import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/kanji/presentation/pages/kanji_dictionary_page.dart';
import '../../features/kanji/presentation/pages/kanji_detail_page.dart';
import '../../features/kanji/presentation/pages/kanji_search_page.dart';
import '../../features/kanji/presentation/pages/kanji_create_page.dart';
import '../../features/kanji_list/presentation/pages/kanji_lists_page.dart';
import '../../features/kanji_list/presentation/pages/kanji_list_detail_page.dart';
import '../../features/flashcard/presentation/pages/deck_list_page.dart';
import '../../features/flashcard/presentation/pages/deck_detail_page.dart';
import '../../features/quiz/presentation/pages/quiz_list_page.dart';
// TODO: Fix quiz_session_page - using old architecture
// import '../../features/quiz/presentation/pages/quiz_session_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
// TODO: Fix admin pages - using old models
// import '../../features/admin/presentation/pages/admin_users_page.dart';
import '../../features/admin/presentation/pages/admin_kanji_page.dart';
// import '../../features/admin/presentation/pages/admin_quizzes_page.dart';
import '../../features/kanji/presentation/bloc/kanji_bloc.dart';
import '../../injection_container.dart' as di;
import '../config/env_config.dart';
import '../debug/debug_settings_page.dart';
import 'app_routes.dart';

/// Generate routes based on route settings
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Print environment config in debug mode
    if (EnvConfig.isDebugMode) {
      print('Navigating to: ${settings.name}');
      print('API Base URL: ${EnvConfig.apiBaseUrl}');
    }

    // Extract arguments if any
    final args = settings.arguments;

    switch (settings.name) {
      // Auth routes
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      // Main routes
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      // Profile route
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      // Kanji Dictionary routes
      case AppRoutes.kanjiDictionary:
        return MaterialPageRoute(builder: (_) => const KanjiDictionaryPage());

      case AppRoutes.kanjiDetail:
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => KanjiDetailPage(kanjiId: args),
          );
        }
        return _errorRoute();

      case AppRoutes.kanjiCreate:
        // Check if editing existing kanji
        final kanjiId = args is int ? args : null;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<KanjiBloc>(),
            child: KanjiCreatePage(kanjiId: kanjiId),
          ),
        );

      // Kanji List routes
      case AppRoutes.kanjiLists:
        return MaterialPageRoute(builder: (_) => const KanjiListsPage());

      case AppRoutes.kanjiListDetail:
        final listId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => KanjiListDetailPage(listId: listId),
        );

      // Search route
      case AppRoutes.search:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<KanjiBloc>(),
            child: const KanjiSearchPage(),
          ),
        );

      // Flashcard routes
      case AppRoutes.flashcardDecks:
        return MaterialPageRoute(builder: (_) => const DeckListPage());

      case AppRoutes.flashcardDeckDetail:
        final deckId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => DeckDetailPage(deckId: deckId),
        );

      // Quiz routes
      case AppRoutes.quizList:
        return MaterialPageRoute(builder: (_) => const QuizListPage());

      // TODO: Fix quiz session page - temporarily disabled
      // case AppRoutes.quizDetail:
      //   final quizId = settings.arguments as int;
      //   return MaterialPageRoute(
      //     builder: (_) => QuizSessionPage(quizId: quizId),
      //   );

      // case AppRoutes.quizSession:
      //   final quizId = settings.arguments as int;
      //   return MaterialPageRoute(
      //     builder: (_) => QuizSessionPage(quizId: quizId),
      //   );

      // Admin routes
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());

      // TODO: Fix admin pages - temporarily disabled
      // case AppRoutes.adminUsers:
      //   return MaterialPageRoute(builder: (_) => const AdminUsersPage());

      case AppRoutes.adminKanji:
        return MaterialPageRoute(builder: (_) => const AdminKanjiPage());

      // case AppRoutes.adminQuizzes:
      //   return MaterialPageRoute(builder: (_) => const AdminQuizzesPage());

      // Debug routes (only available in debug mode)
      case AppRoutes.debugSettings:
        if (EnvConfig.isDebugMode) {
          return MaterialPageRoute(builder: (_) => const DebugSettingsPage());
        }
        return _errorRoute();

      // Default - route not found
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }
}
