import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/kanji_list/data/datasources/kanji_list_remote_datasource.dart';
import 'package:kanji_mobile_v1/features/kanji_list/data/models/kanji_list_model.dart';
import 'package:kanji_mobile_v1/features/kanji_list/data/repositories/kanji_list_repository_impl.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/entities/kanji_list.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/kanji_list_fixtures.dart';

class MockKanjiListRemoteDataSource extends Mock
    implements KanjiListRemoteDataSource {}

void main() {
  late KanjiListRepositoryImpl repository;
  late MockKanjiListRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockKanjiListRemoteDataSource();
    repository = KanjiListRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  final tKanjiListModel = KanjiListModel.fromJson(tKanjiListJson);
  final tKanjiListsModels = tAllKanjiLists
      .map((e) => KanjiListModel.fromJson(tKanjiListJson))
      .toList();

  group('getAllLists', () {
    test('should return list of KanjiList entities when successful', () async {
      // arrange
      final tResponse = KanjiListsResponse(
        data: tKanjiListsModels,
        total: tKanjiListsModels.length,
        limit: 20,
        offset: 0,
      );
      when(
        () => mockRemoteDataSource.getAllLists(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => tResponse);

      // act
      final result = await repository.getAllLists();

      // assert
      expect(result, isA<Right<Failure, List<KanjiList>>>());
      result.fold((failure) => fail('Should not return failure'), (lists) {
        expect(lists.length, tKanjiListsModels.length);
        expect(lists.first, isA<KanjiList>());
      });
      verify(
        () => mockRemoteDataSource.getAllLists(
          search: null,
          limit: null,
          offset: null,
        ),
      ).called(1);
    });

    test('should pass search, limit, and offset to data source', () async {
      // arrange
      const tSearch = 'JLPT N5';
      const tLimit = 10;
      const tOffset = 5;
      final tResponse = KanjiListsResponse(
        data: [],
        total: 0,
        limit: tLimit,
        offset: tOffset,
      );
      when(
        () => mockRemoteDataSource.getAllLists(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => tResponse);

      // act
      await repository.getAllLists(
        search: tSearch,
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      verify(
        () => mockRemoteDataSource.getAllLists(
          search: tSearch,
          limit: tLimit,
          offset: tOffset,
        ),
      ).called(1);
    });

    test(
      'should return NetworkFailure when timeout exception occurs',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.getAllLists(
            search: any(named: 'search'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(Exception('Connection timeout'));

        // act
        final result = await repository.getAllLists();

        // assert
        expect(result, isA<Left<Failure, List<KanjiList>>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (lists) => fail('Should not return success'),
        );
      },
    );

    test('should return ServerFailure when generic exception occurs', () async {
      // arrange
      when(
        () => mockRemoteDataSource.getAllLists(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenThrow(Exception('Server error'));

      // act
      final result = await repository.getAllLists();

      // assert
      expect(result, isA<Left<Failure, List<KanjiList>>>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (lists) => fail('Should not return success'),
      );
    });
  });

  group('getListById', () {
    const tId = 1;

    test('should return KanjiList entity when successful', () async {
      // arrange
      when(
        () => mockRemoteDataSource.getListById(any()),
      ).thenAnswer((_) async => tKanjiListModel);

      // act
      final result = await repository.getListById(tId);

      // assert
      expect(result, isA<Right<Failure, KanjiList>>());
      result.fold((failure) => fail('Should not return failure'), (kanjiList) {
        expect(kanjiList, isA<KanjiList>());
        expect(kanjiList.id, tKanjiListModel.id);
      });
      verify(() => mockRemoteDataSource.getListById(tId)).called(1);
    });

    test('should return NotFoundFailure when list not found', () async {
      // arrange
      when(
        () => mockRemoteDataSource.getListById(any()),
      ).thenThrow(Exception('Kanji list not found'));

      // act
      final result = await repository.getListById(tId);

      // assert
      expect(result, isA<Left<Failure, KanjiList>>());
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (kanjiList) => fail('Should not return success'),
      );
    });
  });

  group('createList', () {
    const tName = 'My List';
    const tDescription = 'Test description';
    final tKanjiIds = [1, 2, 3];

    test('should return created KanjiList entity when successful', () async {
      // arrange
      when(
        () => mockRemoteDataSource.createList(
          name: any(named: 'name'),
          description: any(named: 'description'),
          kanjiIds: any(named: 'kanjiIds'),
        ),
      ).thenAnswer((_) async => tKanjiListModel);

      // act
      final result = await repository.createList(
        name: tName,
        description: tDescription,
        kanjiIds: tKanjiIds,
      );

      // assert
      expect(result, isA<Right<Failure, KanjiList>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (kanjiList) => expect(kanjiList, isA<KanjiList>()),
      );
      verify(
        () => mockRemoteDataSource.createList(
          name: tName,
          description: tDescription,
          kanjiIds: tKanjiIds,
        ),
      ).called(1);
    });

    test('should return BadRequestFailure when invalid request', () async {
      // arrange
      when(
        () => mockRemoteDataSource.createList(
          name: any(named: 'name'),
          description: any(named: 'description'),
          kanjiIds: any(named: 'kanjiIds'),
        ),
      ).thenThrow(Exception('Invalid request'));

      // act
      final result = await repository.createList(name: tName);

      // assert
      expect(result, isA<Left<Failure, KanjiList>>());
      result.fold(
        (failure) => expect(failure, isA<BadRequestFailure>()),
        (kanjiList) => fail('Should not return success'),
      );
    });
  });

  group('updateList', () {
    const tId = 1;
    const tName = 'Updated Name';

    test('should return updated KanjiList entity when successful', () async {
      // arrange
      when(
        () => mockRemoteDataSource.updateList(
          id: any(named: 'id'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          isPublic: any(named: 'isPublic'),
        ),
      ).thenAnswer((_) async => tKanjiListModel);

      // act
      final result = await repository.updateList(id: tId, name: tName);

      // assert
      expect(result, isA<Right<Failure, KanjiList>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (kanjiList) => expect(kanjiList, isA<KanjiList>()),
      );
      verify(
        () => mockRemoteDataSource.updateList(
          id: tId,
          name: tName,
          description: null,
          isPublic: null,
        ),
      ).called(1);
    });

    test('should return NotFoundFailure when list not found', () async {
      // arrange
      when(
        () => mockRemoteDataSource.updateList(
          id: any(named: 'id'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          isPublic: any(named: 'isPublic'),
        ),
      ).thenThrow(Exception('Kanji list not found'));

      // act
      final result = await repository.updateList(id: tId, name: tName);

      // assert
      expect(result, isA<Left<Failure, KanjiList>>());
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (kanjiList) => fail('Should not return success'),
      );
    });
  });

  group('deleteList', () {
    const tId = 1;

    test('should return Right(null) when successful', () async {
      // arrange
      when(
        () => mockRemoteDataSource.deleteList(any()),
      ).thenAnswer((_) async => Future.value());

      // act
      final result = await repository.deleteList(tId);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockRemoteDataSource.deleteList(tId)).called(1);
    });

    test('should return UnauthorizedFailure when not authorized', () async {
      // arrange
      when(
        () => mockRemoteDataSource.deleteList(any()),
      ).thenThrow(Exception('Unauthorized'));

      // act
      final result = await repository.deleteList(tId);

      // assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Should not return success'),
      );
    });

    test('should return NotFoundFailure when list not found', () async {
      // arrange
      when(
        () => mockRemoteDataSource.deleteList(any()),
      ).thenThrow(Exception('Kanji list not found'));

      // act
      final result = await repository.deleteList(tId);

      // assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Should not return success'),
      );
    });
  });

  group('addKanjiToList', () {
    const tListId = 1;
    const tKanjiId = 100;

    test('should return updated KanjiList entity when successful', () async {
      // arrange
      when(
        () => mockRemoteDataSource.addKanjiToList(any(), any()),
      ).thenAnswer((_) async => tKanjiListModel);

      // act
      final result = await repository.addKanjiToList(
        listId: tListId,
        kanjiId: tKanjiId,
      );

      // assert
      expect(result, isA<Right<Failure, KanjiList>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (kanjiList) => expect(kanjiList, isA<KanjiList>()),
      );
      verify(
        () => mockRemoteDataSource.addKanjiToList(tListId, tKanjiId),
      ).called(1);
    });

    test(
      'should return NotFoundFailure when list or kanji not found',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.addKanjiToList(any(), any()),
        ).thenThrow(Exception('Kanji not found'));

        // act
        final result = await repository.addKanjiToList(
          listId: tListId,
          kanjiId: tKanjiId,
        );

        // assert
        expect(result, isA<Left<Failure, KanjiList>>());
        result.fold(
          (failure) => expect(failure, isA<NotFoundFailure>()),
          (kanjiList) => fail('Should not return success'),
        );
      },
    );
  });

  group('removeKanjiFromList', () {
    const tListId = 1;
    const tKanjiId = 100;

    test('should return updated KanjiList entity when successful', () async {
      // arrange
      when(
        () => mockRemoteDataSource.removeKanjiFromList(any(), any()),
      ).thenAnswer((_) async => tKanjiListModel);

      // act
      final result = await repository.removeKanjiFromList(
        listId: tListId,
        kanjiId: tKanjiId,
      );

      // assert
      expect(result, isA<Right<Failure, KanjiList>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (kanjiList) => expect(kanjiList, isA<KanjiList>()),
      );
      verify(
        () => mockRemoteDataSource.removeKanjiFromList(tListId, tKanjiId),
      ).called(1);
    });

    test('should return NotFoundFailure when kanji not in list', () async {
      // arrange
      when(
        () => mockRemoteDataSource.removeKanjiFromList(any(), any()),
      ).thenThrow(Exception('Kanji not found in this list'));

      // act
      final result = await repository.removeKanjiFromList(
        listId: tListId,
        kanjiId: tKanjiId,
      );

      // assert
      expect(result, isA<Left<Failure, KanjiList>>());
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (kanjiList) => fail('Should not return success'),
      );
    });
  });

  group('getListsByJlpt', () {
    const tJlptLevel = 'N5';

    test('should return list of KanjiList entities when successful', () async {
      // arrange
      final tResponse = KanjiListsResponse(
        data: tKanjiListsModels,
        total: tKanjiListsModels.length,
        limit: 20,
        offset: 0,
      );
      when(
        () => mockRemoteDataSource.getListsByJlpt(any()),
      ).thenAnswer((_) async => tResponse);

      // act
      final result = await repository.getListsByJlpt(jlptLevel: tJlptLevel);

      // assert
      expect(result, isA<Right<Failure, List<KanjiList>>>());
      result.fold((failure) => fail('Should not return failure'), (lists) {
        expect(lists.length, tKanjiListsModels.length);
        expect(lists.first, isA<KanjiList>());
      });
      verify(() => mockRemoteDataSource.getListsByJlpt(tJlptLevel)).called(1);
    });

    test('should return ServerFailure when exception occurs', () async {
      // arrange
      when(
        () => mockRemoteDataSource.getListsByJlpt(any()),
      ).thenThrow(Exception('Server error'));

      // act
      final result = await repository.getListsByJlpt(jlptLevel: tJlptLevel);

      // assert
      expect(result, isA<Left<Failure, List<KanjiList>>>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (lists) => fail('Should not return success'),
      );
    });
  });
}
