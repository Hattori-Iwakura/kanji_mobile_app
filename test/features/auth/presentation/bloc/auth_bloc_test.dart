import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kanji_flutter/features/auth/domain/entities/auth_exception.dart';
import 'package:kanji_flutter/features/auth/domain/entities/user_entity.dart';
import 'package:kanji_flutter/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:kanji_flutter/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:kanji_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:kanji_flutter/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kanji_flutter/features/auth/domain/usecases/register_usecase.dart';
import 'package:kanji_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kanji_flutter/features/auth/presentation/bloc/auth_event.dart';
import 'package:kanji_flutter/features/auth/presentation/bloc/auth_state.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([
  LoginUseCase,
  RegisterUseCase,
  GetProfileUseCase,
  LogoutUseCase,
  CheckAuthUseCase,
])
void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockGetProfileUseCase mockGetProfileUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockCheckAuthUseCase mockCheckAuthUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockGetProfileUseCase = MockGetProfileUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockCheckAuthUseCase = MockCheckAuthUseCase();

    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      getProfileUseCase: mockGetProfileUseCase,
      logoutUseCase: mockLogoutUseCase,
      checkAuthUseCase: mockCheckAuthUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  const tEmail = 'test@example.com';
  const tUsername = 'testuser';
  const tPassword = 'Test@123456';
  final tUser = UserEntity(
    id: 1,
    email: tEmail,
    username: tUsername,
    role: 'user',
    createdAt: DateTime(2024, 1, 1),
  );

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, AuthInitial());
    });

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when check auth succeeds and user is logged in',
        build: () {
          when(mockCheckAuthUseCase()).thenAnswer((_) async => true);
          when(mockGetProfileUseCase()).thenAnswer((_) async => tUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthLoading(), Authenticated(tUser)],
        verify: (_) {
          verify(mockCheckAuthUseCase()).called(1);
          verify(mockGetProfileUseCase()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when check auth succeeds but user is not logged in',
        build: () {
          when(mockCheckAuthUseCase()).thenAnswer((_) async => false);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthLoading(), Unauthenticated()],
        verify: (_) {
          verify(mockCheckAuthUseCase()).called(1);
          verifyNever(mockGetProfileUseCase());
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when check auth throws AuthException',
        build: () {
          when(
            mockCheckAuthUseCase(),
          ).thenThrow(AuthException('Token expired'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthLoading(), Unauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when check auth throws generic exception',
        build: () {
          when(mockCheckAuthUseCase()).thenThrow(Exception('Network error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthLoading(), Unauthenticated()],
      );
    });

    group('AuthLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when login succeeds',
        build: () {
          when(
            mockLoginUseCase(email: tEmail, password: tPassword),
          ).thenAnswer((_) async => tUser);
          return authBloc;
        },
        act: (bloc) =>
            bloc.add(AuthLoginRequested(email: tEmail, password: tPassword)),
        expect: () => [AuthLoading(), Authenticated(tUser)],
        verify: (_) {
          verify(
            mockLoginUseCase(email: tEmail, password: tPassword),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when login fails with invalid credentials',
        build: () {
          when(
            mockLoginUseCase(email: tEmail, password: tPassword),
          ).thenThrow(AuthException('Invalid credentials'));
          return authBloc;
        },
        act: (bloc) =>
            bloc.add(AuthLoginRequested(email: tEmail, password: tPassword)),
        expect: () => [AuthLoading(), AuthError('Invalid credentials')],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when login fails with network error',
        build: () {
          when(
            mockLoginUseCase(email: tEmail, password: tPassword),
          ).thenThrow(Exception('Network error'));
          return authBloc;
        },
        act: (bloc) =>
            bloc.add(AuthLoginRequested(email: tEmail, password: tPassword)),
        expect: () => [
          AuthLoading(),
          AuthError('An unexpected error occurred'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when login fails with empty credentials',
        build: () {
          when(
            mockLoginUseCase(email: '', password: ''),
          ).thenThrow(AuthException('Email and password are required'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLoginRequested(email: '', password: '')),
        expect: () => [
          AuthLoading(),
          AuthError('Email and password are required'),
        ],
      );
    });

    group('AuthRegisterRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when registration succeeds',
        build: () {
          when(
            mockRegisterUseCase(
              email: tEmail,
              username: tUsername,
              password: tPassword,
            ),
          ).thenAnswer((_) async => tUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthRegisterRequested(
            email: tEmail,
            username: tUsername,
            password: tPassword,
          ),
        ),
        expect: () => [AuthLoading(), Authenticated(tUser)],
        verify: (_) {
          verify(
            mockRegisterUseCase(
              email: tEmail,
              username: tUsername,
              password: tPassword,
            ),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when registration fails with existing email',
        build: () {
          when(
            mockRegisterUseCase(
              email: tEmail,
              username: tUsername,
              password: tPassword,
            ),
          ).thenThrow(AuthException('Email already exists'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthRegisterRequested(
            email: tEmail,
            username: tUsername,
            password: tPassword,
          ),
        ),
        expect: () => [AuthLoading(), AuthError('Email already exists')],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when registration fails with weak password',
        build: () {
          when(
            mockRegisterUseCase(
              email: tEmail,
              username: tUsername,
              password: '123',
            ),
          ).thenThrow(AuthException('Password too weak'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthRegisterRequested(
            email: tEmail,
            username: tUsername,
            password: '123',
          ),
        ),
        expect: () => [AuthLoading(), AuthError('Password too weak')],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when registration fails with invalid email format',
        build: () {
          when(
            mockRegisterUseCase(
              email: 'invalid-email',
              username: tUsername,
              password: tPassword,
            ),
          ).thenThrow(AuthException('Invalid email format'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthRegisterRequested(
            email: 'invalid-email',
            username: tUsername,
            password: tPassword,
          ),
        ),
        expect: () => [AuthLoading(), AuthError('Invalid email format')],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when registration fails with generic error',
        build: () {
          when(
            mockRegisterUseCase(
              email: tEmail,
              username: tUsername,
              password: tPassword,
            ),
          ).thenThrow(Exception('Server error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthRegisterRequested(
            email: tEmail,
            username: tUsername,
            password: tPassword,
          ),
        ),
        expect: () => [
          AuthLoading(),
          AuthError('An unexpected error occurred'),
        ],
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Unauthenticated] when logout succeeds',
        build: () {
          when(mockLogoutUseCase()).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [Unauthenticated()],
        verify: (_) {
          verify(mockLogoutUseCase()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthError] when logout fails with AuthException',
        build: () {
          when(
            mockLogoutUseCase(),
          ).thenThrow(AuthException('Failed to clear token'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [AuthError('Failed to clear token')],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthError] when logout fails with generic exception',
        build: () {
          when(mockLogoutUseCase()).thenThrow(Exception('Unknown error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [AuthError('Logout failed')],
      );
    });

    group('AuthProfileRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when get profile succeeds',
        build: () {
          when(mockGetProfileUseCase()).thenAnswer((_) async => tUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthProfileRequested()),
        expect: () => [AuthLoading(), Authenticated(tUser)],
        verify: (_) {
          verify(mockGetProfileUseCase()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when get profile fails with unauthorized',
        build: () {
          when(
            mockGetProfileUseCase(),
          ).thenThrow(AuthException('Unauthorized'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthProfileRequested()),
        expect: () => [AuthLoading(), AuthError('Unauthorized')],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when get profile fails with generic error',
        build: () {
          when(mockGetProfileUseCase()).thenThrow(Exception('Network error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthProfileRequested()),
        expect: () => [AuthLoading(), AuthError('Failed to load profile')],
      );
    });

    group('Multiple Events Sequence', () {
      blocTest<AuthBloc, AuthState>(
        'handles login followed by logout correctly',
        build: () {
          when(
            mockLoginUseCase(email: tEmail, password: tPassword),
          ).thenAnswer((_) async => tUser);
          when(mockLogoutUseCase()).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) {
          bloc.add(AuthLoginRequested(email: tEmail, password: tPassword));
          return Future.delayed(const Duration(milliseconds: 100), () {
            bloc.add(AuthLogoutRequested());
          });
        },
        expect: () => [AuthLoading(), Authenticated(tUser), Unauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'handles failed login followed by successful login',
        build: () {
          when(
            mockLoginUseCase(email: tEmail, password: 'wrong'),
          ).thenThrow(AuthException('Invalid credentials'));
          when(
            mockLoginUseCase(email: tEmail, password: tPassword),
          ).thenAnswer((_) async => tUser);
          return authBloc;
        },
        act: (bloc) {
          bloc.add(AuthLoginRequested(email: tEmail, password: 'wrong'));
          return Future.delayed(const Duration(milliseconds: 100), () {
            bloc.add(AuthLoginRequested(email: tEmail, password: tPassword));
          });
        },
        expect: () => [
          AuthLoading(),
          AuthError('Invalid credentials'),
          AuthLoading(),
          Authenticated(tUser),
        ],
      );
    });
  });
}
