import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanji_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kanji_flutter/features/auth/presentation/bloc/auth_event.dart';
import 'package:kanji_flutter/features/auth/presentation/bloc/auth_state.dart';
import 'package:kanji_flutter/injection_container.dart' as di;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth BLoC Integration Tests', () {
    late AuthBloc authBloc;

    setUpAll(() async {
      await di.init();
    });

    setUp(() {
      authBloc = di.sl<AuthBloc>();
    });

    tearDown(() async {
      await authBloc.close();
    });

    testWidgets('Login flow: Initial → Loading → Authenticated', (
      WidgetTester tester,
    ) async {
      // Create a list to track state changes
      final List<AuthState> states = [];

      // Build a simple widget that listens to BLoC
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => authBloc,
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                states.add(state);
              },
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthInitial) {
                    return const Scaffold(body: Center(child: Text('Initial')));
                  } else if (state is AuthLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is Authenticated) {
                    return Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Welcome ${state.user.email}'),
                            Text('Role: ${state.user.role}'),
                          ],
                        ),
                      ),
                    );
                  } else if (state is AuthError) {
                    return Scaffold(
                      body: Center(child: Text('Error: ${state.message}')),
                    );
                  }
                  return const Scaffold(
                    body: Center(child: Text('Unauthenticated')),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Wait for initial render
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Initial'), findsOneWidget);
      expect(authBloc.state, isA<AuthInitial>());

      // Trigger login event
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'Test@123456'),
      );

      // Wait a bit for loading state
      await tester.pump(const Duration(milliseconds: 100));

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(authBloc.state, isA<AuthLoading>());

      // Wait for the API call to complete (max 5 seconds)
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify authenticated state
      expect(authBloc.state, isA<Authenticated>());
      final authenticatedState = authBloc.state as Authenticated;
      expect(authenticatedState.user.email, 'test@example.com');
      expect(authenticatedState.user.role, 'USER');

      // Verify UI shows welcome message
      expect(find.text('Welcome test@example.com'), findsOneWidget);
      expect(find.text('Role: USER'), findsOneWidget);

      // Verify state transitions
      expect(states.length, greaterThanOrEqualTo(2));
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<Authenticated>());
    });

    testWidgets('Login with wrong credentials: Initial → Loading → Error', (
      WidgetTester tester,
    ) async {
      final List<AuthState> states = [];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => authBloc,
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                states.add(state);
              },
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is AuthError) {
                    return Scaffold(
                      body: Center(child: Text('Error: ${state.message}')),
                    );
                  }
                  return const Scaffold(body: Center(child: Text('Ready')));
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger login with wrong password
      authBloc.add(
        AuthLoginRequested(
          email: 'test@example.com',
          password: 'WrongPassword123!',
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show error
      expect(authBloc.state, isA<AuthError>());
      expect(find.textContaining('Error:'), findsOneWidget);

      // Verify state transitions
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthError>());
    });

    testWidgets('Login → Logout flow', (WidgetTester tester) async {
      final List<AuthState> states = [];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => authBloc,
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                states.add(state);
              },
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is Authenticated) {
                    return Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Logged in: ${state.user.email}'),
                            ElevatedButton(
                              key: const Key('logout_button'),
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                  AuthLogoutRequested(),
                                );
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is Unauthenticated) {
                    return const Scaffold(
                      body: Center(child: Text('Logged out')),
                    );
                  } else if (state is AuthLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const Scaffold(body: Center(child: Text('Initial')));
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step 1: Login
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'Test@123456'),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Logged in: test@example.com'), findsOneWidget);
      expect(authBloc.state, isA<Authenticated>());

      // Clear states to focus on logout
      states.clear();

      // Step 2: Tap logout button
      await tester.tap(find.byKey(const Key('logout_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should be logged out
      expect(find.text('Logged out'), findsOneWidget);
      expect(authBloc.state, isA<Unauthenticated>());

      // Verify logout triggered state change
      expect(states.last, isA<Unauthenticated>());
    });

    testWidgets('Check auth status when logged in', (
      WidgetTester tester,
    ) async {
      // First, login to store token
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'Test@123456'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => authBloc,
            child: const Scaffold(body: Center(child: Text('Test'))),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(authBloc.state, isA<Authenticated>());

      // Create new BLoC instance (simulating app restart)
      final newAuthBloc = di.sl<AuthBloc>();
      final List<AuthState> states = [];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => newAuthBloc,
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                states.add(state);
              },
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is Authenticated) {
                    return Scaffold(
                      body: Center(child: Text('User: ${state.user.email}')),
                    );
                  } else if (state is AuthLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const Scaffold(
                    body: Center(child: Text('Not authenticated')),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check auth status
      newAuthBloc.add(AuthCheckRequested());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should retrieve user from stored token
      expect(newAuthBloc.state, isA<Authenticated>());
      expect(find.text('User: test@example.com'), findsOneWidget);

      // Verify state transitions
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<Authenticated>());

      await newAuthBloc.close();
    });

    testWidgets('Profile fetch after login', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => authBloc,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Email: ${state.user.email}'),
                          Text('ID: ${state.user.id}'),
                          ElevatedButton(
                            key: const Key('refresh_profile'),
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                AuthProfileRequested(),
                              );
                            },
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is AuthLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return const Scaffold(
                  body: Center(child: Text('Not authenticated')),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Login first
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'Test@123456'),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text('Email: test@example.com'), findsOneWidget);

      // Tap refresh profile
      await tester.tap(find.byKey(const Key('refresh_profile')));

      // Wait for profile refresh (no need to check loading state, it's too fast)
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should still be authenticated with same user
      expect(authBloc.state, isA<Authenticated>());
      expect(find.text('Email: test@example.com'), findsOneWidget);
    });

    test('Admin login returns correct role', () async {
      // Login as admin
      authBloc.add(
        AuthLoginRequested(
          email: 'admin@example.com',
          password: 'Admin@123456',
        ),
      );

      // Wait for state changes
      await Future.delayed(const Duration(seconds: 3));

      // Verify admin role
      expect(authBloc.state, isA<Authenticated>());
      final state = authBloc.state as Authenticated;
      expect(state.user.email, 'admin@example.com');
      expect(state.user.role, 'ADMIN');
    });

    test('Concurrent login attempts handled correctly', () async {
      // Trigger multiple login events rapidly
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'Test@123456'),
      );

      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'Test@123456'),
      );

      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'Test@123456'),
      );

      // Wait for completion
      await Future.delayed(const Duration(seconds: 5));

      // Should end up authenticated (BLoC handles event queue)
      expect(authBloc.state, isA<Authenticated>());
    });
  });
}
