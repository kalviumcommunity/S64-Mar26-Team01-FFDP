import 'package:flutter/foundation.dart';

/// Reusable logging utility for the NanheNest app.
///
/// Provides tagged, timestamped log output via [debugPrint]
/// so messages appear in the Debug Console during development.
class AppLogger {
  AppLogger._();

  static void debugLog(String message, {String tag = 'DEBUG'}) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$tag] $timestamp: $message');
  }

  static void errorLog(String message,
      {String tag = 'ERROR', Object? error, StackTrace? stackTrace}) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$tag] $timestamp: $message');
    if (error != null) {
      debugPrint('[$tag] $timestamp: Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('[$tag] $timestamp: StackTrace: $stackTrace');
    }
  }

  static void infoLog(String message, {String tag = 'INFO'}) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$tag] $timestamp: $message');
  }
}
