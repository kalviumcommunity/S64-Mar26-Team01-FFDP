import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── 1. Auth State Provider ────────────────────────────────────────────────────
// Streams Firebase auth state — any widget can watch this to react to
// login/logout without manual navigation or setState.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ── 2. Counter Provider (StateProvider) ──────────────────────────────────────
// Simple integer state shared across screens.
// Read:   ref.watch(counterProvider)
// Update: ref.read(counterProvider.notifier).state++
final counterProvider = StateProvider<int>((ref) => 0);

// ── 3. Favorites Provider (StateNotifierProvider) ────────────────────────────
// A list of favorite items shared across multiple screens.
// Demonstrates ChangeNotifier-style logic with Riverpod's StateNotifier.
class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier() : super([]);

  void add(String item) {
    if (!state.contains(item)) {
      state = [...state, item];
    }
  }

  void remove(String item) {
    state = state.where((e) => e != item).toList();
  }

  void toggle(String item) {
    state.contains(item) ? remove(item) : add(item);
  }

  bool contains(String item) => state.contains(item);
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>(
  (ref) => FavoritesNotifier(),
);

// ── 4. Theme Mode Provider ────────────────────────────────────────────────────
// Tracks dark/light mode preference globally.
final darkModeProvider = StateProvider<bool>((ref) => false);
