import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/core/errors/failures.dart';
import 'package:kanji_mobile_v1/features/auth/domain/entities/auth_result.dart';
import 'package:kanji_mobile_v1/features/auth/domain/entities/user.dart';
import 'package:kanji_mobile_v1/features/auth/domain/repositories/auth_repository.dart';
import 'package:kanji_mobile_v1/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = RegisterUseCase(mockAuthRepository);
  });

  const testAccount = 'newuser';
  const testEmail = 'newuser@example.com';
  const testPassword = 'password123';

  final testUser = User(
    id: 1,
    account: testAccount,
    email: testEmail,
    profileImage: null,
    isFirstLogin: true,
    createdAt: DateTime(2024, 1, 1),
    role: 'USER',
  );

  final testAuthResult = AuthResult(
    user: testUser,
    accessToken: 'mock_access_token',
    refreshToken: 'mock_refresh_token',
  );

  group('RegisterUseCase', () {
    test('should return AuthResult when registration is successful', () async {
      // arrange
      when(
        () => mockAuthRepository.register(
          account: any(named: 'account'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Right(testAuthResult));

      // act
      final result = await usecase(
        account: testAccount,
        email: testEmail,
        password: testPassword,
      );

      // assert
      expect(result, equals(Right(testAuthResult)));
      verify(
        () => mockAuthRepository.register(
          account: testAccount,
          email: testEmail,
          password: testPassword,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ServerFailure when email already exists', () async {
      // arrange
      final failure = ServerFailure('Email already exists');
      when(
        () => mockAuthRepository.register(
          account: any(named: 'account'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(
        account: testAccount,
        email: testEmail,
        password: testPassword,
      );

      // assert
      expect(result, equals(Left(failure)));
      verify(
        () => mockAuthRepository.register(
          account: testAccount,
          email: testEmail,
          password: testPassword,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ServerFailure when account already exists', () async {
      // arrange
      final failure = ServerFailure('Account already exists');
      when(
        () => mockAuthRepository.register(
          account: any(named: 'account'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(
        account: testAccount,
        email: testEmail,
        password: testPassword,
      );

      // assert
      expect(result, equals(Left(failure)));
      verify(
        () => mockAuthRepository.register(
          account: testAccount,
          email: testEmail,
          password: testPassword,
        ),
      ).called(1);
    });

    test('should return ValidationFailure for invalid email format', () async {
      // arrange
      final failure = ValidationFailure('Invalid email format');
      when(
        () => mockAuthRepository.register(
          account: any(named: 'account'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(
        account: testAccount,
        email: 'invalid-email',
        password: testPassword,
      );

      // assert
      expect(result, equals(Left(failure)));
      verify(
        () => mockAuthRepository.register(
          account: testAccount,
          email: 'invalid-email',
          password: testPassword,
        ),
      ).called(1);
    });

    test('should return ValidationFailure for weak password', () async {
      // arrange
      final failure = ValidationFailure(
        'Password must be at least 6 characters',
      );
      when(
        () => mockAuthRepository.register(
          account: any(named: 'account'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(
        account: testAccount,
        email: testEmail,
        password: '123',
      );

      // assert
      expect(result, equals(Left(failure)));
      verify(
        () => mockAuthRepository.register(
          account: testAccount,
          email: testEmail,
          password: '123',
        ),
      ).called(1);
    });

    test('should return ValidationFailure for empty account', () async {
      // arrange
      final failure = ValidationFailure('Account cannot be empty');
      when(
        () => mockAuthRepository.register(
          account: any(named: 'account'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(
        account: '',
        email: testEmail,
        password: testPassword,
      );

      // assert
      expect(result, equals(Left(failure)));
      verify(
        () => mockAuthRepository.register(
          account: '',
          email: testEmail,
          password: testPassword,
        ),
      ).called(1);
    });

    test('should return NetworkFailure when network is unavailable', () async {
      // arrange
      final failure = NetworkFailure('No internet connection');
      when(
        () => mockAuthRepository.register(
          account: any(named: 'account'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(
        account: testAccount,
        email: testEmail,
        password: testPassword,
      );

      // assert
      expect(result, equals(Left(failure)));
      verify(
        () => mockAuthRepository.register(
          account: testAccount,
          email: testEmail,
          password: testPassword,
        ),
      ).called(1);
    });

    test('should call repository with exact parameters', () async {
      // arrange
      when(
        () => mockAuthRepository.register(
          account: any(named: 'account'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Right(testAuthResult));

      // act
      await usecase(
        account: testAccount,
        email: testEmail,
        password: testPassword,
      );

      // assert
      verify(
        () => mockAuthRepository.register(
          account: testAccount,
          email: testEmail,
          password: testPassword,
        ),
      ).called(1);
    });
  });
}
