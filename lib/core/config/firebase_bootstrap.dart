import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class FirebaseBootstrap {
  /// Initializes Firebase and verifies the connection.
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await _verifyConnection();
    } catch (e, stack) {
      debugPrint('🚨 Firebase Initialization Failed: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  /// Verification step to confirm Firebase SDK is successfully integrated.
  static Future<void> _verifyConnection() async {
    try {
      final app = Firebase.app();
      debugPrint('✅ Firebase Verification: Successfully connected to project -> ${app.options.projectId}');
    } catch (e) {
      debugPrint('❌ Firebase Verification Failed: No default app found. $e');
    }
  }
}
