import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Full CRUD flow — users/{uid}/items/{itemId}
/// C: FAB → create dialog
/// R: StreamBuilder real-time list
/// U: edit icon → update dialog
/// D: delete icon → confirmation → delete
class CrudDemoScreen extends StatefulWidget {
  const CrudDemoScreen({super.key});

  @override
  State<CrudDemoScreen> createState() => _CrudDemoScreenState();
}

class _CrudDemoScreenState extends State<CrudDemoScreen> {
  CollectionReference<Map<String, dynamic>> get _items {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('items');
  }

  // ── C: Create ─────────────────────────────────────────────────────────────
  Future<void> _createItem(String title, String desc) async {
    await _items.add({
      'title': title,
      'description': desc,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ── U: Update ─────────────────────────────────────────────────────────────
  Future<void> _updateItem(String id, String newTitle, String newDesc) async {
    await _items.doc(id).update({
      'title': newTitle,
      'description': newDesc,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ── D: Delete ─────────────────────────────────────────────────────────────
  Future<void> _deleteItem(String id) async {
    await _items.doc(id).delete();
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────
  void _openCreateDialog() => _showItemDialog(
        dialogTitle: 'New Item',
        onSave: _createItem,
      );

  void _openEditDialog(String id, String currentTitle, String currentDesc) =>
      _showItemDialog(
        dialogTitle: 'Edit Item',
        initialTitle: currentTitle,
        initialDesc: currentDesc,
        onSave: (t, d) => _updateItem(id, t, d),
      );

  void _showItemDialog({
    required String dialogTitle,
    String initialTitle = '',
    String initialDesc = '',
    required Future<void> Function(String, String) onSave,
  }) {
    final titleCtrl = TextEditingController(text: initialTitle);
    final descCtrl = TextEditingController(text: initialDesc);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (ctx, setS) => AlertDialog(
            title: Text(dialogTitle),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Title', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Title is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Description', border: OutlineInputBorder()),
                    maxLines: 3,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Description is required'
                        : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setS(() => saving = true);
                        try {
                          await onSave(
                              titleCtrl.text.trim(), descCtrl.text.trim());
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red));
                          }
                        } finally {
                          setS(() => saving = false);
                        }
                      },
                child: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Delete "$title"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _deleteItem(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Deleted'), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── R: Read ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Items')),
        body: const Center(child: Text('Please sign in first.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Items'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'users/${user.uid.substring(0, 8)}…/items',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDialog,
        tooltip: 'Create item',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _items.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error)),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No items yet.\nTap + to create one.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data();
              final ts = data['createdAt'] as int?;
              final dateStr = ts != null
                  ? () {
                      final d = DateTime.fromMillisecondsSinceEpoch(ts);
                      return '${d.day}/${d.month}/${d.year}';
                    }()
                  : '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(data['title'] ?? '',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(data['description'] ?? '',
                          style: theme.textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(dateStr,
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.45))),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Edit',
                        onPressed: () => _openEditDialog(doc.id,
                            data['title'] ?? '', data['description'] ?? ''),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            size: 20, color: theme.colorScheme.error),
                        tooltip: 'Delete',
                        onPressed: () =>
                            _confirmDelete(doc.id, data['title'] ?? ''),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
