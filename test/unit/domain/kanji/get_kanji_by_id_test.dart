import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/entities/kanji.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/repositories/kanji_repository.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/get_kanji_by_id.dart';

class MockKanjiRepository extends Mock implements KanjiRepository {}

void main() {
  late GetKanjiById usecase;
  late MockKanjiRepository mockKanjiRepository;

  setUp(() {
    mockKanjiRepository = MockKanjiRepository();
    usecase = GetKanjiById(mockKanjiRepository);
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

  group('GetKanjiById', () {
    test('should return kanji when id exists', () async {
      // arrange
      const testId = 1;
      when(
        () => mockKanjiRepository.getKanjiById(testId),
      ).thenAnswer((_) async => Right(testKanji));

      // act
      final result = await usecase(testId);

      // assert
      expect(result, equals(Right(testKanji)));
      verify(() => mockKanjiRepository.getKanjiById(testId)).called(1);
    });

    test('should return kanji with complete data', () async {
      // arrange
      const testId = 1;
      when(
        () => mockKanjiRepository.getKanjiById(testId),
      ).thenAnswer((_) async => Right(testKanji));

      // act
      final result = await usecase(testId);

      // assert
      result.fold((failure) => fail('Expected Right but got Left'), (kanji) {
        expect(kanji.id, equals(1));
        expect(kanji.character, equals('日'));
        expect(kanji.onyomi, equals('ニチ、ジツ'));
        expect(kanji.kunyomi, equals('ひ、か'));
        expect(kanji.meanings, equals('sun, day'));
        expect(kanji.strokeCount, equals(4));
        expect(kanji.jlpt, equals(5));
        expect(kanji.grade, equals(1));
        expect(kanji.frequency, equals(1));
      });
    });

    test('should return ServerFailure when kanji not found', () async {
      // arrange
      const testId = 999;
      final failure = ServerFailure('Kanji not found');
      when(
        () => mockKanjiRepository.getKanjiById(testId),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(testId);

      // assert
      expect(result, equals(Left(failure)));
      verify(() => mockKanjiRepository.getKanjiById(testId)).called(1);
    });

    test('should return NetworkFailure when network is unavailable', () async {
      // arrange
      const testId = 1;
      final failure = NetworkFailure('No internet connection');
      when(
        () => mockKanjiRepository.getKanjiById(testId),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(testId);

      // assert
      expect(result, equals(Left(failure)));
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      const testId = 1;
      final failure = ServerFailure('Internal server error');
      when(
        () => mockKanjiRepository.getKanjiById(testId),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(testId);

      // assert
      expect(result, equals(Left(failure)));
    });

    test('should handle invalid id gracefully', () async {
      // arrange
      const testId = -1;
      final failure = ServerFailure('Invalid kanji ID');
      when(
        () => mockKanjiRepository.getKanjiById(testId),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(testId);

      // assert
      expect(result, equals(Left(failure)));
    });

    test('should return different kanji for different ids', () async {
      // arrange
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

      when(
        () => mockKanjiRepository.getKanjiById(1),
      ).thenAnswer((_) async => Right(testKanji));
      when(
        () => mockKanjiRepository.getKanjiById(2),
      ).thenAnswer((_) async => Right(testKanji2));

      // act
      final result1 = await usecase(1);
      final result2 = await usecase(2);

      // assert
      result1.fold(
        (failure) => fail('Expected Right for id 1'),
        (kanji) => expect(kanji.character, equals('日')),
      );
      result2.fold(
        (failure) => fail('Expected Right for id 2'),
        (kanji) => expect(kanji.character, equals('月')),
      );
    });
  });
}
