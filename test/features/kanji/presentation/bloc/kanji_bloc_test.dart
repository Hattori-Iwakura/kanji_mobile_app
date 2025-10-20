import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kanji_flutter/features/kanji/domain/entities/kanji_entity.dart';
import 'package:kanji_flutter/features/kanji/domain/entities/kanji_exception.dart';
import 'package:kanji_flutter/features/kanji/domain/usecases/create_kanji_usecase.dart';
import 'package:kanji_flutter/features/kanji/domain/usecases/delete_kanji_usecase.dart';
import 'package:kanji_flutter/features/kanji/domain/usecases/get_kanji_by_character_usecase.dart';
import 'package:kanji_flutter/features/kanji/domain/usecases/get_kanji_by_id_usecase.dart';
import 'package:kanji_flutter/features/kanji/domain/usecases/get_kanji_list_usecase.dart';
import 'package:kanji_flutter/features/kanji/domain/usecases/update_kanji_usecase.dart';
import 'package:kanji_flutter/features/kanji/presentation/bloc/kanji_bloc.dart';
import 'package:kanji_flutter/features/kanji/presentation/bloc/kanji_event.dart';
import 'package:kanji_flutter/features/kanji/presentation/bloc/kanji_state.dart';

import 'kanji_bloc_test.mocks.dart';

@GenerateMocks([
  GetKanjiListUseCase,
  GetKanjiByIdUseCase,
  GetKanjiByCharacterUseCase,
  CreateKanjiUseCase,
  UpdateKanjiUseCase,
  DeleteKanjiUseCase,
])
void main() {
  late KanjiBloc kanjiBloc;
  late MockGetKanjiListUseCase mockGetKanjiListUseCase;
  late MockGetKanjiByIdUseCase mockGetKanjiByIdUseCase;
  late MockGetKanjiByCharacterUseCase mockGetKanjiByCharacterUseCase;
  late MockCreateKanjiUseCase mockCreateKanjiUseCase;
  late MockUpdateKanjiUseCase mockUpdateKanjiUseCase;
  late MockDeleteKanjiUseCase mockDeleteKanjiUseCase;

  setUp(() {
    mockGetKanjiListUseCase = MockGetKanjiListUseCase();
    mockGetKanjiByIdUseCase = MockGetKanjiByIdUseCase();
    mockGetKanjiByCharacterUseCase = MockGetKanjiByCharacterUseCase();
    mockCreateKanjiUseCase = MockCreateKanjiUseCase();
    mockUpdateKanjiUseCase = MockUpdateKanjiUseCase();
    mockDeleteKanjiUseCase = MockDeleteKanjiUseCase();

    kanjiBloc = KanjiBloc(
      getKanjiListUseCase: mockGetKanjiListUseCase,
      getKanjiByIdUseCase: mockGetKanjiByIdUseCase,
      getKanjiByCharacterUseCase: mockGetKanjiByCharacterUseCase,
      createKanjiUseCase: mockCreateKanjiUseCase,
      updateKanjiUseCase: mockUpdateKanjiUseCase,
      deleteKanjiUseCase: mockDeleteKanjiUseCase,
    );
  });

  tearDown(() {
    kanjiBloc.close();
  });

  final tKanji = KanjiEntity(
    id: 1,
    character: '日',
    meanings: const ['sun', 'day'],
    onyomi: 'ニチ、ジツ',
    kunyomi: 'ひ、び、か',
    jlptLevel: 'N5',
    grade: 1,
    strokeCount: 4,
    frequency: 1,
    hanviet: 'nhật',
    meaningMnemonic: 'The sun',
    readingMnemonic: 'にち',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final tKanjiList = [tKanji];
  const tKanjiData = {
    'character': '日',
    'meanings': ['sun', 'day'],
    'onyomi': 'ニチ、ジツ',
    'kunyomi': 'ひ、び、か',
    'jlptLevel': 'N5',
    'grade': 1,
    'strokeCount': 4,
  };

  group('KanjiBloc', () {
    test('initial state is KanjiInitial', () {
      expect(kanjiBloc.state, KanjiInitial());
    });

    group('LoadKanjiListEvent', () {
      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiListLoaded] when loading list succeeds',
        build: () {
          when(
            mockGetKanjiListUseCase.call(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenAnswer((_) async => tKanjiList);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(LoadKanjiListEvent()),
        expect: () => [
          KanjiLoading(),
          KanjiListLoaded(
            kanjiList: tKanjiList,
            currentPage: 1,
            hasMore: false,
          ),
        ],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiListLoaded] with JLPT filter',
        build: () {
          when(
            mockGetKanjiListUseCase.call(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenAnswer((_) async => tKanjiList);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(LoadKanjiListEvent(jlptLevel: 'N5')),
        expect: () => [
          KanjiLoading(),
          KanjiListLoaded(
            kanjiList: tKanjiList,
            currentPage: 1,
            hasMore: false,
            appliedJlptFilter: 'N5',
          ),
        ],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiListLoaded] with grade filter',
        build: () {
          when(
            mockGetKanjiListUseCase.call(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenAnswer((_) async => tKanjiList);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(LoadKanjiListEvent(grade: 1)),
        expect: () => [
          KanjiLoading(),
          KanjiListLoaded(
            kanjiList: tKanjiList,
            currentPage: 1,
            hasMore: false,
            appliedGradeFilter: 1,
          ),
        ],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiListLoaded] with search query',
        build: () {
          when(
            mockGetKanjiListUseCase.call(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenAnswer((_) async => tKanjiList);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(LoadKanjiListEvent(search: 'sun')),
        expect: () => [
          KanjiLoading(),
          KanjiListLoaded(
            kanjiList: tKanjiList,
            currentPage: 1,
            hasMore: false,
            appliedSearch: 'sun',
          ),
        ],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiListLoaded] with pagination',
        build: () {
          when(
            mockGetKanjiListUseCase.call(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenAnswer((_) async => List.generate(20, (i) => tKanji));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(LoadKanjiListEvent(page: 2)),
        expect: () => [
          KanjiLoading(),
          isA<KanjiListLoaded>()
              .having((s) => s.currentPage, 'currentPage', 2)
              .having((s) => s.hasMore, 'hasMore', false),
        ],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when loading fails',
        build: () {
          when(
            mockGetKanjiListUseCase.call(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenThrow(KanjiException('Network error'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(LoadKanjiListEvent()),
        expect: () => [KanjiLoading(), KanjiError('Network error')],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when loading fails with generic error',
        build: () {
          when(
            mockGetKanjiListUseCase.call(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenThrow(Exception('Unknown error'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(LoadKanjiListEvent()),
        expect: () => [KanjiLoading(), KanjiError('Failed to load kanji list')],
      );
    });

    group('LoadKanjiByIdEvent', () {
      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiDetailLoaded] when loading by ID succeeds',
        build: () {
          when(
            mockGetKanjiByIdUseCase.call(any),
          ).thenAnswer((_) async => tKanji);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(LoadKanjiByIdEvent(1)),
        expect: () => [KanjiLoading(), KanjiDetailLoaded(tKanji)],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when kanji not found',
        build: () {
          when(
            mockGetKanjiByIdUseCase.call(any),
          ).thenThrow(KanjiException('Kanji not found'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(LoadKanjiByIdEvent(999)),
        expect: () => [KanjiLoading(), KanjiError('Kanji not found')],
      );
    });

    group('LoadKanjiByCharacterEvent', () {
      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiDetailLoaded] when loading by character succeeds',
        build: () {
          when(
            mockGetKanjiByCharacterUseCase.call(any),
          ).thenAnswer((_) async => tKanji);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(LoadKanjiByCharacterEvent('日')),
        expect: () => [KanjiLoading(), KanjiDetailLoaded(tKanji)],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when character not found',
        build: () {
          when(
            mockGetKanjiByCharacterUseCase.call(any),
          ).thenThrow(KanjiException('Kanji not found'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(LoadKanjiByCharacterEvent('X')),
        expect: () => [KanjiLoading(), KanjiError('Kanji not found')],
      );
    });

    group('CreateKanjiEvent', () {
      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiCreated] when creation succeeds',
        build: () {
          when(
            mockCreateKanjiUseCase.call(any),
          ).thenAnswer((_) async => tKanji);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(CreateKanjiEvent(tKanjiData)),
        expect: () => [KanjiLoading(), KanjiCreated(tKanji)],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when creation fails with duplicate',
        build: () {
          when(
            mockCreateKanjiUseCase.call(any),
          ).thenThrow(KanjiException('Kanji already exists'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(CreateKanjiEvent(tKanjiData)),
        expect: () => [KanjiLoading(), KanjiError('Kanji already exists')],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when creation fails with validation error',
        build: () {
          when(
            mockCreateKanjiUseCase.call(any),
          ).thenThrow(KanjiException('Invalid kanji data'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(CreateKanjiEvent(const {})),
        expect: () => [KanjiLoading(), KanjiError('Invalid kanji data')],
      );
    });

    group('UpdateKanjiEvent', () {
      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiUpdated] when update succeeds',
        build: () {
          when(
            mockUpdateKanjiUseCase.call(any, any),
          ).thenAnswer((_) async => tKanji);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(UpdateKanjiEvent(1, tKanjiData)),
        expect: () => [KanjiLoading(), KanjiUpdated(tKanji)],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when update fails - not found',
        build: () {
          when(
            mockUpdateKanjiUseCase.call(any, any),
          ).thenThrow(KanjiException('Kanji not found'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(UpdateKanjiEvent(999, tKanjiData)),
        expect: () => [KanjiLoading(), KanjiError('Kanji not found')],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when update fails - unauthorized',
        build: () {
          when(
            mockUpdateKanjiUseCase.call(any, any),
          ).thenThrow(KanjiException('Unauthorized'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(UpdateKanjiEvent(1, tKanjiData)),
        expect: () => [KanjiLoading(), KanjiError('Unauthorized')],
      );
    });

    group('DeleteKanjiEvent', () {
      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiDeleted] when deletion succeeds',
        build: () {
          when(mockDeleteKanjiUseCase.call(any)).thenAnswer((_) async => {});
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(DeleteKanjiEvent(1)),
        expect: () => [KanjiLoading(), KanjiDeleted()],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when deletion fails - not found',
        build: () {
          when(
            mockDeleteKanjiUseCase.call(any),
          ).thenThrow(KanjiException('Kanji not found'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(DeleteKanjiEvent(999)),
        expect: () => [KanjiLoading(), KanjiError('Kanji not found')],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when deletion fails - unauthorized',
        build: () {
          when(
            mockDeleteKanjiUseCase.call(any),
          ).thenThrow(KanjiException('Unauthorized'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(DeleteKanjiEvent(1)),
        expect: () => [KanjiLoading(), KanjiError('Unauthorized')],
      );
    });

    group('RefreshKanjiListEvent', () {
      blocTest<KanjiBloc, KanjiState>(
        'triggers LoadKanjiListEvent when refresh is requested',
        build: () {
          when(
            mockGetKanjiListUseCase.call(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenAnswer((_) async => tKanjiList);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(RefreshKanjiListEvent()),
        expect: () => [KanjiLoading(), isA<KanjiListLoaded>()],
      );
    });

    group('Multiple Events Sequence', () {
      blocTest<KanjiBloc, KanjiState>(
        'handles load list followed by load detail correctly',
        build: () {
          when(
            mockGetKanjiListUseCase.call(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenAnswer((_) async => tKanjiList);
          when(
            mockGetKanjiByIdUseCase.call(any),
          ).thenAnswer((_) async => tKanji);
          return kanjiBloc;
        },
        act: (bloc) {
          bloc.add(LoadKanjiListEvent());
          return Future.delayed(const Duration(milliseconds: 100), () {
            bloc.add(LoadKanjiByIdEvent(1));
          });
        },
        expect: () => [
          KanjiLoading(),
          isA<KanjiListLoaded>(),
          KanjiLoading(),
          KanjiDetailLoaded(tKanji),
        ],
      );
    });
  });
}
