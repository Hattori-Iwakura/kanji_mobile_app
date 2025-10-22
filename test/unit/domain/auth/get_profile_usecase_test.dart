import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/core/errors/failures.dart';
import 'package:kanji_mobile_v1/features/auth/domain/entities/user.dart';
import 'package:kanji_mobile_v1/features/auth/domain/repositories/auth_repository.dart';
import 'package:kanji_mobile_v1/features/auth/domain/usecases/get_profile_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetProfileUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = GetProfileUseCase(mockAuthRepository);
  });

  final testUser = User(
    id: 1,
    account: 'testuser',
    email: 'test@example.com',
    profileImage: 'https://example.com/avatar.jpg',
    isFirstLogin: false,
    createdAt: DateTime(2024, 1, 1),
    role: 'USER',
  );

  group('GetProfileUseCase', () {
    test('should return User when profile is retrieved successfully', () async {
      // arrange
      when(
        () => mockAuthRepository.getProfile(),
      ).thenAnswer((_) async => Right(testUser));

      // act
      final result = await usecase();

      // assert
      expect(result, equals(Right(testUser)));
      verify(() => mockAuthRepository.getProfile()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test(
      'should return ServerFailure when user is not authenticated',
      () async {
        // arrange
        final failure = ServerFailure('User not authenticated');
        when(
          () => mockAuthRepository.getProfile(),
        ).thenAnswer((_) async => Left(failure));

        // act
        final result = await usecase();

        // assert
        expect(result, equals(Left(failure)));
        verify(() => mockAuthRepository.getProfile()).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test('should return ServerFailure when token is expired', () async {
      // arrange
      final failure = ServerFailure('Token expired');
      when(
        () => mockAuthRepository.getProfile(),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase();

      // assert
      expect(result, equals(Left(failure)));
      verify(() => mockAuthRepository.getProfile()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return NetworkFailure when network is unavailable', () async {
      // arrange
      final failure = NetworkFailure('No internet connection');
      when(
        () => mockAuthRepository.getProfile(),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase();

      // assert
      expect(result, equals(Left(failure)));
      verify(() => mockAuthRepository.getProfile()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return CacheFailure when cached profile is invalid', () async {
      // arrange
      final failure = CacheFailure('Invalid cached profile');
      when(
        () => mockAuthRepository.getProfile(),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase();

      // assert
      expect(result, equals(Left(failure)));
      verify(() => mockAuthRepository.getProfile()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should call repository getProfile without parameters', () async {
      // arrange
      when(
        () => mockAuthRepository.getProfile(),
      ).thenAnswer((_) async => Right(testUser));

      // act
      await usecase();

      // assert
      verify(() => mockAuthRepository.getProfile()).called(1);
    });

    test('should return User with all profile data', () async {
      // arrange
      final userWithFullProfile = User(
        id: 2,
        account: 'fulluser',
        email: 'full@example.com',
        profileImage: 'https://example.com/profile.png',
        isFirstLogin: false,
        createdAt: DateTime(2024, 1, 15),
        role: 'ADMIN',
      );

      when(
        () => mockAuthRepository.getProfile(),
      ).thenAnswer((_) async => Right(userWithFullProfile));

      // act
      final result = await usecase();

      // assert
      result.fold((failure) => fail('Should return Right'), (user) {
        expect(user.id, equals(2));
        expect(user.account, equals('fulluser'));
        expect(user.email, equals('full@example.com'));
        expect(user.profileImage, equals('https://example.com/profile.png'));
        expect(user.isFirstLogin, equals(false));
        expect(user.role, equals('ADMIN'));
      });
      verify(() => mockAuthRepository.getProfile()).called(1);
    });

    test('should handle multiple profile fetch calls', () async {
      // arrange
      when(
        () => mockAuthRepository.getProfile(),
      ).thenAnswer((_) async => Right(testUser));

      // act
      final result1 = await usecase();
      final result2 = await usecase();

      // assert
      expect(result1, equals(Right(testUser)));
      expect(result2, equals(Right(testUser)));
      verify(() => mockAuthRepository.getProfile()).called(2);
    });
  });
}
