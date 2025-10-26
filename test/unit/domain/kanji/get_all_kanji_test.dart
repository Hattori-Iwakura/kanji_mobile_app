import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/entities/kanji.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/repositories/kanji_repository.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/get_all_kanji.dart';

class MockKanjiRepository extends Mock implements KanjiRepository {}

void main() {
  late GetAllKanji usecase;
  late MockKanjiRepository mockKanjiRepository;

  setUp(() {
    mockKanjiRepository = MockKanjiRepository();
    usecase = GetAllKanji(mockKanjiRepository);
  });

  final testKanji1 = Kanji(
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

  final testKanji2 = Kanji(
    id: 2,
    character: '月',
    onyomi: 'ゲツ、ガツ',
    kunyomi: 'つき',
    meanings: 'moon, month',
    strokeCount: 4,
    jlpt: 5,
    grade: 1,
    frequency: 2,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final testKanjiList = [testKanji1, testKanji2];

  group('GetAllKanji', () {
    test(
      'should return list of kanji when repository call is successful',
      () async {
        // arrange
        when(
          () => mockKanjiRepository.getAllKanji(
            jlpt: any(named: 'jlpt'),
            grade: any(named: 'grade'),
            search: any(named: 'search'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => Right(testKanjiList));

        // act
        final result = await usecase();

        // assert
        expect(result, equals(Right(testKanjiList)));
        verify(
          () => mockKanjiRepository.getAllKanji(
            jlpt: null,
            grade: null,
            search: null,
            limit: null,
            offset: null,
          ),
        ).called(1);
      },
    );

    test('should return kanji filtered by JLPT level', () async {
      // arrange
      when(
        () => mockKanjiRepository.getAllKanji(
          jlpt: any(named: 'jlpt'),
          grade: any(named: 'grade'),
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right([testKanji1]));

      // act
      final result = await usecase(jlpt: 5);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (kanjiList) => expect(kanjiList, equals([testKanji1])),
      );
      verify(
        () => mockKanjiRepository.getAllKanji(
          jlpt: 5,
          grade: null,
          search: null,
          limit: null,
          offset: null,
        ),
      ).called(1);
    });

    test('should return kanji filtered by grade', () async {
      // arrange
      when(
        () => mockKanjiRepository.getAllKanji(
          jlpt: any(named: 'jlpt'),
          grade: any(named: 'grade'),
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right(testKanjiList));

      // act
      final result = await usecase(grade: 1);

      // assert
      expect(result, equals(Right(testKanjiList)));
      verify(
        () => mockKanjiRepository.getAllKanji(
          jlpt: null,
          grade: 1,
          search: null,
          limit: null,
          offset: null,
        ),
      ).called(1);
    });

    test('should return kanji with search query', () async {
      // arrange
      when(
        () => mockKanjiRepository.getAllKanji(
          jlpt: any(named: 'jlpt'),
          grade: any(named: 'grade'),
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right([testKanji1]));

      // act
      final result = await usecase(search: 'sun');

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (kanjiList) => expect(kanjiList, equals([testKanji1])),
      );
      verify(
        () => mockKanjiRepository.getAllKanji(
          jlpt: null,
          grade: null,
          search: 'sun',
          limit: null,
          offset: null,
        ),
      ).called(1);
    });

    test('should return kanji with pagination', () async {
      // arrange
      when(
        () => mockKanjiRepository.getAllKanji(
          jlpt: any(named: 'jlpt'),
          grade: any(named: 'grade'),
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right(testKanjiList));

      // act
      final result = await usecase(limit: 20, offset: 0);

      // assert
      expect(result, equals(Right(testKanjiList)));
      verify(
        () => mockKanjiRepository.getAllKanji(
          jlpt: null,
          grade: null,
          search: null,
          limit: 20,
          offset: 0,
        ),
      ).called(1);
    });

    test('should return ServerFailure when repository call fails', () async {
      // arrange
      final failure = ServerFailure('Failed to fetch kanji');
      when(
        () => mockKanjiRepository.getAllKanji(
          jlpt: any(named: 'jlpt'),
          grade: any(named: 'grade'),
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase();

      // assert
      expect(result, equals(Left(failure)));
      verify(
        () => mockKanjiRepository.getAllKanji(
          jlpt: null,
          grade: null,
          search: null,
          limit: null,
          offset: null,
        ),
      ).called(1);
    });

    test('should return NetworkFailure when network is unavailable', () async {
      // arrange
      final failure = NetworkFailure('No internet connection');
      when(
        () => mockKanjiRepository.getAllKanji(
          jlpt: any(named: 'jlpt'),
          grade: any(named: 'grade'),
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase();

      // assert
      expect(result, equals(Left(failure)));
    });

    test('should return empty list when no kanji match filters', () async {
      // arrange
      when(
        () => mockKanjiRepository.getAllKanji(
          jlpt: any(named: 'jlpt'),
          grade: any(named: 'grade'),
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => const Right([]));

      // act
      final result = await usecase(jlpt: 1);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (kanjiList) => expect(kanjiList, isEmpty),
      );
    });

    test('should return kanji with multiple filters (JLPT + Grade)', () async {
      // arrange
      when(
        () => mockKanjiRepository.getAllKanji(
          jlpt: any(named: 'jlpt'),
          grade: any(named: 'grade'),
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right(testKanjiList));

      // act
      final result = await usecase(jlpt: 5, grade: 1);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (kanjiList) => expect(kanjiList, equals(testKanjiList)),
      );
      verify(
        () => mockKanjiRepository.getAllKanji(
          jlpt: 5,
          grade: 1,
          search: null,
          limit: null,
          offset: null,
        ),
      ).called(1);
    });

    test('should return kanji with all filters combined', () async {
      // arrange
      when(
        () => mockKanjiRepository.getAllKanji(
          jlpt: any(named: 'jlpt'),
          grade: any(named: 'grade'),
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right([testKanji1]));

      // act
      final result = await usecase(
        jlpt: 5,
        grade: 1,
        search: 'sun',
        limit: 10,
        offset: 0,
      );

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (kanjiList) => expect(kanjiList, equals([testKanji1])),
      );
      verify(
        () => mockKanjiRepository.getAllKanji(
          jlpt: 5,
          grade: 1,
          search: 'sun',
          limit: 10,
          offset: 0,
        ),
      ).called(1);
    });
  });
}
