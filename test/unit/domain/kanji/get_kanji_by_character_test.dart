import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/get_kanji_by_character.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/repositories/kanji_repository.dart';

import '../../../helpers/fixtures/kanji_fixtures.dart';

class MockKanjiRepository extends Mock implements KanjiRepository {}

void main() {
  late GetKanjiByCharacter usecase;
  late MockKanjiRepository mockKanjiRepository;

  setUp(() {
    mockKanjiRepository = MockKanjiRepository();
    usecase = GetKanjiByCharacter(mockKanjiRepository);
  });

  group('GetKanjiByCharacter', () {
    const tCharacter = '日';

    test('should return kanji when repository call is successful', () async {
      // arrange
      when(
        () => mockKanjiRepository.getKanjiByCharacter(any()),
      ).thenAnswer((_) async => Right(tKanji1));

      // act
      final result = await usecase(tCharacter);

      // assert
      expect(result, equals(Right(tKanji1)));
      verify(
        () => mockKanjiRepository.getKanjiByCharacter(tCharacter),
      ).called(1);
      verifyNoMoreInteractions(mockKanjiRepository);
    });

    test('should return ValidationFailure when character is empty', () async {
      // act
      final result = await usecase('');

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (kanji) => fail('Expected ValidationFailure but got Kanji'),
      );
      verifyNever(() => mockKanjiRepository.getKanjiByCharacter(any()));
    });

    test(
      'should return ValidationFailure when character length is more than 1',
      () async {
        // act
        final result = await usecase('日本');

        // assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            (failure as ValidationFailure).message,
            contains('single character'),
          );
        }, (kanji) => fail('Expected ValidationFailure but got Kanji'));
        verifyNever(() => mockKanjiRepository.getKanjiByCharacter(any()));
      },
    );

    test('should return NotFoundFailure when kanji does not exist', () async {
      // arrange
      final failure = NotFoundFailure('Kanji not found');
      when(
        () => mockKanjiRepository.getKanjiByCharacter(any()),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(tCharacter);

      // assert
      expect(result, equals(Left(failure)));
      verify(
        () => mockKanjiRepository.getKanjiByCharacter(tCharacter),
      ).called(1);
    });

    test('should return ServerFailure when repository call fails', () async {
      // arrange
      final failure = ServerFailure('Failed to fetch kanji');
      when(
        () => mockKanjiRepository.getKanjiByCharacter(any()),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(tCharacter);

      // assert
      expect(result, equals(Left(failure)));
      verify(
        () => mockKanjiRepository.getKanjiByCharacter(tCharacter),
      ).called(1);
    });

    test('should return NetworkFailure when network is unavailable', () async {
      // arrange
      final failure = NetworkFailure('No internet connection');
      when(
        () => mockKanjiRepository.getKanjiByCharacter(any()),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(tCharacter);

      // assert
      expect(result, equals(Left(failure)));
    });

    test('should work with different kanji characters', () async {
      // arrange
      when(
        () => mockKanjiRepository.getKanjiByCharacter('水'),
      ).thenAnswer((_) async => Right(tKanji4));

      // act
      final result = await usecase('水');

      // assert
      expect(result, equals(Right(tKanji4)));
      verify(() => mockKanjiRepository.getKanjiByCharacter('水')).called(1);
    });
  });
}
