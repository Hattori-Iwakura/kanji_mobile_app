import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_event.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../../kanji/presentation/pages/admin_kanji_list_page.dart';
import '../../kanji_recognition/presentation/pages/kanji_drawing_page.dart';
import '../../kanji_recognition/presentation/bloc/kanji_recognition_bloc.dart';
import '../../../injection_container.dart' as di;

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerHeader(context, user),
              const Divider(height: 1),

              // Main Features
              _buildSectionTitle(context, 'Learn'),
              _buildDrawerItem(
                context,
                icon: Icons.search,
                title: 'Search Kanji',
                subtitle: 'Find and learn kanji',
                onTap: () {
                  Navigator.pop(context);
                  // Already on main page with search
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.draw_outlined,
                title: 'Draw Kanji',
                subtitle: 'Recognition by drawing',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => di.sl<KanjiRecognitionBloc>(),
                        child: const KanjiDrawingPage(),
                      ),
                    ),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.list_alt,
                title: 'My Lists',
                subtitle: 'Manage kanji lists',
                onTap: () {
                  Navigator.pop(context);
                  // Switch to Lists tab
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.style,
                title: 'Flashcards',
                subtitle: 'Study with flashcards',
                onTap: () {
                  Navigator.pop(context);
                  // Switch to Flashcards tab
                },
              ),

              const Divider(),

              // Progress & Stats
              _buildSectionTitle(context, 'Progress'),
              _buildDrawerItem(
                context,
                icon: Icons.bar_chart,
                title: 'My Progress',
                subtitle: 'View learning statistics',
                onTap: () {
                  Navigator.pop(context);
                  // Switch to Progress tab
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.emoji_events_outlined,
                title: 'Achievements',
                subtitle: 'View your achievements',
                badge: 'Soon',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Achievements feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const Divider(),

              // Admin & Settings
              _buildSectionTitle(context, 'More'),
              if (user != null) ...[
                _buildDrawerItem(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Admin Panel',
                  subtitle: 'Manage kanji database',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminKanjiListPage(),
                      ),
                    );
                  },
                ),
              ],
              _buildDrawerItem(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'App preferences',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings page coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help',
                onTap: () {
                  Navigator.pop(context);
                  _showHelpDialog(context);
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App information',
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog(context);
                },
              ),

              const Divider(),

              // Logout
              _buildDrawerItem(
                context,
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                iconColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, dynamic user) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          user?.account[0].toUpperCase() ?? 'U',
          style: TextStyle(
            fontSize: 40,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      accountName: Text(
        user?.account ?? 'User',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(
        user?.email ?? 'user@example.com',
        style: const TextStyle(fontSize: 14),
      ),
      otherAccountsPictures: [
        IconButton(
          icon: const Icon(Icons.brightness_6, color: Colors.white),
          onPressed: () {
            // Toggle theme (placeholder)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Theme toggle coming soon!'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          tooltip: 'Toggle theme',
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    String? badge,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Row(
        children: [
          Expanded(child: Text(title)),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      onTap: onTap,
      dense: true,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Help & Support'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How to use:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildHelpItem(
                'Search',
                'Find kanji by character, meaning, or reading',
              ),
              _buildHelpItem('Draw', 'Draw a kanji to recognize it'),
              _buildHelpItem('Lists', 'Create custom lists to organize kanji'),
              _buildHelpItem('Progress', 'Track your learning progress'),
              _buildHelpItem('Flashcards', 'Study with spaced repetition'),
              const SizedBox(height: 16),
              const Text(
                'Need more help?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Email: support@kanjiapp.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Kanji Learning App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.book, size: 48, color: Colors.blue),
      applicationLegalese: '© 2025 Kanji Learning App. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'A comprehensive Japanese kanji learning application with search, '
          'recognition, flashcards, and progress tracking.',
        ),
        const SizedBox(height: 8),
        const Text(
          'Features:\n'
          '• Search 3000+ kanji\n'
          '• Handwriting recognition\n'
          '• Custom lists\n'
          '• Flashcard study\n'
          '• Progress tracking\n'
          '• JLPT & Grade levels',
        ),
      ],
    );
  }
}
