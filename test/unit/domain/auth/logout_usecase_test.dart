import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/core/errors/failures.dart';
import 'package:kanji_mobile_v1/features/auth/domain/repositories/auth_repository.dart';
import 'package:kanji_mobile_v1/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LogoutUseCase(mockAuthRepository);
  });

  group('LogoutUseCase', () {
    test('should return Right(void) when logout is successful', () async {
      // arrange
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase();

      // assert
      expect(result, equals(const Right(null)));
      verify(() => mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return CacheFailure when clearing local data fails', () async {
      // arrange
      final failure = CacheFailure('Failed to clear local data');
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase();

      // assert
      expect(result, equals(Left(failure)));
      verify(() => mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ServerFailure when server logout fails', () async {
      // arrange
      final failure = ServerFailure('Logout failed on server');
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase();

      // assert
      expect(result, equals(Left(failure)));
      verify(() => mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return NetworkFailure when network is unavailable', () async {
      // arrange
      final failure = NetworkFailure('No internet connection');
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase();

      // assert
      expect(result, equals(Left(failure)));
      verify(() => mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should call repository logout without any parameters', () async {
      // arrange
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) async => const Right(null));

      // act
      await usecase();

      // assert
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('should handle multiple logout calls independently', () async {
      // arrange
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) async => const Right(null));

      // act
      final result1 = await usecase();
      final result2 = await usecase();

      // assert
      expect(result1, equals(const Right(null)));
      expect(result2, equals(const Right(null)));
      verify(() => mockAuthRepository.logout()).called(2);
    });
  });
}
