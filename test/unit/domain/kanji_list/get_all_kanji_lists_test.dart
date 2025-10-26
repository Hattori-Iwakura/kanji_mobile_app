import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/entities/kanji_list.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/repositories/kanji_list_repository.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/usecases/get_all_kanji_lists.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/kanji_list_fixtures.dart';

class MockKanjiListRepository extends Mock implements KanjiListRepository {}

void main() {
  late GetAllKanjiLists usecase;
  late MockKanjiListRepository mockRepository;

  setUp(() {
    mockRepository = MockKanjiListRepository();
    usecase = GetAllKanjiLists(mockRepository);
  });

  group('GetAllKanjiLists', () {
    test('should get all kanji lists from repository', () async {
      // arrange
      when(
        () => mockRepository.getAllLists(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right(tAllKanjiLists));

      // act
      final result = await usecase();

      // assert
      expect(result, Right(tAllKanjiLists));
      verify(
        () =>
            mockRepository.getAllLists(search: null, limit: null, offset: null),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get all lists with limit and offset for pagination', () async {
      // arrange
      const tLimit = 10;
      const tOffset = 5;
      when(
        () => mockRepository.getAllLists(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right(tAllKanjiLists));

      // act
      final result = await usecase(limit: tLimit, offset: tOffset);

      // assert
      expect(result, Right(tAllKanjiLists));
      verify(
        () => mockRepository.getAllLists(
          search: null,
          limit: tLimit,
          offset: tOffset,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get lists matching search query', () async {
      // arrange
      const tSearch = 'JLPT N5';
      when(
        () => mockRepository.getAllLists(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right(tAllKanjiLists));

      // act
      final result = await usecase(search: tSearch);

      // assert
      expect(result, Right(tAllKanjiLists));
      verify(
        () => mockRepository.getAllLists(
          search: tSearch,
          limit: null,
          offset: null,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no lists found', () async {
      // arrange
      when(
        () => mockRepository.getAllLists(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => const Right([]));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right<Failure, List<KanjiList>>([]));
      verify(
        () =>
            mockRepository.getAllLists(search: null, limit: null, offset: null),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      const tFailure = ServerFailure('Failed to load kanji lists');
      when(
        () => mockRepository.getAllLists(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left(tFailure));
      verify(
        () =>
            mockRepository.getAllLists(search: null, limit: null, offset: null),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
