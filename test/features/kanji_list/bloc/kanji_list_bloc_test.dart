import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kanji_flutter/features/kanji_list/services/kanji_list_service.dart';
import 'package:kanji_flutter/features/kanji_list/bloc/kanji_list_bloc.dart';
import 'package:kanji_flutter/features/kanji_list/bloc/kanji_list_event.dart';
import 'package:kanji_flutter/features/kanji_list/bloc/kanji_list_state.dart';
import 'package:kanji_flutter/features/kanji_list/models/kanji_list.dart';
import 'package:kanji_flutter/features/kanji_list/models/kanji_list_exception.dart';

@GenerateMocks([KanjiListService])
import 'kanji_list_bloc_test.mocks.dart';

void main() {
  late KanjiListBloc kanjiListBloc;
  late MockKanjiListService mockKanjiListService;

  setUp(() {
    mockKanjiListService = MockKanjiListService();
    kanjiListBloc = KanjiListBloc(kanjiListService: mockKanjiListService);
  });

  tearDown(() {
    kanjiListBloc.close();
  });

  final testSystemList = KanjiList(
    id: 1,
    name: 'JLPT N5',
    description: 'N5 kanji list',
    type: 'SYSTEM',
    level: 'N5',
    kanjiCount: 80,
    userId: null,
    createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
    updatedAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
  );

  final testCustomList = KanjiList(
    id: 2,
    name: 'My Custom List',
    description: 'Personal study list',
    type: 'CUSTOM',
    level: null,
    kanjiCount: 25,
    userId: 123,
    createdAt: DateTime.parse('2025-01-15T00:00:00.000Z'),
    updatedAt: DateTime.parse('2025-01-15T00:00:00.000Z'),
  );

  final testKanji = {
    'id': 1,
    'character': '一',
    'jlptLevel': 'N5',
    'meanings': ['one'],
  };

  group('KanjiListBloc Tests', () {
    group('KanjiListLoadRequested', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'should emit [Loading, ListsLoaded] when load succeeds',
        build: () {
          when(
            mockKanjiListService.getKanjiLists(),
          ).thenAnswer((_) async => [testSystemList, testCustomList]);
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(KanjiListLoadRequested()),
        expect: () => [
          KanjiListLoading(),
          isA<KanjiListsLoaded>()
              .having((s) => s.systemLists.length, 'system lists length', 1)
              .having((s) => s.customLists.length, 'custom lists length', 1)
              .having((s) => s.systemLists.first.level, 'first level', 'N5')
              .having((s) => s.customLists.first.type, 'first type', 'CUSTOM'),
        ],
        verify: (_) {
          verify(mockKanjiListService.getKanjiLists()).called(1);
        },
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'should emit [Loading, Error] when load fails',
        build: () {
          when(
            mockKanjiListService.getKanjiLists(),
          ).thenThrow(KanjiListException('Failed to load'));
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(KanjiListLoadRequested()),
        expect: () => [
          KanjiListLoading(),
          isA<KanjiListError>().having(
            (s) => s.message,
            'message',
            'Failed to load',
          ),
        ],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'should sort system lists by JLPT level (N5->N1)',
        build: () {
          final n1List = KanjiList(
            id: 5,
            name: 'JLPT N1',
            description: 'N1 list',
            type: 'SYSTEM',
            level: 'N1',
            kanjiCount: 1000,
            userId: null,
            createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
            updatedAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
          );
          final n3List = KanjiList(
            id: 3,
            name: 'JLPT N3',
            description: 'N3 list',
            type: 'SYSTEM',
            level: 'N3',
            kanjiCount: 350,
            userId: null,
            createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
            updatedAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
          );

          // Return in random order
          when(
            mockKanjiListService.getKanjiLists(),
          ).thenAnswer((_) async => [n1List, testSystemList, n3List]);
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(KanjiListLoadRequested()),
        expect: () => [
          KanjiListLoading(),
          isA<KanjiListsLoaded>().having(
            (s) {
              final levels = s.systemLists.map((l) => l.level).toList();
              return levels;
            },
            'sorted levels',
            ['N5', 'N3', 'N1'], // Should be sorted N5 -> N1
          ),
        ],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'should sort custom lists by creation date (newest first)',
        build: () {
          final olderList = KanjiList(
            id: 3,
            name: 'Older List',
            description: 'desc',
            type: 'CUSTOM',
            level: null,
            kanjiCount: 10,
            userId: 123,
            createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
            updatedAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
          );

          // Return older first, newer second
          when(
            mockKanjiListService.getKanjiLists(),
          ).thenAnswer((_) async => [olderList, testCustomList]);
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(KanjiListLoadRequested()),
        expect: () => [
          KanjiListLoading(),
          isA<KanjiListsLoaded>().having(
            (s) => s.customLists.first.id,
            'first list id',
            2, // testCustomList (newer) should be first
          ),
        ],
      );
    });

    group('KanjiListDetailRequested', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'should emit [Loading, DetailLoaded] when detail load succeeds',
        build: () {
          when(mockKanjiListService.getKanjiListById(1)).thenAnswer(
            (_) async => {
              'list': testSystemList,
              'kanjis': [testKanji],
            },
          );
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(const KanjiListDetailRequested(1)),
        expect: () => [
          KanjiListLoading(),
          isA<KanjiListDetailLoaded>()
              .having((s) => s.list.id, 'list id', 1)
              .having((s) => s.kanjiItems.length, 'kanji items length', 1),
        ],
        verify: (_) {
          verify(mockKanjiListService.getKanjiListById(1)).called(1);
        },
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'should emit [Loading, Error] when detail load fails',
        build: () {
          when(
            mockKanjiListService.getKanjiListById(999),
          ).thenThrow(KanjiListException('Kanji list not found'));
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(const KanjiListDetailRequested(999)),
        expect: () => [
          KanjiListLoading(),
          isA<KanjiListError>().having(
            (s) => s.message,
            'message',
            'Kanji list not found',
          ),
        ],
      );
    });

    group('KanjiListCreateRequested', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'should emit [Loading, OperationSuccess, Loading, ListsLoaded] when create succeeds',
        build: () {
          when(
            mockKanjiListService.createKanjiList(
              name: anyNamed('name'),
              description: anyNamed('description'),
            ),
          ).thenAnswer((_) async => testCustomList);
          when(
            mockKanjiListService.getKanjiLists(),
          ).thenAnswer((_) async => [testCustomList]);
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(
          const KanjiListCreateRequested(
            name: 'My Custom List',
            description: 'Personal study list',
          ),
        ),
        expect: () => [
          KanjiListLoading(),
          isA<KanjiListOperationSuccess>().having(
            (s) => s.message,
            'message',
            'List created successfully',
          ),
          KanjiListLoading(),
          isA<KanjiListsLoaded>().having(
            (s) => s.customLists.length,
            'custom lists',
            1,
          ),
        ],
        verify: (_) {
          verify(
            mockKanjiListService.createKanjiList(
              name: 'My Custom List',
              description: 'Personal study list',
            ),
          ).called(1);
          verify(mockKanjiListService.getKanjiLists()).called(1);
        },
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'should emit [Loading, Error] when create fails',
        build: () {
          when(
            mockKanjiListService.createKanjiList(
              name: anyNamed('name'),
              description: anyNamed('description'),
            ),
          ).thenThrow(KanjiListException('Name must be at least 3 characters'));
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(
          const KanjiListCreateRequested(name: 'ab', description: 'desc'),
        ),
        expect: () => [
          KanjiListLoading(),
          isA<KanjiListError>().having(
            (s) => s.message,
            'message',
            'Name must be at least 3 characters',
          ),
        ],
      );
    });

    group('KanjiListUpdateRequested', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'should emit [Loading, OperationSuccess, Loading, ListsLoaded] when update succeeds',
        build: () {
          final updatedList = KanjiList(
            id: 2,
            name: 'Updated Name',
            description: 'Updated description',
            type: 'CUSTOM',
            level: null,
            kanjiCount: 25,
            userId: 123,
            createdAt: DateTime.parse('2025-01-15T00:00:00.000Z'),
            updatedAt: DateTime.parse('2025-01-16T00:00:00.000Z'),
          );

          when(
            mockKanjiListService.updateKanjiList(
              id: anyNamed('id'),
              name: anyNamed('name'),
              description: anyNamed('description'),
            ),
          ).thenAnswer((_) async => updatedList);
          when(
            mockKanjiListService.getKanjiLists(),
          ).thenAnswer((_) async => [updatedList]);
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(
          const KanjiListUpdateRequested(
            listId: 2,
            name: 'Updated Name',
            description: 'Updated description',
          ),
        ),
        expect: () => [
          KanjiListLoading(),
          isA<KanjiListOperationSuccess>().having(
            (s) => s.message,
            'message',
            'List updated successfully',
          ),
          KanjiListLoading(),
          isA<KanjiListsLoaded>(),
        ],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'should emit Error when updating system list',
        build: () {
          when(
            mockKanjiListService.updateKanjiList(
              id: anyNamed('id'),
              name: anyNamed('name'),
              description: anyNamed('description'),
            ),
          ).thenThrow(KanjiListException('Cannot modify system list'));
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(
          const KanjiListUpdateRequested(
            listId: 1,
            name: 'New Name',
            description: 'desc',
          ),
        ),
        expect: () => [
          KanjiListLoading(),
          isA<KanjiListError>().having(
            (s) => s.message,
            'message',
            'Cannot modify system list',
          ),
        ],
      );
    });

    group('KanjiListDeleteRequested', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'should emit [Loading, OperationSuccess, Loading, ListsLoaded] when delete succeeds',
        build: () {
          when(
            mockKanjiListService.deleteKanjiList(2),
          ).thenAnswer((_) async => {});
          when(
            mockKanjiListService.getKanjiLists(),
          ).thenAnswer((_) async => []);
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(const KanjiListDeleteRequested(2)),
        expect: () => [
          KanjiListLoading(),
          isA<KanjiListOperationSuccess>().having(
            (s) => s.message,
            'message',
            'List deleted successfully',
          ),
          KanjiListLoading(),
          isA<KanjiListsLoaded>().having(
            (s) => s.customLists.length,
            'custom lists',
            0,
          ),
        ],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'should emit Error when deleting system list',
        build: () {
          when(
            mockKanjiListService.deleteKanjiList(1),
          ).thenThrow(KanjiListException('Cannot delete system list'));
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(const KanjiListDeleteRequested(1)),
        expect: () => [
          KanjiListLoading(),
          isA<KanjiListError>().having(
            (s) => s.message,
            'message',
            'Cannot delete system list',
          ),
        ],
      );
    });

    group('KanjiAddToListRequested', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'should emit OperationSuccess when add succeeds',
        build: () {
          when(
            mockKanjiListService.addKanjiToList(
              listId: anyNamed('listId'),
              kanjiId: anyNamed('kanjiId'),
            ),
          ).thenAnswer((_) async => {});
          return kanjiListBloc;
        },
        act: (bloc) =>
            bloc.add(const KanjiAddToListRequested(listId: 2, kanjiId: 1)),
        expect: () => [
          isA<KanjiListOperationSuccess>().having(
            (s) => s.message,
            'message',
            'Kanji added to list',
          ),
        ],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'should emit Error when kanji already in list',
        build: () {
          when(
            mockKanjiListService.addKanjiToList(
              listId: anyNamed('listId'),
              kanjiId: anyNamed('kanjiId'),
            ),
          ).thenThrow(KanjiListException('Kanji already in list'));
          return kanjiListBloc;
        },
        act: (bloc) =>
            bloc.add(const KanjiAddToListRequested(listId: 2, kanjiId: 1)),
        expect: () => [
          isA<KanjiListError>().having(
            (s) => s.message,
            'message',
            'Kanji already in list',
          ),
        ],
      );
    });

    group('KanjiRemoveFromListRequested', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'should emit OperationSuccess when remove succeeds',
        build: () {
          when(
            mockKanjiListService.removeKanjiFromList(
              listId: anyNamed('listId'),
              kanjiId: anyNamed('kanjiId'),
            ),
          ).thenAnswer((_) async => {});
          return kanjiListBloc;
        },
        act: (bloc) =>
            bloc.add(const KanjiRemoveFromListRequested(listId: 2, kanjiId: 1)),
        expect: () => [
          isA<KanjiListOperationSuccess>().having(
            (s) => s.message,
            'message',
            'Kanji removed from list',
          ),
        ],
      );

      blocTest<KanjiListBloc, KanjiListState>(
        'should emit Error when kanji not in list',
        build: () {
          when(
            mockKanjiListService.removeKanjiFromList(
              listId: anyNamed('listId'),
              kanjiId: anyNamed('kanjiId'),
            ),
          ).thenThrow(KanjiListException('Kanji not found in list'));
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(
          const KanjiRemoveFromListRequested(listId: 2, kanjiId: 999),
        ),
        expect: () => [
          isA<KanjiListError>().having(
            (s) => s.message,
            'message',
            'Kanji not found in list',
          ),
        ],
      );
    });

    group('KanjiListRefreshRequested', () {
      blocTest<KanjiListBloc, KanjiListState>(
        'should reload lists when refresh is requested',
        build: () {
          when(
            mockKanjiListService.getKanjiLists(),
          ).thenAnswer((_) async => [testSystemList]);
          return kanjiListBloc;
        },
        act: (bloc) => bloc.add(KanjiListRefreshRequested()),
        expect: () => [
          KanjiListLoading(),
          isA<KanjiListsLoaded>().having(
            (s) => s.systemLists.length,
            'system lists',
            1,
          ),
        ],
      );
    });
  });
}
