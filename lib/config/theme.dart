import 'package:flutter/material.dart';

/// Centralized Theme Configuration for NanheNest using Material 3.
///
/// Primary  — pinkish pale red  → #B5363E
/// Secondary — bluish teal       → #3A6B67
class AppTheme {
  // --- Typography ---
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
        fontSize: 57, fontWeight: FontWeight.bold, letterSpacing: -0.25),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
    titleSmall: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    bodyLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    bodySmall: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    labelLarge: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    labelMedium: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    labelSmall: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  );

  // --- Light Theme ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      // Primary — pinkish / pale red
      primary: Color(0xFFB5363E), // deep rose-red
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFFFDAD9), // very pale pink
      onPrimaryContainer: Color(0xFF410007),

      // Secondary — bluish teal
      secondary: Color(0xFF3A6B67), // teal-blue
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFBCEBE6), // pale mint-green
      onSecondaryContainer: Color(0xFF00201E),

      error: Color(0xFFB3261E),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFFFF8F7), // warm white with pink tint
      onSurface: Color(0xFF201A1A),
      surfaceContainerHighest: Color(0xFFFFDAD9),
      onSurfaceVariant: Color(0xFF534342),
      outline: Color(0xFF857371),
    ),
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Color(0xFFFFF8F7),
      foregroundColor: Color(0xFF201A1A),
    ),
    cardTheme: const CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      color: Color(0xFFFFF8F7),
      surfaceTintColor: Colors.transparent,
    ),
  );

  // --- Dark Theme ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      // Primary — pinkish / pale red (lighter for dark bg)
      primary: Color(0xFFFFB3B3), // soft pink
      onPrimary: Color(0xFF680011),
      primaryContainer: Color(0xFF920020),
      onPrimaryContainer: Color(0xFFFFDAD9),

      // Secondary — bluish teal (lighter for dark bg)
      secondary: Color(0xFFA0CFCA), // pale teal
      onSecondary: Color(0xFF003734),
      secondaryContainer: Color(0xFF21504D),
      onSecondaryContainer: Color(0xFFBCEBE6),

      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      surface: Color(0xFF201A1A),
      onSurface: Color(0xFFEDE0DF),
      surfaceContainerHighest: Color(0xFF534342),
      onSurfaceVariant: Color(0xFFD8C2C1),
      outline: Color(0xFFA08C8B),
    ),
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Color(0xFF201A1A),
      foregroundColor: Color(0xFFEDE0DF),
    ),
    cardTheme: const CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      color: Color(0xFF201A1A),
      surfaceTintColor: Colors.transparent,
    ),
  );
}
