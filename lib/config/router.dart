import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/main_scaffold.dart';
import '../screens/home/dashboard_screen.dart';
import '../screens/home/sitter_profile_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/phone_auth_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/chat/chat_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/home/onboarding_screen.dart';
import '../screens/home/global_loader.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    navigatorKey: rootNavigatorKey,
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/phone-auth' ||
          state.matchedLocation == '/otp-auth' ||
          state.matchedLocation == '/loader'; // allow loader

      if (!loggedIn && !isLoggingIn) return '/login';
      if (loggedIn && isLoggingIn && state.matchedLocation != '/loader')
        return '/';
      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(
          onSignUpTap: () => context.go('/signup'),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => SignUpScreen(
          onLoginTap: () => context.go('/login'),
        ),
      ),
      GoRoute(
        path: '/phone-auth',
        name: 'phone-auth',
        builder: (context, state) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: '/otp-auth',
        name: 'otp-auth',
        builder: (context, state) {
          final verificationId = state.extra as String? ?? '';
          return OtpScreen(verificationId: verificationId);
        },
      ),
      GoRoute(
        path: '/loader',
        name: 'loader',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final targetRoute = state.extra as String? ?? '/';
          return GlobalLoaderScreen(nextRoute: targetRoute);
        },
      ),
      GoRoute(
        path: '/sitter/:id',
        name: 'sitter_profile',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 's1';
          return SitterProfileScreen(id: id);
        },
      ),
      GoRoute(
        path: '/chat/:sitterId',
        name: 'chat_detail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final sitterId = state.pathParameters['sitterId'] ?? 's1';
          return ChatDetailScreen(sitterId: sitterId);
        },
      ),

      // Main App Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
