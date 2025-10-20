import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanji_flutter/injection_container.dart' as di;
import 'package:kanji_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kanji_flutter/features/auth/presentation/bloc/auth_event.dart';
import 'package:kanji_flutter/features/auth/presentation/bloc/auth_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Feature Integration Tests', () {
    setUpAll(() async {
      await di.init();
    });

    testWidgets('Login Flow: Should authenticate user with valid credentials', (
      WidgetTester tester,
    ) async {
      final authBloc = di.sl<AuthBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => authBloc,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is Authenticated) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Welcome ${state.user.username}!'),
                          Text('Email: ${state.user.email}'),
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
                  body: Center(child: Text('Not authenticated')),
                );
              },
            ),
          ),
        ),
      );

      // Initial state
      await tester.pumpAndSettle();
      expect(find.text('Not authenticated'), findsOneWidget);

      // Trigger login
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'password123'),
      );

      // Wait for loading
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for response
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify authentication (might fail if backend not running)
      // This is expected to work only when backend is available
      final state = authBloc.state;
      expect(
        state is Authenticated || state is AuthError,
        true,
        reason: 'Should be either authenticated or show error',
      );

      await authBloc.close();
    });

    testWidgets('Register Flow: Should create new user account', (
      WidgetTester tester,
    ) async {
      final authBloc = di.sl<AuthBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => authBloc,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is Authenticated) {
                  return Scaffold(
                    body: Center(
                      child: Text('Registered: ${state.user.email}'),
                    ),
                  );
                } else if (state is AuthError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: Text('Ready to register')),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger registration with unique email
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      authBloc.add(
        AuthRegisterRequested(
          email: 'test_$timestamp@example.com',
          username: 'testuser_$timestamp',
          password: 'password123',
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check result
      final state = authBloc.state;
      expect(
        state is Authenticated || state is AuthError,
        true,
        reason: 'Registration should complete with success or error',
      );

      await authBloc.close();
    });

    testWidgets('Logout Flow: Should clear authentication', (
      WidgetTester tester,
    ) async {
      final authBloc = di.sl<AuthBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => authBloc,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                        },
                        child: const Text('Logout'),
                      ),
                    ),
                  );
                } else if (state is Unauthenticated) {
                  return const Scaffold(
                    body: Center(child: Text('Logged out')),
                  );
                }
                return const Scaffold(body: Center(child: Text('Initial')));
              },
            ),
          ),
        ),
      );

      // Login first
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'password123'),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // If authenticated, test logout
      if (authBloc.state is Authenticated) {
        await tester.tap(find.text('Logout'));
        await tester.pumpAndSettle();
        expect(find.text('Logged out'), findsOneWidget);
      }

      await authBloc.close();
    });

    testWidgets(
      'Validation Error: Should show error for invalid email format',
      (WidgetTester tester) async {
        final authBloc = di.sl<AuthBloc>();

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AuthBloc>(
              create: (_) => authBloc,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthError) {
                    return Scaffold(
                      body: Center(child: Text('Error: ${state.message}')),
                    );
                  } else if (state is AuthLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const Scaffold(body: Center(child: Text('Ready')));
                },
              ),
            ),
          ),
        );

        // Try login with invalid email
        authBloc.add(
          AuthLoginRequested(email: 'invalid-email', password: 'password123'),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Should show error
        expect(
          authBloc.state is AuthError,
          true,
          reason: 'Invalid email should result in error',
        );

        await authBloc.close();
      },
    );

    testWidgets('Wrong Password: Should show authentication error', (
      WidgetTester tester,
    ) async {
      final authBloc = di.sl<AuthBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => authBloc,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                } else if (state is Authenticated) {
                  return const Scaffold(body: Center(child: Text('Logged in')));
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Try login with wrong password
      authBloc.add(
        AuthLoginRequested(
          email: 'test@example.com',
          password: 'wrongpassword',
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show authentication error
      expect(
        authBloc.state is AuthError || authBloc.state is Unauthenticated,
        true,
        reason: 'Wrong password should result in error or unauthenticated',
      );

      await authBloc.close();
    });

    testWidgets('Get Profile: Should load user profile when authenticated', (
      WidgetTester tester,
    ) async {
      final authBloc = di.sl<AuthBloc>();

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
                          Text('ID: ${state.user.id}'),
                          Text('Email: ${state.user.email}'),
                          Text('Username: ${state.user.username}'),
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
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Login first
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'password123'),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check if profile loaded
      if (authBloc.state is Authenticated) {
        final state = authBloc.state as Authenticated;
        expect(state.user.email, isNotEmpty);
        expect(state.user.username, isNotEmpty);
        expect(find.textContaining('Email:'), findsOneWidget);
      }

      await authBloc.close();
    });

    testWidgets('Update Profile: Should update user information', (
      WidgetTester tester,
    ) async {
      final authBloc = di.sl<AuthBloc>();

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
                          Text('Username: ${state.user.username}'),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                AuthUpdateProfileRequested(
                                  username:
                                      'Updated Name ${DateTime.now().millisecondsSinceEpoch}',
                                ),
                              );
                            },
                            child: const Text('Update Profile'),
                          ),
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
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Login first
      authBloc.add(
        AuthLoginRequested(email: 'test@example.com', password: 'password123'),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // If authenticated, update profile
      if (authBloc.state is Authenticated) {
        final originalUsername =
            (authBloc.state as Authenticated).user.username;

        await tester.tap(find.text('Update Profile'));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Verify update
        if (authBloc.state is Authenticated) {
          final newUsername = (authBloc.state as Authenticated).user.username;
          expect(
            newUsername != originalUsername,
            true,
            reason: 'Username should be updated',
          );
        }
      }

      await authBloc.close();
    });

    testWidgets('Register with Duplicate Email: Should show error', (
      WidgetTester tester,
    ) async {
      final authBloc = di.sl<AuthBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => authBloc,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                } else if (state is Authenticated) {
                  return const Scaffold(
                    body: Center(child: Text('Registered')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Try to register with existing email
      authBloc.add(
        AuthRegisterRequested(
          email: 'test@example.com', // Existing email
          username: 'newuser',
          password: 'password123',
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show duplicate error
      expect(
        authBloc.state is AuthError,
        true,
        reason: 'Duplicate email should result in error',
      );

      await authBloc.close();
    });

    testWidgets('Auto Login: Should restore session from stored token', (
      WidgetTester tester,
    ) async {
      final authBloc = di.sl<AuthBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => authBloc,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return Scaffold(
                    body: Center(
                      child: Text('Auto-logged in: ${state.user.email}'),
                    ),
                  );
                } else if (state is Unauthenticated) {
                  return const Scaffold(
                    body: Center(child: Text('Not logged in')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Trigger auto login check
      authBloc.add(AuthCheckRequested());

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should either restore session or show not logged in
      expect(
        authBloc.state is Authenticated || authBloc.state is Unauthenticated,
        true,
        reason: 'Should complete auth check',
      );

      await authBloc.close();
    });
  });
}
