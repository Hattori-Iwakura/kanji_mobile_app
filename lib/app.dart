import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';

class KanjiMasterApp extends StatefulWidget {
  const KanjiMasterApp({super.key});

  @override
  State<KanjiMasterApp> createState() => _KanjiMasterAppState();
}

class _KanjiMasterAppState extends State<KanjiMasterApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Initialize router once with initial auth state
    final authState = context.read<AuthBloc>().state;
    final isAuthenticated = authState is Authenticated;
    _router = AppRouter.createRouter(isAuthenticated: isAuthenticated);

    print('🚀 App initialized with auth state: ${authState.runtimeType}');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('🔄 Auth state changed: ${state.runtimeType}');

        // Navigate based on auth state
        if (state is Authenticated) {
          print('✅ User authenticated - navigating to home');
          _router.go('/');
        } else if (state is Unauthenticated) {
          print('❌ User unauthenticated - navigating to login');
          _router.go('/login');
        }
      },
      child: MaterialApp.router(
        title: 'Kanji Master',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: _router,
      ),
    );
  }
}
