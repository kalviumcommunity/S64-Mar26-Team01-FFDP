import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

/// Demonstrates all three Firestore write operations:
///   1. add()    — create new document with auto-generated ID
///   2. set()    — write to a specific document ID (merge: true)
///   3. update() — modify specific fields of an existing document
class FirestoreWriteDemoScreen extends StatefulWidget {
  const FirestoreWriteDemoScreen({super.key});

  @override
  State<FirestoreWriteDemoScreen> createState() =>
      _FirestoreWriteDemoScreenState();
}

class _FirestoreWriteDemoScreenState extends State<FirestoreWriteDemoScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ── 1. add() — new document, auto-generated ID ───────────────────────────
  Future<void> _addTask() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      _showSnack('Please fill in both fields', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _firestore.collection('tasks').add({
        'title': title,
        'description': desc,
        'isCompleted': false,
        'uid': AuthService().currentUser?.uid ?? '',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      _titleController.clear();
      _descController.clear();
      _showSnack('Task added via .add()');
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── 2. update() — toggle isCompleted on existing document ────────────────
  Future<void> _toggleComplete(String docId, bool current) async {
    try {
      await _firestore.collection('tasks').doc(docId).update({
        'isCompleted': !current,
        'updatedAt': Timestamp.now(),
      });
      _showSnack('Updated via .update()');
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }
  }

  // ── 3. update() — edit title inline ──────────────────────────────────────
  Future<void> _editTask(String docId, String currentTitle) async {
    final controller = TextEditingController(text: currentTitle);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Task Title'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      try {
        await _firestore.collection('tasks').doc(docId).update({
          'title': controller.text.trim(),
          'updatedAt': Timestamp.now(),
        });
        _showSnack('Title updated via .update()');
      } catch (e) {
        _showSnack('Error: $e', isError: true);
      }
    }
    controller.dispose();
  }

  // ── 4. set(merge:true) — upsert user profile note ────────────────────────
  Future<void> _upsertProfileNote() async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set({'lastWriteDemo': Timestamp.now()}, SetOptions(merge: true));
      _showSnack('Profile updated via .set(merge: true)');
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Write Demo'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Add form ────────────────────────────────────────────────────
          Container(
            color: theme.colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: theme.colorScheme.primary, size: 18),
                    const SizedBox(width: 6),
                    Text('collection("tasks").add({})',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _addTask,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.add),
                        label: const Text('Add Task'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _upsertProfileNote,
                      icon: const Icon(Icons.merge_type, size: 18),
                      label: const Text('set(merge)'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Legend ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('Tasks — tap ✓ to update, ✏ to edit title',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6))),
              ],
            ),
          ),

          // ── Live task list ───────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('tasks')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.task_outlined,
                            size: 56, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('No tasks yet — add one above',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600])),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final isCompleted = data['isCompleted'] as bool? ?? false;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: IconButton(
                          tooltip: 'Toggle — .update()',
                          icon: Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isCompleted
                                ? Colors.green
                                : theme.colorScheme.outline,
                          ),
                          onPressed: () => _toggleComplete(doc.id, isCompleted),
                        ),
                        title: Text(
                          data['title'] ?? '',
                          style: TextStyle(
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Text(data['description'] ?? '',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          tooltip: 'Edit title — .update()',
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () =>
                              _editTask(doc.id, data['title'] ?? ''),
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
    );
  }
}
