import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/config/firebase_bootstrap.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await FirebaseBootstrap.initialize();
  } catch (e, stack) {
    debugPrint('🚨 Unhandled Firebase error at startup!');
    debugPrint('Error: $e');
    debugPrint('Stack: $stack');
    runApp(const FirebaseErrorApp());
    return;
  }

  runApp(const NanheNestApp());
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routes: AppRoutes.routes,
      home: const AuthGate(),
    );
  }
}

/// AuthGate listens to Firebase auth state and routes accordingly.
/// No manual Navigator calls needed — the stream handles all transitions.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Signed in → HomeScreen
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        // Signed out → AuthScreen (combined login/signup)
        return const AuthScreen();
      },
    );
  }
}
