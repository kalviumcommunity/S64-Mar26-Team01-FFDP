import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await AuthService().signOut();
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.email ?? 'User'}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.displayName ?? user?.email ?? 'Friend',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Explore your community and connect with others.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Explore',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Navigation Cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _NavCard(
                      icon: Icons.dashboard_outlined,
                      label: 'Dashboard',
                      description: 'View your feed and posts',
                      color: Colors.blue,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.dashboard),
                    ),
                    _NavCard(
                      icon: Icons.person_outline,
                      label: 'Profile',
                      description: 'View and edit your profile',
                      color: Colors.purple,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                    ),
                    _NavCard(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      description: 'App preferences and account',
                      color: Colors.orange,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                    ),
                    _NavCard(
                      icon: Icons.info_outline,
                      label: 'About',
                      description: 'Learn about NanheNest',
                      color: Colors.teal,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                    ),
                    _NavCard(
                      icon: Icons.storage_outlined,
                      label: 'Firestore Reads',
                      description: 'Live & one-time data reads',
                      color: Colors.deepOrange,
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.firestoreReadDemo),
                    ),
                    _NavCard(
                      icon: Icons.edit_note,
                      label: 'Firestore Writes',
                      description: 'Add, update & set operations',
                      color: Colors.indigo,
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.firestoreWriteDemo),
                    ),
                    _NavCard(
                      icon: Icons.manage_search,
                      label: 'Firestore Queries',
                      description: 'Filter, sort & limit data',
                      color: Colors.green,
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.firestoreQueryDemo),
                    ),
                    _NavCard(
                      icon: Icons.checklist_rtl,
                      label: 'My Items (CRUD)',
                      description: 'Create, read, update, delete',
                      color: Colors.pink,
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.crudDemo),
                    ),
                    _NavCard(
                      icon: Icons.hub_outlined,
                      label: 'Riverpod State',
                      description: 'Shared state across screens',
                      color: Colors.cyan,
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.riverpodDemo),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
