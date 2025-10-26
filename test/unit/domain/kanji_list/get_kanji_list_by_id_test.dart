import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/repositories/kanji_list_repository.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/usecases/get_kanji_list_by_id.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/kanji_list_fixtures.dart';

class MockKanjiListRepository extends Mock implements KanjiListRepository {}

void main() {
  late GetKanjiListById usecase;
  late MockKanjiListRepository mockRepository;

  setUp(() {
    mockRepository = MockKanjiListRepository();
    usecase = GetKanjiListById(mockRepository);
  });

  group('GetKanjiListById', () {
    const tId = 1;

    test('should get kanji list by id from repository', () async {
      // arrange
      when(
        () => mockRepository.getListById(any()),
      ).thenAnswer((_) async => Right(tKanjiList));

      // act
      final result = await usecase(tId);

      // assert
      expect(result, Right(tKanjiList));
      verify(() => mockRepository.getListById(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotFoundFailure when list does not exist', () async {
      // arrange
      const tFailure = NotFoundFailure('Kanji list not found');
      when(
        () => mockRepository.getListById(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tId);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.getListById(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      const tFailure = ServerFailure('Server error');
      when(
        () => mockRepository.getListById(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tId);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.getListById(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when there is no internet', () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(
        () => mockRepository.getListById(any()),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tId);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.getListById(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
