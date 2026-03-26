import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/config/firebase_bootstrap.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase using the core configuration wrapper
    await FirebaseBootstrap.initialize();
  } catch (e, stack) {
    debugPrint('🚨 Unhandled Firebase error at startup!');
    debugPrint('Error: $e');
    debugPrint('Stack: $stack');
    
    // In a production app, handle fallback logic here.
    runApp(const FirebaseErrorApp());
    return;
  }

  runApp(const NanheNestApp());
}

class FirebaseErrorApp extends StatelessWidget {
  const FirebaseErrorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: const [
                 Icon(Icons.error_outline, color: Colors.red, size: 48),
                 SizedBox(height: 16),
                 Text(
                   'Failed to initialize application data.',
                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                   textAlign: TextAlign.center,
                 ),
                 SizedBox(height: 8),
                 Text('Please check your configuration or internet connection and restart.',
                   textAlign: TextAlign.center,
                 ),
               ],
             )
          )
        )
      )
    );
  }
}

class NanheNestApp extends StatelessWidget {
  const NanheNestApp({Key? key}) : super(key: key);

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
      // Named routes — use Navigator.pushNamed(context, AppRoutes.profile)
      routes: AppRoutes.routes,
      // AuthGate is the initial screen; it decides login vs dashboard
      home: const AuthGate(),
    );
  }
}

/// AuthGate handles navigation based on authentication state
class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();
  bool _showLoginScreen = true;

  void _toggleAuthScreen() {
    setState(() => _showLoginScreen = !_showLoginScreen);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading spinner while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is logged in
        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        // User is not logged in - show auth screens
        return _showLoginScreen
            ? LoginScreen(onSignUpTap: _toggleAuthScreen)
            : SignUpScreen(onLoginTap: _toggleAuthScreen);
      },
    );
  }
}
