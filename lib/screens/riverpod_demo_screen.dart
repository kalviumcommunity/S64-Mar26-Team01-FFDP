import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

/// Demonstrates Riverpod state management across multiple tabs:
///   Tab 1 — StateProvider (counter shared across screens)
///   Tab 2 — StateNotifierProvider (favorites list)
///   Tab 3 — StreamProvider (Firebase auth state)
class RiverpodDemoScreen extends ConsumerWidget {
  const RiverpodDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riverpod State Demo'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Counter'),
              Tab(text: 'Favorites'),
              Tab(text: 'Auth State'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CounterTab(),
            _FavoritesTab(),
            _AuthStateTab(),
          ],
        ),
      ),
    );
  }
}

// ── Tab 1: StateProvider — counter ────────────────────────────────────────────
class _CounterTab extends ConsumerWidget {
  const _CounterTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch rebuilds this widget whenever counterProvider changes
    final count = ref.watch(counterProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CodeChip(
            'final count = ref.watch(counterProvider);',
            theme: theme,
          ),
          const SizedBox(height: 32),
          Text(
            '$count',
            style: theme.textTheme.displayLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('shared counter value', style: theme.textTheme.bodySmall),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => ref.read(counterProvider.notifier).state--,
                icon: const Icon(Icons.remove),
                label: const Text('Decrement'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => ref.read(counterProvider.notifier).state++,
                icon: const Icon(Icons.add),
                label: const Text('Increment'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => ref.read(counterProvider.notifier).state = 0,
            child: const Text('Reset'),
          ),
          const SizedBox(height: 32),
          _InfoCard(
            'This counter is shared globally. Navigate away and back — the value persists.',
            theme: theme,
          ),
        ],
      ),
    );
  }
}

// ── Tab 2: StateNotifierProvider — favorites ──────────────────────────────────
class _FavoritesTab extends ConsumerWidget {
  const _FavoritesTab();

  static const _items = [
    'Flutter',
    'Firebase',
    'Riverpod',
    'Dart',
    'Firestore',
    'Cloud Functions',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          color: theme.colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CodeChip(
                'final favorites = ref.watch(favoritesProvider);',
                theme: theme,
              ),
              const SizedBox(height: 6),
              Text(
                '${favorites.length} item${favorites.length == 1 ? '' : 's'} favorited',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text('Tap to toggle favorites:',
                  style: theme.textTheme.labelMedium),
              const SizedBox(height: 8),
              ..._items.map((item) {
                final isFav = favorites.contains(item);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(item),
                    trailing: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : null,
                      ),
                      onPressed: () =>
                          ref.read(favoritesProvider.notifier).toggle(item),
                    ),
                  ),
                );
              }),
              if (favorites.isNotEmpty) ...[
                const Divider(height: 24),
                Text('Your favorites:', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: favorites
                      .map((f) => Chip(
                            label: Text(f),
                            onDeleted: () =>
                                ref.read(favoritesProvider.notifier).remove(f),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tab 3: StreamProvider — Firebase auth state ───────────────────────────────
class _AuthStateTab extends ConsumerWidget {
  const _AuthStateTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch on a StreamProvider returns AsyncValue<User?>
    final authAsync = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CodeChip(
            'final authAsync = ref.watch(authStateProvider);',
            theme: theme,
          ),
          const SizedBox(height: 32),
          authAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e',
                style: TextStyle(color: theme.colorScheme.error)),
            data: (user) => Column(
              children: [
                Icon(
                  user != null ? Icons.verified_user : Icons.no_accounts,
                  size: 64,
                  color: user != null ? Colors.green : Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  user != null ? 'Signed In' : 'Signed Out',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: user != null ? Colors.green : Colors.grey,
                  ),
                ),
                if (user != null) ...[
                  const SizedBox(height: 8),
                  Text(user.email ?? user.uid,
                      style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          _InfoCard(
            'StreamProvider wraps Firebase authStateChanges().\n'
            'Any widget watching this rebuilds automatically on login/logout.',
            theme: theme,
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────
class _CodeChip extends StatelessWidget {
  final String code;
  final ThemeData theme;
  const _CodeChip(this.code, {required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        code,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String text;
  final ThemeData theme;
  const _InfoCard(this.text, {required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
          ),
        ],
      ),
    );
  }
}
