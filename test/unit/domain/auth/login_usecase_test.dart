import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/core/errors/failures.dart';
import 'package:kanji_mobile_v1/features/auth/domain/entities/auth_result.dart';
import 'package:kanji_mobile_v1/features/auth/domain/entities/user.dart';
import 'package:kanji_mobile_v1/features/auth/domain/repositories/auth_repository.dart';
import 'package:kanji_mobile_v1/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUseCase(mockAuthRepository);
  });

  const testAccount = 'testuser';
  const testPassword = 'password123';

  final testUser = User(
    id: 1,
    account: testAccount,
    email: 'test@example.com',
    profileImage: null,
    isFirstLogin: false,
    createdAt: DateTime(2024, 1, 1),
    role: 'USER',
  );

  final testAuthResult = AuthResult(
    user: testUser,
    accessToken: 'mock_access_token',
    refreshToken: 'mock_refresh_token',
  );

  group('LoginUseCase', () {
    test('should return AuthResult when login is successful', () async {
      // arrange
      when(
        () => mockAuthRepository.login(
          account: any(named: 'account'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Right(testAuthResult));

      // act
      final result = await usecase(
        account: testAccount,
        password: testPassword,
      );

      // assert
      expect(result, equals(Right(testAuthResult)));
      verify(
        () => mockAuthRepository.login(
          account: testAccount,
          password: testPassword,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ServerFailure when credentials are invalid', () async {
      // arrange
      final failure = ServerFailure('Invalid credentials');
      when(
        () => mockAuthRepository.login(
          account: any(named: 'account'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(
        account: testAccount,
        password: testPassword,
      );

      // assert
      expect(result, equals(Left(failure)));
      verify(
        () => mockAuthRepository.login(
          account: testAccount,
          password: testPassword,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return NetworkFailure when network is unavailable', () async {
      // arrange
      final failure = NetworkFailure('No internet connection');
      when(
        () => mockAuthRepository.login(
          account: any(named: 'account'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(
        account: testAccount,
        password: testPassword,
      );

      // assert
      expect(result, equals(Left(failure)));
      verify(
        () => mockAuthRepository.login(
          account: testAccount,
          password: testPassword,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ValidationFailure for empty account', () async {
      // arrange
      final failure = ValidationFailure('Account cannot be empty');
      when(
        () => mockAuthRepository.login(
          account: any(named: 'account'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(account: '', password: testPassword);

      // assert
      expect(result, equals(Left(failure)));
      verify(
        () => mockAuthRepository.login(account: '', password: testPassword),
      ).called(1);
    });

    test('should return ValidationFailure for empty password', () async {
      // arrange
      final failure = ValidationFailure('Password cannot be empty');
      when(
        () => mockAuthRepository.login(
          account: any(named: 'account'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(account: testAccount, password: '');

      // assert
      expect(result, equals(Left(failure)));
      verify(
        () => mockAuthRepository.login(account: testAccount, password: ''),
      ).called(1);
    });

    test('should call repository with exact parameters', () async {
      // arrange
      when(
        () => mockAuthRepository.login(
          account: any(named: 'account'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Right(testAuthResult));

      // act
      await usecase(account: testAccount, password: testPassword);

      // assert
      verify(
        () => mockAuthRepository.login(
          account: testAccount,
          password: testPassword,
        ),
      ).called(1);
    });
  });
}
