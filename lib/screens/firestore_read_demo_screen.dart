import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

/// Demonstrates all four Firestore read patterns:
///   1. Real-time stream of a collection (StreamBuilder)
///   2. Single document one-time read (FutureBuilder)
///   3. Filtered query stream (where clause)
///   4. Real-time single document stream
class FirestoreReadDemoScreen extends StatelessWidget {
  const FirestoreReadDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = AuthService().currentUser?.uid ?? '';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Firestore Read Demo'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Live Feed'),
              Tab(text: 'My Posts'),
              Tab(text: 'My Profile'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── Tab 1: Real-time stream of all posts ──────────────────────
            _AllPostsTab(theme: theme),

            // ── Tab 2: Filtered query — only current user's posts ─────────
            _MyPostsTab(uid: uid, theme: theme),

            // ── Tab 3: Single document read — user profile ────────────────
            _ProfileTab(uid: uid, theme: theme),
          ],
        ),
      ),
    );
  }
}

// ── Tab 1: StreamBuilder on posts/ collection ─────────────────────────────────
class _AllPostsTab extends StatelessWidget {
  final ThemeData theme;
  const _AllPostsTab({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          icon: Icons.stream,
          label: 'Real-time stream — posts/ collection',
          subtitle: 'Updates instantly when Firestore data changes',
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const _EmptyState(
                  icon: Icons.article_outlined,
                  message: 'No posts yet.\nCreate one from the Dashboard.',
                );
              }
              final docs = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  return _PostCard(data: data);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Tab 2: Filtered query — where('uid', isEqualTo: uid) ─────────────────────
class _MyPostsTab extends StatelessWidget {
  final String uid;
  final ThemeData theme;
  const _MyPostsTab({required this.uid, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          icon: Icons.filter_list,
          label: 'Filtered query — my posts only',
          subtitle: '.where("uid", isEqualTo: currentUser.uid)',
        ),
        Expanded(
          child: uid.isEmpty
              ? const _EmptyState(
                  icon: Icons.lock_outline,
                  message: 'Sign in to see your posts',
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: uid)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const _EmptyState(
                        icon: Icons.edit_note,
                        message: "You haven't posted anything yet.",
                      );
                    }
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        return _PostCard(data: data, highlight: true);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Tab 3: FutureBuilder + StreamBuilder for single document ─────────────────
class _ProfileTab extends StatelessWidget {
  final String uid;
  final ThemeData theme;
  const _ProfileTab({required this.uid, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── One-time read with FutureBuilder ──────────────────────────
          const _SectionHeader(
            icon: Icons.download_outlined,
            label: 'One-time read — FutureBuilder',
            subtitle: '.collection("users").doc(uid).get()',
          ),
          uid.isEmpty
              ? const _EmptyState(
                  icon: Icons.lock_outline,
                  message: 'Sign in to view profile',
                )
              : FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const _EmptyState(
                        icon: Icons.person_off_outlined,
                        message: 'No Firestore profile found.\n'
                            'Sign up to create one.',
                      );
                    }
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    return _ProfileCard(data: data, isLive: false);
                  },
                ),

          const SizedBox(height: 24),

          // ── Real-time stream with StreamBuilder ───────────────────────
          const _SectionHeader(
            icon: Icons.sync,
            label: 'Real-time stream — StreamBuilder',
            subtitle: '.collection("users").doc(uid).snapshots()',
          ),
          uid.isEmpty
              ? const _EmptyState(
                  icon: Icons.lock_outline,
                  message: 'Sign in to view live profile',
                )
              : StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const _EmptyState(
                        icon: Icons.person_off_outlined,
                        message: 'No Firestore profile found.',
                      );
                    }
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    return _ProfileCard(data: data, isLive: true);
                  },
                ),
        ],
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool highlight;
  const _PostCard({required this.data, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ts = data['createdAt'];
    String timeStr = '';
    if (ts is Timestamp) {
      final dt = ts.toDate();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) {
        timeStr = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        timeStr = '${diff.inHours}h ago';
      } else {
        timeStr = '${dt.day}/${dt.month}/${dt.year}';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: highlight
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['displayName'] ?? 'Anonymous',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(timeStr,
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5))),
              ],
            ),
            const SizedBox(height: 8),
            Text(data['content'] ?? '', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.favorite_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 4),
                Text('${data['likes'] ?? 0}',
                    style: theme.textTheme.labelSmall),
                const SizedBox(width: 12),
                Icon(Icons.comment_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 4),
                Text('${data['comments'] ?? 0}',
                    style: theme.textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isLive;
  const _ProfileCard({required this.data, required this.isLive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                  child: Text(
                    ((data['displayName'] as String?)?.isNotEmpty == true
                            ? (data['displayName'] as String)[0]
                            : '?')
                        .toUpperCase(),
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['displayName'] ?? '—',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(data['email'] ?? '—',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLive
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isLive ? '● Live' : 'Snapshot',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isLive ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _Row(
                'Bio',
                data['bio']?.toString().isNotEmpty == true
                    ? data['bio']
                    : 'No bio set'),
            _Row('Posts', '${data['postCount'] ?? 0}'),
            _Row('Followers', '${data['followerCount'] ?? 0}'),
            _Row('Following', '${data['followingCount'] ?? 0}'),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
