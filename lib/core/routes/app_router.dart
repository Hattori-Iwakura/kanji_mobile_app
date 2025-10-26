import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../di/injection.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/dashboard/presentation/pages/home_page.dart';
import '../../features/progress/presentation/bloc/progress_bloc.dart';
import '../../features/progress/presentation/pages/progress_overview_page.dart';
import '../../features/progress/presentation/pages/leaderboard_page.dart';
import '../../features/progress/presentation/pages/achievements_page.dart';
import '../../features/user_management/presentation/bloc/user_management_bloc.dart';
import '../../features/user_management/presentation/pages/user_management_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page_real.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/';
  static const String profile = '/profile';
  static const String kanji = '/kanji';
  static const String kanjiDetail = '/kanji/:id';
  static const String kanjiSearch = '/search';
  static const String flashcards = '/flashcards';
  static const String quiz = '/quiz';
  static const String settings = '/settings';
  static const String admin = '/admin';
  static const String dashboard = '/dashboard';
  static const String progress = '/progress';
  static const String progressLeaderboard = '/progress/leaderboard';
  static const String progressAchievements = '/progress/achievements';
  static const String progressStatistics = '/progress/statistics';
  static const String userManagement = '/admin/users';
  static const String adminDashboard = '/admin/dashboard';

  static GoRouter createRouter({required bool isAuthenticated}) {
    return GoRouter(
      initialLocation: isAuthenticated ? home : login,
      routes: [
        // Auth Routes
        GoRoute(path: login, builder: (context, state) => const LoginPage()),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: forgotPassword,
          builder: (context, state) => const ForgotPasswordPage(),
        ),

        // Protected Routes
        GoRoute(path: home, builder: (context, state) => const HomePage()),

        // Progress Routes
        GoRoute(
          path: progress,
          builder: (context, state) => BlocProvider(
            create: (context) => getIt<ProgressBloc>(),
            child: const ProgressOverviewPage(),
          ),
        ),
        GoRoute(
          path: progressLeaderboard,
          builder: (context, state) => BlocProvider(
            create: (context) => getIt<ProgressBloc>(),
            child: const LeaderboardPage(),
          ),
        ),
        GoRoute(
          path: progressAchievements,
          builder: (context, state) => BlocProvider(
            create: (context) => getIt<ProgressBloc>(),
            child: const AchievementsPage(),
          ),
        ),

        // Admin Routes
        GoRoute(
          path: userManagement,
          builder: (context, state) => BlocProvider(
            create: (context) => getIt<UserManagementBloc>(),
            child: const UserManagementPage(),
          ),
        ),
        GoRoute(
          path: adminDashboard,
          builder: (context, state) => const AdminDashboardPageReal(),
        ),

        // TODO: Add other routes
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.matchedLocation}')),
      ),
    );
  }
}
