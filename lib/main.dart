import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash_screen.dart';
import 'config/router.dart';
import 'config/theme.dart';
import 'providers/theme_provider.dart';

/// Global navigator key used by NotificationService to push routes
/// from outside the widget tree (e.g. on notification tap).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    debugPrint('🚨 Unhandled Firebase error at startup!');
    debugPrint('Error: $e');
    debugPrint('Stack: $stack');
    runApp(const FirebaseErrorApp());
    return;
  }

  // Initialize push notifications after Firebase is ready.
  try {
    await NotificationService.instance.initialize(
      onNotificationTap: (payload) {
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
  } catch (e) {
    debugPrint('⚠️ Notification service init failed: $e');
  }

  runApp(
    const ProviderScope(
      child: NanheNestApp(),
    ),
  );
}

class NanheNestApp extends ConsumerWidget {
  const NanheNestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme state
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'NanheNest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
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
