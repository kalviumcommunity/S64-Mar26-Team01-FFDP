import 'package:flutter/material.dart';

/// Centralized Theme Configuration for NanheNest using Material 3.
class AppTheme {
  // --- Typography ---
  static const TextTheme _textTheme = TextTheme(
    displayLarge:  TextStyle(fontSize: 57, fontWeight: FontWeight.bold, letterSpacing: -0.25),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
    displaySmall:  TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
    headlineMedium:TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
    titleLarge:    TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
    titleSmall:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    labelMedium:   TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  );

  // --- Light Theme ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary:                Color(0xFF6750A4),
      onPrimary:              Colors.white,
      primaryContainer:       Color(0xFFEADDFF),
      onPrimaryContainer:     Color(0xFF21005D),
      secondary:              Color(0xFF625B71),
      onSecondary:            Colors.white,
      secondaryContainer:     Color(0xFFE8DEF8),
      onSecondaryContainer:   Color(0xFF1D192B),
      error:                  Color(0xFFB3261E),
      onError:                Colors.white,
      // surface replaces deprecated background
      surface:                Color(0xFFFFFBFE),
      onSurface:              Color(0xFF1C1B1F),
      // surfaceContainerHighest replaces deprecated surfaceVariant
      surfaceContainerHighest:Color(0xFFE7E0EC),
      onSurfaceVariant:       Color(0xFF49454F),
      outline:                Color(0xFF79747E),
    ),
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Color(0xFFFFFBFE),
      foregroundColor: Color(0xFF1C1B1F),
    ),
    // CardThemeData (not CardTheme) is the correct type for ThemeData.cardTheme
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFFFFFBFE),
      surfaceTintColor: Colors.transparent,
    ),
  );

  // --- Dark Theme ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary:                Color(0xFFD0BCFF),
      onPrimary:              Color(0xFF381E72),
      primaryContainer:       Color(0xFF4F378B),
      onPrimaryContainer:     Color(0xFFEADDFF),
      secondary:              Color(0xFFCCC2DC),
      onSecondary:            Color(0xFF332D41),
      secondaryContainer:     Color(0xFF4A4458),
      onSecondaryContainer:   Color(0xFFE8DEF8),
      error:                  Color(0xFFF2B8B5),
      onError:                Color(0xFF601410),
      surface:                Color(0xFF1C1B1F),
      onSurface:              Color(0xFFE6E1E5),
      surfaceContainerHighest:Color(0xFF49454F),
      onSurfaceVariant:       Color(0xFFCAC4D0),
      outline:                Color(0xFF938F99),
    ),
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Color(0xFF1C1B1F),
      foregroundColor: Color(0xFFE6E1E5),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1C1B1F),
      surfaceTintColor: Colors.transparent,
    ),
  );
}
