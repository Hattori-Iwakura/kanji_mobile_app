import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../kanji/presentation/pages/kanji_search_page.dart';
import '../../../kanji/presentation/pages/kanji_lists_page.dart';
import '../../../kanji/presentation/pages/progress_dashboard_page.dart';
import '../../../flashcard/presentation/pages/flashcard_deck_list_page.dart';
import '../../../flashcard/presentation/bloc/flashcard_deck_bloc.dart';
import '../../../flashcard/presentation/bloc/flashcard_deck_event.dart';
import '../../../quiz/presentation/pages/quiz_list_page.dart';
import '../../widgets/app_drawer.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    KanjiSearchPage(),
    KanjiListsPage(),
    ProgressDashboardPage(),
    FlashcardDeckListPage(),
    QuizListPage(),
  ];

  static const List<String> _titles = [
    'Kanji Search',
    'My Lists',
    'Progress',
    'Flashcards',
    'Quizzes',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>()..add(const AuthCheckRequested()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_titles[_selectedIndex]),
            elevation: 0,
            actions: [
              // Search icon (only show when not on search page)
              if (_selectedIndex != 0)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() => _selectedIndex = 0);
                  },
                  tooltip: 'Search Kanji',
                ),
              // Refresh current page
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  // Trigger refresh based on current page
                  _refreshCurrentPage();
                },
                tooltip: 'Refresh',
              ),
              // Notifications
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No new notifications'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                tooltip: 'Notifications',
              ),
            ],
          ),
          drawer: const AppDrawer(),
          body: BlocProvider(
            create: (_) =>
                di.sl<FlashcardDeckBloc>()..add(LoadUserDecksEvent()),
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            elevation: 3,
            height: 70,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Search',
                tooltip: 'Search Kanji',
              ),
              NavigationDestination(
                icon: Icon(Icons.list_outlined),
                selectedIcon: Icon(Icons.list),
                label: 'Lists',
                tooltip: 'My Kanji Lists',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Progress',
                tooltip: 'Learning Progress',
              ),
              NavigationDestination(
                icon: Icon(Icons.style_outlined),
                selectedIcon: Icon(Icons.style),
                label: 'Flashcards',
                tooltip: 'Study with Flashcards',
              ),
              NavigationDestination(
                icon: Icon(Icons.quiz_outlined),
                selectedIcon: Icon(Icons.quiz),
                label: 'Quiz',
                tooltip: 'Take Quizzes',
              ),
            ],
          ),
          floatingActionButton: _buildFAB(),
        ),
      ),
    );
  }

  void _refreshCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        // Search page - no refresh needed, user manually searches
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Search for kanji using the search bar'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 1:
        // Lists page - reload lists
        // Trigger via BLoC if available
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Refreshing lists...'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 2:
        // Progress page - reload progress
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Refreshing progress...'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 3:
        // Flashcards - reload decks
        context.read<FlashcardDeckBloc>().add(LoadUserDecksEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Refreshing flashcard decks...'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
    }
  }

  Widget? _buildFAB() {
    switch (_selectedIndex) {
      case 1: // Lists page
        return FloatingActionButton.extended(
          onPressed: () {
            // Navigate to create list (already handled in KanjiListsPage)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tap the + button on the Lists page'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('New List'),
        );
      case 3: // Flashcards page
        return FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tap the + button on the Flashcards page'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('New Deck'),
        );
      default:
        return null;
    }
  }
}
