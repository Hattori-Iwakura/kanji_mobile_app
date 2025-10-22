import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/core/errors/failures.dart';
import 'package:kanji_mobile_v1/features/auth/domain/entities/auth_result.dart';
import 'package:kanji_mobile_v1/features/auth/domain/entities/user.dart';
import 'package:kanji_mobile_v1/features/auth/domain/usecases/login_usecase.dart';
import 'package:kanji_mobile_v1/features/auth/domain/usecases/register_usecase.dart';
import 'package:kanji_mobile_v1/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kanji_mobile_v1/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:kanji_mobile_v1/features/auth/domain/repositories/auth_repository.dart';
import 'package:kanji_mobile_v1/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kanji_mobile_v1/features/auth/presentation/bloc/auth_event.dart';
import 'package:kanji_mobile_v1/features/auth/presentation/bloc/auth_state.dart';

// Mock UseCases and Repository
class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetProfileUseCase mockGetProfileUseCase;
  late MockAuthRepository mockAuthRepository;

  // Test data
  final testUser = User(
    id: 1,
    account: 'testuser',
    email: 'test@example.com',
    profileImage: null,
    isFirstLogin: false,
    createdAt: DateTime(2024, 1, 1),
    role: 'USER',
  );

  final testAuthResult = AuthResult(
    user: testUser,
    accessToken: 'mock_jwt_token_12345',
    refreshToken: 'mock_refresh_token_67890',
  );

  const testAccount = 'testuser';
  const testEmail = 'test@example.com';
  const testPassword = 'password123';

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetProfileUseCase = MockGetProfileUseCase();
    mockAuthRepository = MockAuthRepository();

    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
      getProfileUseCase: mockGetProfileUseCase,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state should be AuthInitial', () {
      expect(authBloc.state, equals(const AuthInitial()));
    });

    group('LoginEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when login is successful',
        build: () {
          when(
            () => mockLoginUseCase(
              account: any(named: 'account'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => Right(testAuthResult));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const LoginEvent(account: testAccount, password: testPassword),
        ),
        expect: () => [const AuthLoading(), Authenticated(user: testUser)],
        verify: (_) {
          verify(
            () =>
                mockLoginUseCase(account: testAccount, password: testPassword),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when login fails with invalid credentials',
        build: () {
          when(
            () => mockLoginUseCase(
              account: any(named: 'account'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => Left(ServerFailure('Invalid credentials')));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const LoginEvent(account: testAccount, password: testPassword),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Invalid credentials'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when network is down',
        build: () {
          when(
            () => mockLoginUseCase(
              account: any(named: 'account'),
              password: any(named: 'password'),
            ),
          ).thenAnswer(
            (_) async => Left(NetworkFailure('No internet connection')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const LoginEvent(account: testAccount, password: testPassword),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'No internet connection'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when server error occurs',
        build: () {
          when(
            () => mockLoginUseCase(
              account: any(named: 'account'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => Left(ServerFailure('Server error')));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const LoginEvent(account: testAccount, password: testPassword),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Server error'),
        ],
      );
    });

    group('RegisterEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when registration is successful',
        build: () {
          when(
            () => mockRegisterUseCase(
              account: any(named: 'account'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => Right(testAuthResult));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const RegisterEvent(
            account: testAccount,
            email: testEmail,
            password: testPassword,
          ),
        ),
        expect: () => [const AuthLoading(), Authenticated(user: testUser)],
        verify: (_) {
          verify(
            () => mockRegisterUseCase(
              account: testAccount,
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when email already exists',
        build: () {
          when(
            () => mockRegisterUseCase(
              account: any(named: 'account'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer(
            (_) async => Left(ServerFailure('Email already exists')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const RegisterEvent(
            account: testAccount,
            email: testEmail,
            password: testPassword,
          ),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Email already exists'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when validation fails',
        build: () {
          when(
            () => mockRegisterUseCase(
              account: any(named: 'account'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer(
            (_) async => Left(ValidationFailure('Invalid email format')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const RegisterEvent(
            account: testAccount,
            email: 'invalid-email',
            password: testPassword,
          ),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Invalid email format'),
        ],
      );
    });

    group('LogoutEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when logout is successful',
        build: () {
          when(
            () => mockLogoutUseCase(),
          ).thenAnswer((_) async => const Right(null));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LogoutEvent()),
        expect: () => [const AuthLoading(), const Unauthenticated()],
        verify: (_) {
          verify(() => mockLogoutUseCase()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when logout fails',
        build: () {
          when(
            () => mockLogoutUseCase(),
          ).thenAnswer((_) async => Left(CacheFailure('Storage error')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LogoutEvent()),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Storage error'),
        ],
      );
    });

    group('CheckAuthStatusEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Authenticated] when valid token exists',
        build: () {
          when(
            () => mockAuthRepository.isAuthenticated(),
          ).thenAnswer((_) async => true);
          when(
            () => mockAuthRepository.getCachedUser(),
          ).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(const CheckAuthStatusEvent()),
        expect: () => [Authenticated(user: testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [Unauthenticated] when no token found',
        build: () {
          when(
            () => mockAuthRepository.isAuthenticated(),
          ).thenAnswer((_) async => false);
          return authBloc;
        },
        act: (bloc) => bloc.add(const CheckAuthStatusEvent()),
        expect: () => [const Unauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [Unauthenticated] when token is expired',
        build: () {
          when(
            () => mockAuthRepository.isAuthenticated(),
          ).thenAnswer((_) async => false);
          return authBloc;
        },
        act: (bloc) => bloc.add(const CheckAuthStatusEvent()),
        expect: () => [const Unauthenticated()],
      );
    });
  });
}
