import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kanji_flutter/features/kanji_list/domain/entities/kanji_list_entity.dart';
import 'package:kanji_flutter/features/kanji_list/domain/entities/kanji_list_exception.dart';
import 'package:kanji_flutter/features/kanji_list/domain/usecases/add_kanji_to_list_usecase.dart';
import 'package:kanji_flutter/features/kanji_list/domain/usecases/approve_publish_request_usecase.dart';
import 'package:kanji_flutter/features/kanji_list/domain/usecases/create_list_usecase.dart';
import 'package:kanji_flutter/features/kanji_list/domain/usecases/delete_list_usecase.dart';
import 'package:kanji_flutter/features/kanji_list/domain/usecases/get_all_lists_usecase.dart';
import 'package:kanji_flutter/features/kanji_list/domain/usecases/get_list_by_id_usecase.dart';
import 'package:kanji_flutter/features/kanji_list/domain/usecases/get_publish_requests_usecase.dart';
import 'package:kanji_flutter/features/kanji_list/domain/usecases/reject_publish_request_usecase.dart';
import 'package:kanji_flutter/features/kanji_list/domain/usecases/remove_kanji_from_list_usecase.dart';
import 'package:kanji_flutter/features/kanji_list/domain/usecases/request_publish_list_usecase.dart';
import 'package:kanji_flutter/features/kanji_list/domain/usecases/update_list_usecase.dart';
import 'package:kanji_flutter/features/kanji_list/presentation/bloc/kanji_list_bloc.dart';
import 'package:kanji_flutter/features/kanji_list/presentation/bloc/kanji_list_event.dart';
import 'package:kanji_flutter/features/kanji_list/presentation/bloc/kanji_list_state.dart';

import 'kanji_list_bloc_test.mocks.dart';

@GenerateMocks([
  GetAllListsUseCase,
  GetListByIdUseCase,
  CreateListUseCase,
  UpdateListUseCase,
  DeleteListUseCase,
  AddKanjiToListUseCase,
  RemoveKanjiFromListUseCase,
  RequestPublishListUseCase,
  GetPublishRequestsUseCase,
  ApprovePublishRequestUseCase,
  RejectPublishRequestUseCase,
])
void main() {
  late KanjiListBloc kanjiListBloc;
  late MockGetAllListsUseCase mockGetAllListsUseCase;
  late MockGetListByIdUseCase mockGetListByIdUseCase;
  late MockCreateListUseCase mockCreateListUseCase;
  late MockUpdateListUseCase mockUpdateListUseCase;
  late MockDeleteListUseCase mockDeleteListUseCase;
  late MockAddKanjiToListUseCase mockAddKanjiToListUseCase;
  late MockRemoveKanjiFromListUseCase mockRemoveKanjiFromListUseCase;
  late MockRequestPublishListUseCase mockRequestPublishListUseCase;
  late MockGetPublishRequestsUseCase mockGetPublishRequestsUseCase;
  late MockApprovePublishRequestUseCase mockApprovePublishRequestUseCase;
  late MockRejectPublishRequestUseCase mockRejectPublishRequestUseCase;

  setUp(() {
    mockGetAllListsUseCase = MockGetAllListsUseCase();
    mockGetListByIdUseCase = MockGetListByIdUseCase();
    mockCreateListUseCase = MockCreateListUseCase();
    mockUpdateListUseCase = MockUpdateListUseCase();
    mockDeleteListUseCase = MockDeleteListUseCase();
    mockAddKanjiToListUseCase = MockAddKanjiToListUseCase();
    mockRemoveKanjiFromListUseCase = MockRemoveKanjiFromListUseCase();
    mockRequestPublishListUseCase = MockRequestPublishListUseCase();
    mockGetPublishRequestsUseCase = MockGetPublishRequestsUseCase();
    mockApprovePublishRequestUseCase = MockApprovePublishRequestUseCase();
    mockRejectPublishRequestUseCase = MockRejectPublishRequestUseCase();

    kanjiListBloc = KanjiListBloc(
      getAllListsUseCase: mockGetAllListsUseCase,
      getListByIdUseCase: mockGetListByIdUseCase,
      createListUseCase: mockCreateListUseCase,
      updateListUseCase: mockUpdateListUseCase,
      deleteListUseCase: mockDeleteListUseCase,
      addKanjiToListUseCase: mockAddKanjiToListUseCase,
      removeKanjiFromListUseCase: mockRemoveKanjiFromListUseCase,
      requestPublishListUseCase: mockRequestPublishListUseCase,
      getPublishRequestsUseCase: mockGetPublishRequestsUseCase,
      approvePublishRequestUseCase: mockApprovePublishRequestUseCase,
      rejectPublishRequestUseCase: mockRejectPublishRequestUseCase,
    );
  });

  tearDown(() {
    kanjiListBloc.close();
  });

  final tList = KanjiListEntity(
    id: 1,
    name: 'N5 Kanji',
    description: 'JLPT N5 kanji list',
    userId: 1,
    isPublic: true,
    totalKanji: 3,
    createAt: DateTime(2024, 1, 1),
    updateAt: DateTime(2024, 1, 1),
  );

  final tLists = [tList];

  group('KanjiListBloc', () {
    test('initial state is KanjiListInitial', () {
      expect(kanjiListBloc.state, KanjiListInitial());
    });

    group('LoadAllListsEvent', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, ListsLoaded] when loading succeeds',
        build: () {
          when(
            mockGetAllListsUseCase.call(
              search: anyNamed('search'),
              type: anyNamed('type'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset'),
            ),
          ).thenAnswer((_) async => tLists);
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(LoadAllListsEvent()),
        expect: () => [
          KanjiListLoading(),
          isA<ListsLoaded>().having((s) => s.lists, 'lists', tLists),
        ],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, ListsLoaded] with search filter',
        build: () {
          when(
            mockGetAllListsUseCase.call(
              search: anyNamed('search'),
              type: anyNamed('type'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset'),
            ),
          ).thenAnswer((_) async => tLists);
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(LoadAllListsEvent(search: 'N5')),
        expect: () => [
          KanjiListLoading(),
          isA<ListsLoaded>().having(
            (s) => s.appliedSearch,
            'appliedSearch',
            'N5',
          ),
        ],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, ListsLoaded] with type filter',
        build: () {
          when(
            mockGetAllListsUseCase.call(
              search: anyNamed('search'),
              type: anyNamed('type'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset'),
            ),
          ).thenAnswer((_) async => tLists);
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(LoadAllListsEvent(type: 'custom')),
        expect: () => [
          KanjiListLoading(),
          isA<ListsLoaded>().having(
            (s) => s.appliedType,
            'appliedType',
            'custom',
          ),
        ],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, KanjiListError] when loading fails',
        build: () {
          when(
            mockGetAllListsUseCase.call(
              search: anyNamed('search'),
              type: anyNamed('type'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset'),
            ),
          ).thenThrow(KanjiListException('Network error'));
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(LoadAllListsEvent()),
        expect: () => [KanjiListLoading(), KanjiListError('Network error')],
      );
    });

    group('LoadListByIdEvent', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, ListDetailLoaded] when loading by ID succeeds',
        build: () {
          when(mockGetListByIdUseCase.call(any)).thenAnswer((_) async => tList);
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(LoadListByIdEvent(1)),
        expect: () => [KanjiListLoading(), ListDetailLoaded(tList)],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, KanjiListError] when list not found',
        build: () {
          when(
            mockGetListByIdUseCase.call(any),
          ).thenThrow(KanjiListException('List not found'));
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(LoadListByIdEvent(999)),
        expect: () => [KanjiListLoading(), KanjiListError('List not found')],
      );
    });

    group('CreateListEvent', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, ListCreated] when creation succeeds',
        build: () {
          when(
            mockCreateListUseCase.call(
              name: anyNamed('name'),
              description: anyNamed('description'),
              kanjiIds: anyNamed('kanjiIds'),
            ),
          ).thenAnswer((_) async => tList);
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(
          CreateListEvent(
            name: 'My List',
            description: 'Test list',
            kanjiIds: const [1, 2],
          ),
        ),
        expect: () => [KanjiListLoading(), ListCreated(tList)],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, KanjiListError] when creation fails',
        build: () {
          when(
            mockCreateListUseCase.call(
              name: anyNamed('name'),
              description: anyNamed('description'),
              kanjiIds: anyNamed('kanjiIds'),
            ),
          ).thenThrow(KanjiListException('Failed to create list'));
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(
          CreateListEvent(name: 'My List', description: 'Test list'),
        ),
        expect: () => [
          KanjiListLoading(),
          KanjiListError('Failed to create list'),
        ],
      );
    });

    group('UpdateListEvent', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, ListUpdated] when update succeeds',
        build: () {
          when(
            mockUpdateListUseCase.call(
              id: anyNamed('id'),
              name: anyNamed('name'),
              description: anyNamed('description'),
              isPublic: anyNamed('isPublic'),
            ),
          ).thenAnswer((_) async => tList);
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(
          UpdateListEvent(
            id: 1,
            name: 'Updated List',
            description: 'Updated description',
            isPublic: true,
          ),
        ),
        expect: () => [KanjiListLoading(), ListUpdated(tList)],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, KanjiListError] when update fails - unauthorized',
        build: () {
          when(
            mockUpdateListUseCase.call(
              id: anyNamed('id'),
              name: anyNamed('name'),
              description: anyNamed('description'),
              isPublic: anyNamed('isPublic'),
            ),
          ).thenThrow(KanjiListException('Unauthorized'));
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(UpdateListEvent(id: 1, name: 'Updated List')),
        expect: () => [KanjiListLoading(), KanjiListError('Unauthorized')],
      );
    });

    group('DeleteListEvent', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, ListDeleted] when deletion succeeds',
        build: () {
          when(mockDeleteListUseCase.call(any)).thenAnswer((_) async => {});
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(DeleteListEvent(1)),
        expect: () => [KanjiListLoading(), ListDeleted()],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, KanjiListError] when deletion fails',
        build: () {
          when(
            mockDeleteListUseCase.call(any),
          ).thenThrow(KanjiListException('Cannot delete system list'));
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(DeleteListEvent(1)),
        expect: () => [
          KanjiListLoading(),
          KanjiListError('Cannot delete system list'),
        ],
      );
    });

    group('AddKanjiToListEvent', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, KanjiAddedToList] when adding succeeds',
        build: () {
          when(
            mockAddKanjiToListUseCase.call(
              listId: anyNamed('listId'),
              kanjiId: anyNamed('kanjiId'),
            ),
          ).thenAnswer((_) async => {});
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(AddKanjiToListEvent(listId: 1, kanjiId: 10)),
        expect: () => [KanjiListLoading(), KanjiAddedToList()],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, KanjiListError] when kanji already in list',
        build: () {
          when(
            mockAddKanjiToListUseCase.call(
              listId: anyNamed('listId'),
              kanjiId: anyNamed('kanjiId'),
            ),
          ).thenThrow(KanjiListException('Kanji already in list'));
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(AddKanjiToListEvent(listId: 1, kanjiId: 10)),
        expect: () => [
          KanjiListLoading(),
          KanjiListError('Kanji already in list'),
        ],
      );
    });

    group('RemoveKanjiFromListEvent', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, KanjiRemovedFromList] when removal succeeds',
        build: () {
          when(
            mockRemoveKanjiFromListUseCase.call(
              listId: anyNamed('listId'),
              kanjiId: anyNamed('kanjiId'),
            ),
          ).thenAnswer((_) async => {});
          return kanjiListBloc;
        },
        act: (bloc) =>
            bloc.add(RemoveKanjiFromListEvent(listId: 1, kanjiId: 10)),
        expect: () => [KanjiListLoading(), KanjiRemovedFromList()],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, KanjiListError] when removal fails',
        build: () {
          when(
            mockRemoveKanjiFromListUseCase.call(
              listId: anyNamed('listId'),
              kanjiId: anyNamed('kanjiId'),
            ),
          ).thenThrow(KanjiListException('Kanji not in list'));
          return kanjiListBloc;
        },
        act: (bloc) =>
            bloc.add(RemoveKanjiFromListEvent(listId: 1, kanjiId: 10)),
        expect: () => [KanjiListLoading(), KanjiListError('Kanji not in list')],
      );
    });

    group('RequestPublishListEvent', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, PublishRequested] when request succeeds',
        build: () {
          when(
            mockRequestPublishListUseCase.call(any),
          ).thenAnswer((_) async => {});
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(RequestPublishListEvent(1)),
        expect: () => [KanjiListLoading(), PublishRequested()],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, KanjiListError] when request fails',
        build: () {
          when(
            mockRequestPublishListUseCase.call(any),
          ).thenThrow(KanjiListException('List already published'));
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(RequestPublishListEvent(1)),
        expect: () => [
          KanjiListLoading(),
          KanjiListError('List already published'),
        ],
      );
    });

    group('RefreshListsEvent', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'emits [KanjiListLoading, ListsLoaded] when refresh succeeds',
        build: () {
          when(
            mockGetAllListsUseCase.call(
              search: anyNamed('search'),
              type: anyNamed('type'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset'),
            ),
          ).thenAnswer((_) async => tLists);
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(RefreshListsEvent()),
        expect: () => [KanjiListLoading(), isA<ListsLoaded>()],
      );
    });
  });
}
