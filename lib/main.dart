import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/config/firebase_bootstrap.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';

/// Global navigator key used by NotificationService to push routes
/// from outside the widget tree (e.g. on notification tap).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

import 'config/router.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NanheNestApp());
}

class NanheNestApp extends StatelessWidget {
  const NanheNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NanheNest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}


/// AuthGate handles navigation based on authentication state


  try {
    await FirebaseBootstrap.initialize();
  } catch (e, stack) {
    debugPrint('🚨 Unhandled Firebase error at startup!');
    debugPrint('Error: $e');
    debugPrint('Stack: $stack');
    runApp(const FirebaseErrorApp());
    return;
  }

  // Initialize push notifications after Firebase is ready.
  await NotificationService.instance.initialize(
    onNotificationTap: (payload) {
      // Route the user to the appropriate screen based on notification type.
      final navigator = navigatorKey.currentState;
      if (navigator == null) return;

      switch (payload.type) {
        case 'like':
        case 'comment':
          if (payload.postId != null) {
            navigator.pushNamed(
              AppRoutes.dashboard,
              arguments: payload.postId,
            );
          }
          break;
        case 'message':
          if (payload.chatId != null) {
            navigator.pushNamed(
              AppRoutes.realtimeChatList,
              arguments: payload.chatId,
            );
          }
          break;
        default:
          debugPrint('ℹ️ Unhandled notification type: ${payload.type}');
      }
    },
  );

  runApp(const ProviderScope(child: NanheNestApp()));
}

class FirebaseErrorApp extends StatelessWidget {
  const FirebaseErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(
                  'Failed to initialize application data.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Please check your configuration or internet connection and restart.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NanheNestApp extends StatelessWidget {
  const NanheNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NanheNest',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routes: AppRoutes.routes,
      home: const AuthGate(),
    );
  }
}

/// AuthGate — listens to Firebase auth state for persistent session handling.
///
/// Flow:
///   App opens → SplashScreen (while Firebase checks stored token)
///   Token valid  → HomeScreen  (auto-login, no credentials needed)
///   Token absent → AuthScreen  (user must sign in)
///   User logs out → AuthScreen (session cleared)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges(),
      builder: (context, snapshot) {
        // Firebase is checking the persisted session token — show splash
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // Valid session found → skip login, go straight to HomeScreen
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // No session / logged out → show AuthScreen
        return const AuthScreen();
      },
    );
  }
}
