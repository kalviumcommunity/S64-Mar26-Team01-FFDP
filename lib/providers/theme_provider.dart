import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A provider that manages the [ThemeMode] of the application.
/// It allows toggling between Light, Dark, and System theme modes.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  /// Toggle between Light and Dark mode. 
  /// If currently System, it will switch to the opposite of what the system currently is.
  void toggleTheme(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    if (state == ThemeMode.system) {
      state = brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    } else {
      state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    }
  }

  /// Explicitly set the theme mode.
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}
