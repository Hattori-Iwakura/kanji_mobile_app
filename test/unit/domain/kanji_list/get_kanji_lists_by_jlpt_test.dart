import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/entities/kanji_list.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/repositories/kanji_list_repository.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/usecases/get_kanji_lists_by_jlpt.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/kanji_list_fixtures.dart';

class MockKanjiListRepository extends Mock implements KanjiListRepository {}

void main() {
  late GetKanjiListsByJlpt usecase;
  late MockKanjiListRepository mockRepository;

  setUp(() {
    mockRepository = MockKanjiListRepository();
    usecase = GetKanjiListsByJlpt(mockRepository);
  });

  group('GetKanjiListsByJlpt', () {
    const tJlptLevel = 'N5';

    test('should get kanji lists filtered by JLPT level', () async {
      // arrange
      when(
        () => mockRepository.getListsByJlpt(jlptLevel: any(named: 'jlptLevel')),
      ).thenAnswer((_) async => Right(tAllKanjiLists));

      // act
      final result = await usecase(jlptLevel: tJlptLevel);

      // assert
      expect(result, Right(tAllKanjiLists));
      verify(
        () => mockRepository.getListsByJlpt(jlptLevel: tJlptLevel),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no lists match JLPT level', () async {
      // arrange
      when(
        () => mockRepository.getListsByJlpt(jlptLevel: any(named: 'jlptLevel')),
      ).thenAnswer((_) async => const Right([]));

      // act
      final result = await usecase(jlptLevel: 'N1');

      // assert
      expect(result, const Right<Failure, List<KanjiList>>([]));
      verify(() => mockRepository.getListsByJlpt(jlptLevel: 'N1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should work with all JLPT levels (N5, N4, N3, N2, N1)', () async {
      // arrange
      final levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
      when(
        () => mockRepository.getListsByJlpt(jlptLevel: any(named: 'jlptLevel')),
      ).thenAnswer((_) async => Right(tAllKanjiLists));

      // act & assert
      for (final level in levels) {
        final result = await usecase(jlptLevel: level);
        expect(result, Right(tAllKanjiLists));
        verify(() => mockRepository.getListsByJlpt(jlptLevel: level)).called(1);
      }
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      const tFailure = ServerFailure('Server error');
      when(
        () => mockRepository.getListsByJlpt(jlptLevel: any(named: 'jlptLevel')),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(jlptLevel: tJlptLevel);

      // assert
      expect(result, const Left(tFailure));
      verify(
        () => mockRepository.getListsByJlpt(jlptLevel: tJlptLevel),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
