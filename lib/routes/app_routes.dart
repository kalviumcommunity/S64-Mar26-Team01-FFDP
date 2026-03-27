import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/dashboard_screen.dart';
import '../screens/home/realtime_feed_screen.dart';
import '../screens/home/realtime_chat_list_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/devtools_demo_screen.dart';
import '../screens/state_management_demo.dart';
import '../screens/animations/animation_demo_screen.dart';
import '../screens/firestore_read_demo_screen.dart';
import '../screens/firestore_write_demo_screen.dart';

/// Centralized named route definitions for NanheNest.
///
/// Usage:
///   Navigator.pushNamed(context, AppRoutes.profile);
///   Navigator.pushNamed(context, AppRoutes.settings, arguments: 'msg');
///   Navigator.pop(context);
class AppRoutes {
  AppRoutes._();

  // Route name constants
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String realtimeFeed = '/realtime-feed';
  static const String realtimeChatList = '/realtime-chat-list';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String devToolsDemo = '/devtools-demo';
  static const String stateManagementDemo = '/state-management-demo';
  static const String animationDemo = '/animation-demo';
  static const String firestoreReadDemo = '/firestore-read-demo';
  static const String firestoreWriteDemo = '/firestore-write-demo';

  /// All named routes registered in MaterialApp
  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomeScreen(),
        auth: (_) => const AuthScreen(),
        login: (ctx) => LoginScreen(onSignUpTap: () {
              Navigator.pushReplacementNamed(ctx, signup);
            }),
        signup: (ctx) => SignUpScreen(onLoginTap: () {
              Navigator.pushReplacementNamed(ctx, login);
            }),
        dashboard: (_) => const DashboardScreen(),
        realtimeFeed: (_) => const RealtimeFeedScreen(),
        realtimeChatList: (_) => const RealtimeChatListScreen(),
        profile: (_) => const ProfileScreen(),
        settings: (_) => const SettingsScreen(),
        about: (_) => const AboutScreen(),
        devToolsDemo: (_) => const DevToolsDemoScreen(),
        stateManagementDemo: (_) => const StateManagementDemo(),
        animationDemo: (_) => const AnimationDemoScreen(),
        firestoreReadDemo: (_) => const FirestoreReadDemoScreen(),
        firestoreWriteDemo: (_) => const FirestoreWriteDemoScreen(),
      };
}
