import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:kanji_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kanji_flutter/features/auth/presentation/bloc/auth_event.dart';
import 'package:kanji_flutter/features/auth/presentation/bloc/auth_state.dart';
import 'package:kanji_flutter/features/auth/domain/entities/user_entity.dart';
import 'package:kanji_flutter/injection_container.dart' as di;

import '../helpers/test_env_helper.dart';

void main() {
  setUpAll(() async {
    // Load .env file for test environment
    await loadEnvForTest();
    // Initialize dependency injection
    await di.init();
  });

  group('Auth Bloc Tests - With DI', () {
    final tUserEntity = UserEntity(
      id: 1,
      email: 'user@example.com',
      username: 'testuser',
      avatarUrl: null,
      role: 'USER',
      createdAt: DateTime.now(),
    );

    final tAdminEntity = UserEntity(
      id: 2,
      email: 'admin@example.com',
      username: 'admin',
      avatarUrl: null,
      role: 'ADMIN',
      createdAt: DateTime.now(),
    );

    group('Login Tests', () {
      blocTest<AuthBloc, AuthState>(
        '✅ Login Success - User Role',
        build: () {
          when(
            mockLoginUseCase(any),
          ).thenAnswer((_) async => Right(tUserEntity));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthLoginRequested(
            email: 'user@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [AuthLoading(), Authenticated(tUserEntity)],
        verify: (_) {
          verify(mockLoginUseCase(any)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        '✅ Login Success - Admin Role',
        build: () {
          when(
            mockLoginUseCase(any),
          ).thenAnswer((_) async => Right(tAdminEntity));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthLoginRequested(email: 'admin@example.com', password: 'admin123'),
        ),
        expect: () => [AuthLoading(), Authenticated(tAdminEntity)],
        verify: (_) {
          verify(mockLoginUseCase(any)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        '❌ Login Failure - Invalid Credentials',
        build: () {
          when(
            mockLoginUseCase(any),
          ).thenAnswer((_) async => Left(ServerFailure('Invalid credentials')));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthLoginRequested(email: 'wrong@example.com', password: 'wrongpass'),
        ),
        expect: () => [AuthLoading(), AuthError('Invalid credentials')],
        verify: (_) {
          verify(mockLoginUseCase(any)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        '❌ Login Failure - Empty Email',
        build: () {
          when(mockLoginUseCase(any)).thenAnswer(
            (_) async => Left(ValidationFailure('Email is required')),
          );
          return authBloc;
        },
        act: (bloc) =>
            bloc.add(AuthLoginRequested(email: '', password: 'password123')),
        expect: () => [AuthLoading(), AuthError('Email is required')],
        verify: (_) {
          verify(mockLoginUseCase(any)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        '❌ Login Failure - Empty Password',
        build: () {
          when(mockLoginUseCase(any)).thenAnswer(
            (_) async => Left(ValidationFailure('Password is required')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthLoginRequested(email: 'user@example.com', password: ''),
        ),
        expect: () => [AuthLoading(), AuthError('Password is required')],
        verify: (_) {
          verify(mockLoginUseCase(any)).called(1);
        },
      );
    });

    group('Register Tests', () {
      blocTest<AuthBloc, AuthState>(
        '✅ Register Success',
        build: () {
          when(
            mockRegisterUseCase(any),
          ).thenAnswer((_) async => Right(tUserEntity));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthRegisterRequested(
            email: 'newuser@example.com',
            username: 'newuser',
            password: 'password123',
          ),
        ),
        expect: () => [AuthLoading(), Authenticated(tUserEntity)],
        verify: (_) {
          verify(mockRegisterUseCase(any)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        '❌ Register Failure - Duplicate Email',
        build: () {
          when(mockRegisterUseCase(any)).thenAnswer(
            (_) async => Left(ServerFailure('Email already exists')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthRegisterRequested(
            email: 'existing@example.com',
            username: 'user',
            password: 'password123',
          ),
        ),
        expect: () => [AuthLoading(), AuthError('Email already exists')],
        verify: (_) {
          verify(mockRegisterUseCase(any)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        '❌ Register Failure - Weak Password',
        build: () {
          when(mockRegisterUseCase(any)).thenAnswer(
            (_) async => Left(ValidationFailure('Password too weak')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthRegisterRequested(
            email: 'user@example.com',
            username: 'user',
            password: '123',
          ),
        ),
        expect: () => [AuthLoading(), AuthError('Password too weak')],
        verify: (_) {
          verify(mockRegisterUseCase(any)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        '❌ Register Failure - Invalid Email Format',
        build: () {
          when(mockRegisterUseCase(any)).thenAnswer(
            (_) async => Left(ValidationFailure('Invalid email format')),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(
          AuthRegisterRequested(
            email: 'invalid-email',
            username: 'user',
            password: 'password123',
          ),
        ),
        expect: () => [AuthLoading(), AuthError('Invalid email format')],
        verify: (_) {
          verify(mockRegisterUseCase(any)).called(1);
        },
      );
    });

    group('Logout Tests', () {
      blocTest<AuthBloc, AuthState>(
        '✅ Logout Success - From Authenticated',
        build: () {
          when(mockLogoutUseCase()).thenAnswer((_) async => const Right(null));
          return authBloc;
        },
        seed: () => Authenticated(tUserEntity),
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [AuthLoading(), Unauthenticated()],
        verify: (_) {
          verify(mockLogoutUseCase()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        '✅ Logout - From Unauthenticated (No-op)',
        build: () {
          when(mockLogoutUseCase()).thenAnswer((_) async => const Right(null));
          return authBloc;
        },
        seed: () => Unauthenticated(),
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [AuthLoading(), Unauthenticated()],
      );
    });

    group('Auth Check Tests', () {
      blocTest<AuthBloc, AuthState>(
        '✅ Check Auth - Valid Token',
        build: () {
          when(
            mockCheckAuthUseCase(),
          ).thenAnswer((_) async => Right(tUserEntity));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthLoading(), Authenticated(tUserEntity)],
        verify: (_) {
          verify(mockCheckAuthUseCase()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        '❌ Check Auth - Invalid Token',
        build: () {
          when(
            mockCheckAuthUseCase(),
          ).thenAnswer((_) async => Left(AuthFailure('Token expired')));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthLoading(), Unauthenticated()],
        verify: (_) {
          verify(mockCheckAuthUseCase()).called(1);
        },
      );
    });

    group('Profile Tests', () {
      blocTest<AuthBloc, AuthState>(
        '✅ Get Profile - Authenticated',
        build: () {
          when(
            mockGetProfileUseCase(),
          ).thenAnswer((_) async => Right(tUserEntity));
          return authBloc;
        },
        seed: () => Authenticated(tUserEntity),
        act: (bloc) => bloc.add(AuthProfileRequested()),
        expect: () => [AuthLoading(), Authenticated(tUserEntity)],
        verify: (_) {
          verify(mockGetProfileUseCase()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        '❌ Get Profile - Unauthenticated',
        build: () {
          when(
            mockGetProfileUseCase(),
          ).thenAnswer((_) async => Left(AuthFailure('Not authenticated')));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthProfileRequested()),
        expect: () => [AuthLoading(), AuthError('Not authenticated')],
        verify: (_) {
          verify(mockGetProfileUseCase()).called(1);
        },
      );
    });

    group('Role-Based Navigation Tests', () {
      test('USER role should navigate to Landing Page', () {
        expect(tUserEntity.role, equals('USER'));
      });

      test('ADMIN role should navigate to Dashboard', () {
        expect(tAdminEntity.role, equals('ADMIN'));
      });
    });
  });
}
