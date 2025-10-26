import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:kanji_mobile_v1/features/kanji_list/data/datasources/kanji_list_remote_datasource.dart';
import 'package:kanji_mobile_v1/features/kanji_list/data/repositories/kanji_list_repository_impl.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/usecases/add_kanji_to_list.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/usecases/create_kanji_list.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/usecases/delete_kanji_list.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/usecases/get_all_kanji_lists.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/usecases/get_kanji_list_by_id.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/usecases/get_kanji_lists_by_jlpt.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/usecases/remove_kanji_from_list.dart';
import 'package:kanji_mobile_v1/features/kanji_list/domain/usecases/update_kanji_list.dart';
import 'package:kanji_mobile_v1/features/kanji_list/presentation/bloc/kanji_list_bloc.dart';
import 'package:kanji_mobile_v1/features/kanji_list/presentation/bloc/kanji_list_event.dart';
import 'package:kanji_mobile_v1/features/kanji_list/presentation/bloc/kanji_list_state.dart';

import '../helpers/fixtures/kanji_list_fixtures.dart';

void main() {
  late KanjiListBloc bloc;
  late Dio dio;
  late DioAdapter dioAdapter;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api'));
    dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;

    // Setup data source, repository, and use cases
    final dataSource = KanjiListRemoteDataSourceImpl(dio: dio);
    final repository = KanjiListRepositoryImpl(remoteDataSource: dataSource);

    bloc = KanjiListBloc(
      getAllKanjiLists: GetAllKanjiLists(repository),
      getKanjiListById: GetKanjiListById(repository),
      createKanjiList: CreateKanjiList(repository),
      updateKanjiList: UpdateKanjiList(repository),
      deleteKanjiList: DeleteKanjiList(repository),
      addKanjiToList: AddKanjiToList(repository),
      removeKanjiFromList: RemoveKanjiFromList(repository),
      getKanjiListsByJlpt: GetKanjiListsByJlpt(repository),
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadKanjiListsEvent Integration', () {
    test(
      'should emit [Loading, Loaded] when fetching lists successfully',
      () async {
        // arrange
        dioAdapter.onGet(
          '/kanji-lists',
          (server) => server.reply(200, tAllKanjiListsResponseJson),
        );

        // assert later - GET all returns lists without items
        final expected = [
          KanjiListLoading(),
          KanjiListsLoaded(tAllKanjiListsNoItems),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const LoadKanjiListsEvent());
      },
    );

    test('should emit [Loading, Loaded] with search parameter', () async {
      // arrange
      const tSearch = 'JLPT N5';
      dioAdapter.onGet(
        '/kanji-lists',
        (server) => server.reply(200, tAllKanjiListsResponseJson),
        queryParameters: {'search': tSearch},
      );

      // assert later - GET all returns lists without items
      final expected = [
        KanjiListLoading(),
        KanjiListsLoaded(tAllKanjiListsNoItems),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(const LoadKanjiListsEvent(search: tSearch));
    });

    test('should emit [Loading, Loaded] with pagination', () async {
      // arrange
      const tLimit = 10;
      const tOffset = 5;
      dioAdapter.onGet(
        '/kanji-lists',
        (server) => server.reply(200, tAllKanjiListsResponseJson),
        queryParameters: {'limit': tLimit, 'offset': tOffset},
      );

      // assert later - GET all returns lists without items
      final expected = [
        KanjiListLoading(),
        KanjiListsLoaded(tAllKanjiListsNoItems),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(const LoadKanjiListsEvent(limit: tLimit, offset: tOffset));
    });

    test('should emit [Loading, Error] when API fails', () async {
      // arrange
      dioAdapter.onGet(
        '/kanji-lists',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      // assert later
      final expected = [
        KanjiListLoading(),
        isA<KanjiListError>().having(
          (e) => e.message,
          'message',
          contains('Server error'),
        ),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(const LoadKanjiListsEvent());
    });
  });

  group('LoadKanjiListByIdEvent Integration', () {
    test(
      'should emit [Loading, Loaded] when fetching list by id successfully',
      () async {
        // arrange
        const tId = 1;
        dioAdapter.onGet(
          '/kanji-lists/1',
          (server) => server.reply(200, tKanjiListByIdJson),
        );

        // assert later - GET by ID returns full list with items
        final expected = [KanjiListLoading(), KanjiListLoaded(tKanjiListById)];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const LoadKanjiListByIdEvent(tId));
      },
    );

    test('should emit [Loading, Error] when list not found', () async {
      // arrange
      const tId = 999;
      dioAdapter.onGet(
        '/kanji-lists/$tId',
        (server) => server.reply(404, {'message': 'Kanji list not found'}),
      );

      // assert later
      final expected = [
        KanjiListLoading(),
        isA<KanjiListError>().having(
          (e) => e.message,
          'message',
          contains('not found'),
        ),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(const LoadKanjiListByIdEvent(tId));
    });
  });

  group('CreateKanjiListEvent Integration', () {
    test(
      'should emit [Loading, Created] when creating list successfully',
      () async {
        // arrange
        const tName = 'My New List';
        const tDescription = 'Test description';
        dioAdapter.onPost(
          '/kanji-lists',
          (server) => server.reply(201, tKanjiListByIdJson),
          data: {'name': tName, 'description': tDescription},
        );

        // assert later - POST returns created list with items
        final expected = [KanjiListLoading(), KanjiListCreated(tKanjiListById)];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(
          const CreateKanjiListEvent(name: tName, description: tDescription),
        );
      },
    );

    test('should emit [Loading, Created] with kanji IDs', () async {
      // arrange
      const tName = 'List with Kanji';
      final tKanjiIds = [1, 2, 3];
      dioAdapter.onPost(
        '/kanji-lists',
        (server) => server.reply(201, tKanjiListByIdJson),
        data: {'name': tName, 'kanjiIds': tKanjiIds},
      );

      // assert later - POST returns created list with items
      final expected = [KanjiListLoading(), KanjiListCreated(tKanjiListById)];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(CreateKanjiListEvent(name: tName, kanjiIds: tKanjiIds));
    });

    test('should emit [Loading, Error] when name is invalid', () async {
      // arrange
      const tName = '';
      dioAdapter.onPost(
        '/kanji-lists',
        (server) => server.reply(400, {'message': 'Invalid request'}),
        data: {'name': tName},
      );

      // assert later
      final expected = [
        KanjiListLoading(),
        isA<KanjiListError>().having(
          (e) => e.message,
          'message',
          contains('cannot be empty'),
        ),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(const CreateKanjiListEvent(name: tName));
    });
  });

  group('UpdateKanjiListEvent Integration', () {
    test(
      'should emit [Loading, Updated] when updating list successfully',
      () async {
        // arrange
        const tId = 1;
        const tName = 'Updated Name';
        dioAdapter.onPut(
          '/kanji-lists/$tId',
          (server) => server.reply(200, tKanjiListByIdJson),
          data: {'name': tName},
        );

        // assert later - PUT returns updated list with items
        final expected = [KanjiListLoading(), KanjiListUpdated(tKanjiListById)];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const UpdateKanjiListEvent(id: tId, name: tName));
      },
    );

    test('should emit [Loading, Updated] with all fields', () async {
      // arrange
      const tId = 1;
      const tName = 'New Name';
      const tDescription = 'New description';
      const tIsPublic = true;
      dioAdapter.onPut(
        '/kanji-lists/$tId',
        (server) => server.reply(200, tKanjiListByIdJson),
        data: {
          'name': tName,
          'description': tDescription,
          'isPublic': tIsPublic,
        },
      );

      // assert later - PUT returns updated list with items
      final expected = [KanjiListLoading(), KanjiListUpdated(tKanjiListById)];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(
        const UpdateKanjiListEvent(
          id: tId,
          name: tName,
          description: tDescription,
          isPublic: tIsPublic,
        ),
      );
    });

    test('should emit [Loading, Error] when no fields provided', () async {
      // arrange
      const tId = 1;

      // assert later
      final expected = [
        KanjiListLoading(),
        isA<KanjiListError>().having(
          (e) => e.message,
          'message',
          contains('At least one field must be provided'),
        ),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(const UpdateKanjiListEvent(id: tId));
    });
  });

  group('DeleteKanjiListEvent Integration', () {
    test(
      'should emit [Loading, Deleted] when deleting list successfully',
      () async {
        // arrange
        const tId = 1;
        dioAdapter.onDelete(
          '/kanji-lists/$tId',
          (server) => server.reply(204, null),
        );

        // assert later
        final expected = [KanjiListLoading(), const KanjiListDeleted(tId)];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const DeleteKanjiListEvent(tId));
      },
    );

    test('should emit [Loading, Error] when unauthorized', () async {
      // arrange
      const tId = 1;
      dioAdapter.onDelete(
        '/kanji-lists/$tId',
        (server) => server.reply(401, {'message': 'Unauthorized'}),
      );

      // assert later
      final expected = [
        KanjiListLoading(),
        isA<KanjiListError>().having(
          (e) => e.message,
          'message',
          contains('Unauthorized'),
        ),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(const DeleteKanjiListEvent(tId));
    });
  });

  group('AddKanjiToListEvent Integration', () {
    test(
      'should emit [Loading, KanjiAdded] when adding kanji successfully',
      () async {
        // arrange
        const tListId = 1;
        const tKanjiId = 100;
        dioAdapter.onPost(
          '/kanji-lists/$tListId/kanji/$tKanjiId',
          (server) => server.reply(200, tKanjiListByIdJson),
        );

        // assert later - POST returns updated list with items
        final expected = [KanjiListLoading(), KanjiAddedToList(tKanjiListById)];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const AddKanjiToListEvent(listId: tListId, kanjiId: tKanjiId));
      },
    );

    test('should emit [Loading, Error] when kanji not found', () async {
      // arrange
      const tListId = 1;
      const tKanjiId = 999;
      dioAdapter.onPost(
        '/kanji-lists/$tListId/kanji/$tKanjiId',
        (server) => server.reply(404, {'message': 'Kanji not found'}),
      );

      // assert later
      final expected = [
        KanjiListLoading(),
        isA<KanjiListError>().having(
          (e) => e.message,
          'message',
          contains('not found'),
        ),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(const AddKanjiToListEvent(listId: tListId, kanjiId: tKanjiId));
    });
  });

  group('RemoveKanjiFromListEvent Integration', () {
    test(
      'should emit [Loading, KanjiRemoved] when removing kanji successfully',
      () async {
        // arrange
        const tListId = 1;
        const tKanjiId = 100;
        dioAdapter.onDelete(
          '/kanji-lists/$tListId/kanji/$tKanjiId',
          (server) => server.reply(200, tKanjiListByIdJson),
        );

        // assert later - DELETE returns updated list with items
        final expected = [
          KanjiListLoading(),
          KanjiRemovedFromList(tKanjiListById),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(
          const RemoveKanjiFromListEvent(listId: tListId, kanjiId: tKanjiId),
        );
      },
    );

    test('should emit [Loading, Error] when kanji not in list', () async {
      // arrange
      const tListId = 1;
      const tKanjiId = 999;
      dioAdapter.onDelete(
        '/kanji-lists/$tListId/kanji/$tKanjiId',
        (server) =>
            server.reply(404, {'message': 'Kanji not found in this list'}),
      );

      // assert later
      final expected = [
        KanjiListLoading(),
        isA<KanjiListError>().having(
          (e) => e.message,
          'message',
          contains('not found'),
        ),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(
        const RemoveKanjiFromListEvent(listId: tListId, kanjiId: tKanjiId),
      );
    });
  });

  group('FilterByJlptEvent Integration', () {
    test(
      'should emit [Loading, Loaded] when filtering by JLPT successfully',
      () async {
        // arrange
        const tJlptLevel = 'N5';
        dioAdapter.onGet(
          '/kanji-lists/jlpt/$tJlptLevel',
          (server) => server.reply(200, tAllKanjiListsResponseJson),
        );

        // assert later - GET by JLPT returns lists without items
        final expected = [
          KanjiListLoading(),
          KanjiListsLoaded(tAllKanjiListsNoItems),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const FilterByJlptEvent(tJlptLevel));
      },
    );

    test(
      'should emit [Loading, Loaded] with empty list when no matches',
      () async {
        // arrange
        const tJlptLevel = 'N1';
        final emptyResponse = {
          'data': [],
          'total': 0,
          'limit': 20,
          'offset': 0,
        };
        dioAdapter.onGet(
          '/kanji-lists/jlpt/$tJlptLevel',
          (server) => server.reply(200, emptyResponse),
        );

        // assert later
        final expected = [KanjiListLoading(), const KanjiListsLoaded([])];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const FilterByJlptEvent(tJlptLevel));
      },
    );
  });
}
