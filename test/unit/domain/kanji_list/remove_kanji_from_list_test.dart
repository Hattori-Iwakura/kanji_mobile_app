import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/repositories/kanji_list_repository.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/usecases/remove_kanji_from_list.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/kanji_list_fixtures.dart';

class MockKanjiListRepository extends Mock implements KanjiListRepository {}

void main() {
  late RemoveKanjiFromList usecase;
  late MockKanjiListRepository mockRepository;

  setUp(() {
    mockRepository = MockKanjiListRepository();
    usecase = RemoveKanjiFromList(mockRepository);
  });

  group('RemoveKanjiFromList', () {
    const tListId = 1;
    const tKanjiId = 100;

    test('should remove kanji from list and return updated list', () async {
      // arrange
      when(
        () => mockRepository.removeKanjiFromList(
          listId: any(named: 'listId'),
          kanjiId: any(named: 'kanjiId'),
        ),
      ).thenAnswer((_) async => Right(tKanjiList));

      // act
      final result = await usecase(listId: tListId, kanjiId: tKanjiId);

      // assert
      expect(result, Right(tKanjiList));
      verify(
        () => mockRepository.removeKanjiFromList(
          listId: tListId,
          kanjiId: tKanjiId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotFoundFailure when list does not exist', () async {
      // arrange
      const tFailure = NotFoundFailure('Kanji list not found');
      when(
        () => mockRepository.removeKanjiFromList(
          listId: any(named: 'listId'),
          kanjiId: any(named: 'kanjiId'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(listId: tListId, kanjiId: tKanjiId);

      // assert
      expect(result, const Left(tFailure));
      verify(
        () => mockRepository.removeKanjiFromList(
          listId: tListId,
          kanjiId: tKanjiId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotFoundFailure when kanji not in list', () async {
      // arrange
      const tFailure = NotFoundFailure('Kanji not found in this list');
      when(
        () => mockRepository.removeKanjiFromList(
          listId: any(named: 'listId'),
          kanjiId: any(named: 'kanjiId'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(listId: tListId, kanjiId: tKanjiId);

      // assert
      expect(result, const Left(tFailure));
      verify(
        () => mockRepository.removeKanjiFromList(
          listId: tListId,
          kanjiId: tKanjiId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return UnauthorizedFailure when user is not owner', () async {
      // arrange
      const tFailure = UnauthorizedFailure(
        'You are not authorized to modify this list',
      );
      when(
        () => mockRepository.removeKanjiFromList(
          listId: any(named: 'listId'),
          kanjiId: any(named: 'kanjiId'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(listId: tListId, kanjiId: tKanjiId);

      // assert
      expect(result, const Left(tFailure));
      verify(
        () => mockRepository.removeKanjiFromList(
          listId: tListId,
          kanjiId: tKanjiId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      const tFailure = ServerFailure('Failed to remove kanji from list');
      when(
        () => mockRepository.removeKanjiFromList(
          listId: any(named: 'listId'),
          kanjiId: any(named: 'kanjiId'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(listId: tListId, kanjiId: tKanjiId);

      // assert
      expect(result, const Left(tFailure));
      verify(
        () => mockRepository.removeKanjiFromList(
          listId: tListId,
          kanjiId: tKanjiId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
