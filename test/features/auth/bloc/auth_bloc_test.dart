import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kanji_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:kanji_flutter/features/auth/bloc/auth_event.dart';
import 'package:kanji_flutter/features/auth/bloc/auth_state.dart';
import 'package:kanji_flutter/features/auth/services/auth_service.dart';
import 'package:kanji_flutter/features/auth/models/user.dart';
import 'package:kanji_flutter/features/auth/models/auth_exception.dart';

// Generate mocks
@GenerateMocks([AuthService])
import 'auth_bloc_test.mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    authBloc = AuthBloc(authService: mockAuthService);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc Tests', () {
    final testUser = User(
      id: 1,
      email: 'test@example.com',
      username: 'testuser',
      avatarUrl: null,
      role: 'USER',
      createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
    );

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, Authenticated] when user is logged in',
        build: () {
          when(
            mockAuthService.initAuth(),
          ).thenAnswer((_) async => Future.value());
          when(mockAuthService.isLoggedIn()).thenAnswer((_) async => true);
          when(mockAuthService.getProfile()).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthLoading(), Authenticated(testUser)],
        verify: (_) {
          verify(mockAuthService.initAuth()).called(1);
          verify(mockAuthService.isLoggedIn()).called(1);
          verify(mockAuthService.getProfile()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, Unauthenticated] when user is not logged in',
        build: () {
          when(
            mockAuthService.initAuth(),
          ).thenAnswer((_) async => Future.value());
          when(mockAuthService.isLoggedIn()).thenAnswer((_) async => false);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthLoading(), Unauthenticated()],
        verify: (_) {
          verify(mockAuthService.initAuth()).called(1);
          verify(mockAuthService.isLoggedIn()).called(1);
          verifyNever(mockAuthService.getProfile());
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when check fails',
        build: () {
          when(
            mockAuthService.initAuth(),
          ).thenAnswer((_) async => Future.value());
          when(mockAuthService.isLoggedIn()).thenAnswer((_) async => true);
          when(
            mockAuthService.getProfile(),
          ).thenThrow(AuthException('Failed to get profile'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthLoading(), Unauthenticated()],
      );
    });

    group('AuthLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, Authenticated] when login succeeds',
        build: () {
          when(
            mockAuthService.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthLoginRequested(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [AuthLoading(), Authenticated(testUser)],
        verify: (_) {
          verify(
            mockAuthService.login(
              email: 'test@example.com',
              password: 'password123',
            ),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when login fails',
        build: () {
          when(
            mockAuthService.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(AuthException('Invalid credentials'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthLoginRequested(
            email: 'test@example.com',
            password: 'wrong-password',
          ),
        ),
        expect: () => [AuthLoading(), AuthError('Invalid credentials')],
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when network error occurs',
        build: () {
          when(
            mockAuthService.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(AuthException('Network error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthLoginRequested(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [AuthLoading(), AuthError('Network error')],
      );
    });

    group('AuthRegisterRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, Authenticated] when registration succeeds',
        build: () {
          when(
            mockAuthService.register(
              email: anyNamed('email'),
              username: anyNamed('username'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthRegisterRequested(
            email: 'test@example.com',
            username: 'testuser',
            password: 'password123',
          ),
        ),
        expect: () => [AuthLoading(), Authenticated(testUser)],
        verify: (_) {
          verify(
            mockAuthService.register(
              email: 'test@example.com',
              username: 'testuser',
              password: 'password123',
            ),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when registration fails',
        build: () {
          when(
            mockAuthService.register(
              email: anyNamed('email'),
              username: anyNamed('username'),
              password: anyNamed('password'),
            ),
          ).thenThrow(AuthException('Email already exists'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthRegisterRequested(
            email: 'test@example.com',
            username: 'testuser',
            password: 'password123',
          ),
        ),
        expect: () => [AuthLoading(), AuthError('Email already exists')],
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [Unauthenticated] when logout succeeds',
        build: () {
          when(
            mockAuthService.logout(),
          ).thenAnswer((_) async => Future.value());
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [Unauthenticated()],
        verify: (_) {
          verify(mockAuthService.logout()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthError] when logout fails',
        build: () {
          when(
            mockAuthService.logout(),
          ).thenThrow(AuthException('Logout failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [AuthError('Logout failed')],
      );
    });

    group('AuthProfileRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, Authenticated] when profile fetch succeeds',
        build: () {
          when(mockAuthService.getProfile()).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthProfileRequested()),
        expect: () => [AuthLoading(), Authenticated(testUser)],
        verify: (_) {
          verify(mockAuthService.getProfile()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when profile fetch fails',
        build: () {
          when(
            mockAuthService.getProfile(),
          ).thenThrow(AuthException('Unauthorized'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthProfileRequested()),
        expect: () => [AuthLoading(), AuthError('Unauthorized')],
      );
    });

    group('Integration Tests', () {
      blocTest<AuthBloc, AuthState>(
        'should handle login -> logout flow',
        build: () {
          when(
            mockAuthService.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => testUser);
          when(
            mockAuthService.logout(),
          ).thenAnswer((_) async => Future.value());
          return authBloc;
        },
        act: (bloc) async {
          bloc.add(
            AuthLoginRequested(
              email: 'test@example.com',
              password: 'password123',
            ),
          );
          await Future.delayed(Duration(milliseconds: 100));
          bloc.add(AuthLogoutRequested());
        },
        expect: () => [
          AuthLoading(),
          Authenticated(testUser),
          Unauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should handle check -> login flow when initially unauthenticated',
        build: () {
          when(
            mockAuthService.initAuth(),
          ).thenAnswer((_) async => Future.value());
          when(mockAuthService.isLoggedIn()).thenAnswer((_) async => false);
          when(
            mockAuthService.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) async {
          bloc.add(AuthCheckRequested());
          await Future.delayed(Duration(milliseconds: 100));
          bloc.add(
            AuthLoginRequested(
              email: 'test@example.com',
              password: 'password123',
            ),
          );
        },
        expect: () => [
          AuthLoading(),
          Unauthenticated(),
          AuthLoading(),
          Authenticated(testUser),
        ],
      );
    });

    group('Error Handling', () {
      blocTest<AuthBloc, AuthState>(
        'should handle generic exceptions gracefully',
        build: () {
          when(
            mockAuthService.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(Exception('Unexpected error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthLoginRequested(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [
          AuthLoading(),
          AuthError('An unexpected error occurred'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should preserve error messages from AuthException',
        build: () {
          const errorMessage = 'Custom error message from backend';
          when(
            mockAuthService.register(
              email: anyNamed('email'),
              username: anyNamed('username'),
              password: anyNamed('password'),
            ),
          ).thenThrow(AuthException(errorMessage));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthRegisterRequested(
            email: 'test@example.com',
            username: 'testuser',
            password: 'password123',
          ),
        ),
        expect: () => [
          AuthLoading(),
          AuthError('Custom error message from backend'),
        ],
      );
    });
  });
}
