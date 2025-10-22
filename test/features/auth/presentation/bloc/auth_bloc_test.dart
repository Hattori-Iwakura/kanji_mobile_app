import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/errors/failures.dart';
import 'package:kanji_mobile_v1/features/auth/domain/entities/auth_result.dart';
import 'package:kanji_mobile_v1/features/auth/domain/entities/user.dart';
import 'package:kanji_mobile_v1/features/auth/domain/repositories/auth_repository.dart';
import 'package:kanji_mobile_v1/features/auth/domain/usecases/login_usecase.dart';
import 'package:kanji_mobile_v1/features/auth/domain/usecases/register_usecase.dart';
import 'package:kanji_mobile_v1/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kanji_mobile_v1/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:kanji_mobile_v1/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kanji_mobile_v1/features/auth/presentation/bloc/auth_event.dart';
import 'package:kanji_mobile_v1/features/auth/presentation/bloc/auth_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_bloc_test.mocks.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([AuthRepository])
void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late LogoutUseCase logoutUseCase;
  late GetProfileUseCase getProfileUseCase;

  // Test data
  final testUser = User(
    id: 1,
    account: 'testuser',
    email: 'test@example.com',
    profileImage: null,
    isFirstLogin: false,
    createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
    role: 'USER',
  );

  final testAuthResult = AuthResult(
    user: testUser,
    accessToken: 'test_access_token',
    refreshToken: 'test_refresh_token',
    sessionId: 'test_session_id',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();

    // Create real use cases with mocked repository
    loginUseCase = LoginUseCase(mockAuthRepository);
    registerUseCase = RegisterUseCase(mockAuthRepository);
    logoutUseCase = LogoutUseCase(mockAuthRepository);
    getProfileUseCase = GetProfileUseCase(mockAuthRepository);

    authBloc = AuthBloc(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      logoutUseCase: logoutUseCase,
      getProfileUseCase: getProfileUseCase,
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
      const testAccount = 'testuser';
      const testPassword = 'Test@123456';

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, LoginSuccess] when login is successful',
        build: () {
          when(
            mockAuthRepository.login(
              account: anyNamed('account'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => Right(testAuthResult));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const LoginEvent(account: testAccount, password: testPassword),
        ),
        expect: () => [const AuthLoading(), LoginSuccess(user: testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when login fails with ServerFailure',
        build: () {
          when(
            mockAuthRepository.login(
              account: anyNamed('account'),
              password: anyNamed('password'),
            ),
          ).thenAnswer(
            (_) async => const Left(ServerFailure('Invalid credentials')),
          );
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
        'emits [AuthLoading, AuthError] when login fails with NetworkFailure',
        build: () {
          when(
            mockAuthRepository.login(
              account: anyNamed('account'),
              password: anyNamed('password'),
            ),
          ).thenAnswer(
            (_) async => const Left(NetworkFailure('No internet connection')),
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
    });

    group('RegisterEvent', () {
      const testAccount = 'newuser';
      const testEmail = 'newuser@example.com';
      const testPassword = 'NewPass@2025';

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, RegisterSuccess] when registration is successful',
        build: () {
          when(
            mockAuthRepository.register(
              account: anyNamed('account'),
              email: anyNamed('email'),
              password: anyNamed('password'),
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
        expect: () => [const AuthLoading(), RegisterSuccess(user: testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when registration fails (duplicate account)',
        build: () {
          when(
            mockAuthRepository.register(
              account: anyNamed('account'),
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer(
            (_) async => const Left(ServerFailure('Account already exists')),
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
          const AuthError(message: 'Account already exists'),
        ],
      );
    });

    group('LogoutEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, LogoutSuccess] when logout is successful',
        build: () {
          when(
            mockAuthRepository.logout(),
          ).thenAnswer((_) async => const Right(null));
          return authBloc;
        },
        act: (bloc) => bloc.add(LogoutEvent()),
        expect: () => [const AuthLoading(), const LogoutSuccess()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when logout fails',
        build: () {
          when(
            mockAuthRepository.logout(),
          ).thenAnswer((_) async => const Left(ServerFailure('Logout failed')));
          return authBloc;
        },
        act: (bloc) => bloc.add(LogoutEvent()),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Logout failed'),
        ],
      );
    });

    group('GetProfileEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, ProfileLoaded] when profile fetch is successful',
        build: () {
          when(
            mockAuthRepository.getProfile(),
          ).thenAnswer((_) async => Right(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(GetProfileEvent()),
        expect: () => [const AuthLoading(), ProfileLoaded(user: testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when profile fetch fails (unauthorized)',
        build: () {
          when(
            mockAuthRepository.getProfile(),
          ).thenAnswer((_) async => const Left(AuthFailure('Unauthorized')));
          return authBloc;
        },
        act: (bloc) => bloc.add(GetProfileEvent()),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Unauthorized'),
        ],
      );
    });

    group('CheckAuthStatusEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Authenticated] when user is authenticated and cached user exists',
        build: () {
          when(
            mockAuthRepository.isAuthenticated(),
          ).thenAnswer((_) async => true);
          when(
            mockAuthRepository.getCachedUser(),
          ).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        expect: () => [Authenticated(user: testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [Unauthenticated] when user is not authenticated',
        build: () {
          when(
            mockAuthRepository.isAuthenticated(),
          ).thenAnswer((_) async => false);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        expect: () => [const Unauthenticated()],
      );
    });
  });
}
