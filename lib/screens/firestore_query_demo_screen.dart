import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

/// Demonstrates Firestore query capabilities:
///   - where()   : equality, comparison, arrayContains filters
///   - orderBy() : ascending / descending sorting
///   - limit()   : cap result count
///   - Composite : where + orderBy chained together
class FirestoreQueryDemoScreen extends StatefulWidget {
  const FirestoreQueryDemoScreen({super.key});

  @override
  State<FirestoreQueryDemoScreen> createState() =>
      _FirestoreQueryDemoScreenState();
}

class _FirestoreQueryDemoScreenState extends State<FirestoreQueryDemoScreen> {
  final _firestore = FirebaseFirestore.instance;

  // ── Filter state ──────────────────────────────────────────────────────────
  bool _showOnlyIncomplete = false;
  String _sortField = 'createdAt';
  bool _descending = true;
  int _limit = 10;

  // ── Active query ──────────────────────────────────────────────────────────
  Stream<QuerySnapshot> get _queryStream {
    Query q = _firestore.collection('tasks');

    // where() filter
    if (_showOnlyIncomplete) {
      q = q.where('isCompleted', isEqualTo: false);
    }

    // orderBy() + limit()
    q = q.orderBy(_sortField, descending: _descending).limit(_limit);

    return q.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Queries'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Query builder panel ─────────────────────────────────────────
          Container(
            color: theme.colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Query',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                _QueryChip(label: _buildQueryString(), theme: theme),
                const SizedBox(height: 12),

                // where toggle
                Row(
                  children: [
                    Expanded(
                      child: Text('.where("isCompleted", isEqualTo: false)',
                          style: theme.textTheme.bodySmall),
                    ),
                    Switch(
                      value: _showOnlyIncomplete,
                      onChanged: (v) => setState(() => _showOnlyIncomplete = v),
                    ),
                  ],
                ),

                // orderBy field
                Row(
                  children: [
                    Text('.orderBy(  ', style: theme.textTheme.bodySmall),
                    const SizedBox(width: 4),
                    DropdownButton<String>(
                      value: _sortField,
                      isDense: true,
                      items: const [
                        DropdownMenuItem(
                            value: 'createdAt', child: Text('createdAt')),
                        DropdownMenuItem(value: 'title', child: Text('title')),
                        DropdownMenuItem(
                            value: 'updatedAt', child: Text('updatedAt')),
                        DropdownMenuItem(
                            value: 'priority', child: Text('priority')),
                      ],
                      onChanged: (v) =>
                          setState(() => _sortField = v ?? 'createdAt'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('DESC'),
                      selected: _descending,
                      onSelected: (v) => setState(() => _descending = true),
                    ),
                    const SizedBox(width: 4),
                    ChoiceChip(
                      label: const Text('ASC'),
                      selected: !_descending,
                      onSelected: (v) => setState(() => _descending = false),
                    ),
                    Text('  )', style: theme.textTheme.bodySmall),
                  ],
                ),

                // limit
                Row(
                  children: [
                    Text('.limit(', style: theme.textTheme.bodySmall),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _limit,
                      isDense: true,
                      items: [5, 10, 20, 50]
                          .map((n) =>
                              DropdownMenuItem(value: n, child: Text('$n')))
                          .toList(),
                      onChanged: (v) => setState(() => _limit = v ?? 10),
                    ),
                    Text(')', style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),

          // ── Result count label ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.filter_list,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  _showOnlyIncomplete
                      ? 'Showing: incomplete tasks only'
                      : 'Showing: all tasks',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),

          // ── Live results ────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _queryStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  // Firestore composite index errors surface here
                  return _ErrorState(message: snapshot.error.toString());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _EmptyState(
                    message: _showOnlyIncomplete
                        ? 'No incomplete tasks found.'
                        : 'No tasks yet.\nAdd some from Firestore Writes.',
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final isCompleted = data['isCompleted'] as bool? ?? false;
                    final ts = data[_sortField];
                    final sortValue =
                        ts is Timestamp ? _formatTs(ts) : ts?.toString() ?? '—';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isCompleted
                              ? Colors.green
                              : theme.colorScheme.outline,
                        ),
                        title: Text(
                          data['title'] ?? '—',
                          style: TextStyle(
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          data['description'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_sortField,
                                style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary)),
                            Text(sortValue, style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // ── Seed button — adds sample tasks if collection is empty ──────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _seedSampleTasks,
        icon: const Icon(Icons.add),
        label: const Text('Seed Tasks'),
      ),
    );
  }

  String _buildQueryString() {
    final filter = _showOnlyIncomplete ? '.where("isCompleted", false)' : '';
    final order = '.orderBy("$_sortField", ${_descending ? 'desc' : 'asc'})';
    return 'tasks$filter$order.limit($_limit)';
  }

  String _formatTs(Timestamp ts) {
    final dt = ts.toDate();
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _seedSampleTasks() async {
    final uid = AuthService().currentUser?.uid ?? 'demo';
    final samples = [
      {'title': 'Learn Flutter', 'description': 'Complete the Flutter course', 'isCompleted': false, 'priority': 1},
      {'title': 'Build NanheNest', 'description': 'Implement all Firebase features', 'isCompleted': false, 'priority': 2},
      {'title': 'Write unit tests', 'description': 'Cover validators and services', 'isCompleted': true, 'priority': 3},
      {'title': 'Deploy to Play Store', 'description': 'Release v1.0 on Android', 'isCompleted': false, 'priority': 4},
      {'title': 'Design Firestore schema', 'description': 'Plan collections and indexes', 'isCompleted': true, 'priority': 5},
    ];

    for (final s in samples) {
      await _firestore.collection('tasks').add({
        ...s,
        'uid': uid,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('5 sample tasks added'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _QueryChip extends StatelessWidget {
  final String label;
  final ThemeData theme;
  const _QueryChip({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text('Query Error',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.error)),
            const SizedBox(height: 8),
            Text(
              message.contains('index')
                  ? 'A composite index is required.\nCreate it in Firebase Console → Firestore → Indexes.'
                  : message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
