import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/dashboard/presentation/pages/home_page.dart';

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

  static GoRouter createRouter({required bool isAuthenticated}) {
    return GoRouter(
      initialLocation: isAuthenticated ? home : login,
      redirect: (BuildContext context, GoRouterState state) {
        final isLoginRoute =
            state.matchedLocation == login ||
            state.matchedLocation == register ||
            state.matchedLocation == forgotPassword;

        // Redirect to login if not authenticated and trying to access protected route
        if (!isAuthenticated && !isLoginRoute) {
          return login;
        }

        // Redirect to home if authenticated and trying to access login routes
        if (isAuthenticated && isLoginRoute) {
          return home;
        }

        return null;
      },
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

        // TODO: Add other routes
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.matchedLocation}')),
      ),
    );
  }
}
