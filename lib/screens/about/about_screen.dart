import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About NanheNest'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // App Logo / Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.diversity_3,
                    size: 56, color: Colors.white),
              ),

              const SizedBox(height: 20),

              Text(
                'NanheNest',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.0.0',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),

              const SizedBox(height: 32),

              const _AboutCard(
                icon: Icons.info_outline,
                title: 'About the App',
                body:
                    'NanheNest is a social and community mobile application built with Flutter and Firebase. '
                    'It enables users to create profiles, share posts, interact in real time, and discover community events.',
              ),

              const _AboutCard(
                icon: Icons.star_outline,
                title: 'Key Features',
                body: '• Email/Password Authentication\n'
                    '• Real-time Firestore Feed\n'
                    '• User Profiles\n'
                    '• Community Posts with Likes\n'
                    '• Multi-Screen Navigation\n'
                    '• Dark Mode Support',
              ),

              const _AboutCard(
                icon: Icons.code_outlined,
                title: 'Tech Stack',
                body: '• Flutter 3.x (Dart)\n'
                    '• Firebase Auth\n'
                    '• Cloud Firestore\n'
                    '• Firebase Storage\n'
                    '• Material Design 3',
              ),

              const _AboutCard(
                icon: Icons.school_outlined,
                title: 'Project Context',
                body:
                    'Built as part of Kalvium Sprint #2. This screen demonstrates multi-screen '
                    'navigation using Navigator.pushNamed(), Navigator.pop(), and named routes '
                    'defined in AppRoutes.',
              ),

              const SizedBox(height: 24),

              // Navigation stack demo
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.settings,
                    arguments: 'Redirected to Settings from About screen',
                  ),
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Go to Settings'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Made with ❤️ by Team01 — Sprint #2, 2026',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _AboutCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
