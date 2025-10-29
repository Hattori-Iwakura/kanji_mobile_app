import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/auth/presentation/pages/two_factor_verify_page.dart';
import 'auth/splash_page.dart';
import 'main_navigation_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        print('=== AUTH WRAPPER BUILDER ===');
        print('State: ${state.runtimeType}');

        if (state is AuthLoading || state is AuthInitial) {
          // Show splash screen while checking auth status
          return const SplashPage();
        } else if (state is Authenticated) {
          // User is logged in, show main navigation
          return const MainNavigationPage();
        } else if (state is TwoFactorRequired) {
          print('=== AUTH WRAPPER - Showing TwoFactorVerifyPage ===');
          // 2FA required, show 2FA verification page
          return TwoFactorVerifyPage(
            email: state.email,
            password: state.password,
          );
        } else {
          // User is not logged in, show login page
          return const LoginPage();
        }
      },
    );
  }
}
