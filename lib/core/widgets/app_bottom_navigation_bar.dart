import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../routes/app_routes.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // NOTE: Backend returns 'ADMIN' (uppercase)
        final isAdmin =
            state is Authenticated && state.user.role.toUpperCase() == 'ADMIN';

        // Define navigation items based on user role
        final items = <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Kanji'),
          const BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lists'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.style),
            label: 'Flashcards',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          if (isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
        ];

        // Validate currentIndex to prevent crash when switching between admin/user
        final safeIndex = currentIndex >= items.length ? 0 : currentIndex;

        return BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: onTap,
          items: items,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 8,
        );
      },
    );
  }
}

/// Main scaffold wrapper with bottom navigation
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // Route mapping for each tab
  final List<String> _routes = [
    AppRoutes.home,
    AppRoutes.kanjiDictionary,
    AppRoutes.kanjiLists,
    AppRoutes.flashcardDecks,
    AppRoutes.quizList,
    AppRoutes.adminDashboard, // For admin users
  ];

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });

      // Navigate to the selected route
      Navigator.pushReplacementNamed(context, _routes[index]);
    }
  }

  // Determine current index based on current route
  int _getCurrentIndex(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute == null) return 0;

    // Map routes to indices
    if (currentRoute.contains(AppRoutes.home) ||
        currentRoute.contains('/user-landing')) {
      return 0;
    } else if (currentRoute.contains(AppRoutes.kanjiDictionary) ||
        currentRoute.contains('/kanji')) {
      return 1;
    } else if (currentRoute.contains(AppRoutes.kanjiLists) ||
        currentRoute.contains('/kanji-list')) {
      return 2;
    } else if (currentRoute.contains(AppRoutes.flashcardDecks) ||
        currentRoute.contains('/flashcard')) {
      return 3;
    } else if (currentRoute.contains(AppRoutes.quizList) ||
        currentRoute.contains('/quiz')) {
      return 4;
    } else if (currentRoute.contains(AppRoutes.adminDashboard) ||
        currentRoute.contains('/admin')) {
      return 5;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    // Update current index based on route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newIndex = _getCurrentIndex(context);
      if (newIndex != _currentIndex && mounted) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    });

    return const Placeholder(); // This will be replaced by actual pages
  }
}
