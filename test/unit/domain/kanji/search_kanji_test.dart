import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/entities/kanji.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/repositories/kanji_repository.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/search_kanji.dart';

class MockKanjiRepository extends Mock implements KanjiRepository {}

void main() {
  late SearchKanji usecase;
  late MockKanjiRepository mockKanjiRepository;

  setUp(() {
    mockKanjiRepository = MockKanjiRepository();
    usecase = SearchKanji(mockKanjiRepository);
  });

  final testKanji = Kanji(
    id: 1,
    character: '日',
    onyomi: 'ニチ、ジツ',
    kunyomi: 'ひ、か',
    meanings: 'sun, day',
    strokeCount: 4,
    jlpt: 5,
    grade: 1,
    frequency: 1,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final testSearchResults = [testKanji];

  group('SearchKanji', () {
    test('should return search results when query is successful', () async {
      // arrange
      when(
        () => mockKanjiRepository.searchKanji(
          query: any(named: 'query'),
          jlptLevels: any(named: 'jlptLevels'),
          grades: any(named: 'grades'),
          minStrokes: any(named: 'minStrokes'),
          maxStrokes: any(named: 'maxStrokes'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortBy: any(named: 'sortBy'),
        ),
      ).thenAnswer((_) async => Right(testSearchResults));

      // act
      final result = await usecase(query: 'sun');

      // assert
      expect(result, equals(Right(testSearchResults)));
      verify(
        () => mockKanjiRepository.searchKanji(
          query: 'sun',
          jlptLevels: null,
          grades: null,
          minStrokes: null,
          maxStrokes: null,
          page: 1,
          limit: 20,
          sortBy: null,
        ),
      ).called(1);
    });

    test('should search kanji with JLPT level filters', () async {
      // arrange
      when(
        () => mockKanjiRepository.searchKanji(
          query: any(named: 'query'),
          jlptLevels: any(named: 'jlptLevels'),
          grades: any(named: 'grades'),
          minStrokes: any(named: 'minStrokes'),
          maxStrokes: any(named: 'maxStrokes'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortBy: any(named: 'sortBy'),
        ),
      ).thenAnswer((_) async => Right(testSearchResults));

      // act
      final result = await usecase(query: 'sun', jlptLevels: [5, 4]);

      // assert
      expect(result, equals(Right(testSearchResults)));
      verify(
        () => mockKanjiRepository.searchKanji(
          query: 'sun',
          jlptLevels: [5, 4],
          grades: null,
          minStrokes: null,
          maxStrokes: null,
          page: 1,
          limit: 20,
          sortBy: null,
        ),
      ).called(1);
    });

    test('should search kanji with grade filters', () async {
      // arrange
      when(
        () => mockKanjiRepository.searchKanji(
          query: any(named: 'query'),
          jlptLevels: any(named: 'jlptLevels'),
          grades: any(named: 'grades'),
          minStrokes: any(named: 'minStrokes'),
          maxStrokes: any(named: 'maxStrokes'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortBy: any(named: 'sortBy'),
        ),
      ).thenAnswer((_) async => Right(testSearchResults));

      // act
      final result = await usecase(query: 'sun', grades: [1, 2]);

      // assert
      expect(result, equals(Right(testSearchResults)));
      verify(
        () => mockKanjiRepository.searchKanji(
          query: 'sun',
          jlptLevels: null,
          grades: [1, 2],
          minStrokes: null,
          maxStrokes: null,
          page: 1,
          limit: 20,
          sortBy: null,
        ),
      ).called(1);
    });

    test('should search kanji with stroke count range', () async {
      // arrange
      when(
        () => mockKanjiRepository.searchKanji(
          query: any(named: 'query'),
          jlptLevels: any(named: 'jlptLevels'),
          grades: any(named: 'grades'),
          minStrokes: any(named: 'minStrokes'),
          maxStrokes: any(named: 'maxStrokes'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortBy: any(named: 'sortBy'),
        ),
      ).thenAnswer((_) async => Right(testSearchResults));

      // act
      final result = await usecase(query: 'sun', minStrokes: 1, maxStrokes: 5);

      // assert
      expect(result, equals(Right(testSearchResults)));
      verify(
        () => mockKanjiRepository.searchKanji(
          query: 'sun',
          jlptLevels: null,
          grades: null,
          minStrokes: 1,
          maxStrokes: 5,
          page: 1,
          limit: 20,
          sortBy: null,
        ),
      ).called(1);
    });

    test('should search kanji with pagination', () async {
      // arrange
      when(
        () => mockKanjiRepository.searchKanji(
          query: any(named: 'query'),
          jlptLevels: any(named: 'jlptLevels'),
          grades: any(named: 'grades'),
          minStrokes: any(named: 'minStrokes'),
          maxStrokes: any(named: 'maxStrokes'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortBy: any(named: 'sortBy'),
        ),
      ).thenAnswer((_) async => Right(testSearchResults));

      // act
      final result = await usecase(query: 'sun', page: 2, limit: 10);

      // assert
      expect(result, equals(Right(testSearchResults)));
      verify(
        () => mockKanjiRepository.searchKanji(
          query: 'sun',
          jlptLevels: null,
          grades: null,
          minStrokes: null,
          maxStrokes: null,
          page: 2,
          limit: 10,
          sortBy: null,
        ),
      ).called(1);
    });

    test('should search kanji with sort option', () async {
      // arrange
      when(
        () => mockKanjiRepository.searchKanji(
          query: any(named: 'query'),
          jlptLevels: any(named: 'jlptLevels'),
          grades: any(named: 'grades'),
          minStrokes: any(named: 'minStrokes'),
          maxStrokes: any(named: 'maxStrokes'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortBy: any(named: 'sortBy'),
        ),
      ).thenAnswer((_) async => Right(testSearchResults));

      // act
      final result = await usecase(query: 'sun', sortBy: 'frequency');

      // assert
      expect(result, equals(Right(testSearchResults)));
      verify(
        () => mockKanjiRepository.searchKanji(
          query: 'sun',
          jlptLevels: null,
          grades: null,
          minStrokes: null,
          maxStrokes: null,
          page: 1,
          limit: 20,
          sortBy: 'frequency',
        ),
      ).called(1);
    });

    test('should return ServerFailure when search fails', () async {
      // arrange
      final failure = ServerFailure('Search failed');
      when(
        () => mockKanjiRepository.searchKanji(
          query: any(named: 'query'),
          jlptLevels: any(named: 'jlptLevels'),
          grades: any(named: 'grades'),
          minStrokes: any(named: 'minStrokes'),
          maxStrokes: any(named: 'maxStrokes'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortBy: any(named: 'sortBy'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(query: 'invalid');

      // assert
      expect(result, equals(Left(failure)));
    });

    test('should return NetworkFailure when network is unavailable', () async {
      // arrange
      final failure = NetworkFailure('No internet connection');
      when(
        () => mockKanjiRepository.searchKanji(
          query: any(named: 'query'),
          jlptLevels: any(named: 'jlptLevels'),
          grades: any(named: 'grades'),
          minStrokes: any(named: 'minStrokes'),
          maxStrokes: any(named: 'maxStrokes'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortBy: any(named: 'sortBy'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(query: 'sun');

      // assert
      expect(result, equals(Left(failure)));
    });

    test('should return empty list when no results found', () async {
      // arrange
      when(
        () => mockKanjiRepository.searchKanji(
          query: any(named: 'query'),
          jlptLevels: any(named: 'jlptLevels'),
          grades: any(named: 'grades'),
          minStrokes: any(named: 'minStrokes'),
          maxStrokes: any(named: 'maxStrokes'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortBy: any(named: 'sortBy'),
        ),
      ).thenAnswer((_) async => const Right([]));

      // act
      final result = await usecase(query: 'nonexistent');

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (kanjiList) => expect(kanjiList, isEmpty),
      );
    });

    test('should search with multiple filters combined', () async {
      // arrange
      when(
        () => mockKanjiRepository.searchKanji(
          query: any(named: 'query'),
          jlptLevels: any(named: 'jlptLevels'),
          grades: any(named: 'grades'),
          minStrokes: any(named: 'minStrokes'),
          maxStrokes: any(named: 'maxStrokes'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortBy: any(named: 'sortBy'),
        ),
      ).thenAnswer((_) async => Right(testSearchResults));

      // act
      final result = await usecase(
        query: 'sun',
        jlptLevels: [5],
        grades: [1],
        minStrokes: 1,
        maxStrokes: 5,
        page: 1,
        limit: 20,
        sortBy: 'frequency',
      );

      // assert
      expect(result, equals(Right(testSearchResults)));
      verify(
        () => mockKanjiRepository.searchKanji(
          query: 'sun',
          jlptLevels: [5],
          grades: [1],
          minStrokes: 1,
          maxStrokes: 5,
          page: 1,
          limit: 20,
          sortBy: 'frequency',
        ),
      ).called(1);
    });
  });
}
