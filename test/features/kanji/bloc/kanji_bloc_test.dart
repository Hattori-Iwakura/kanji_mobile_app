import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kanji_flutter/features/kanji/services/kanji_service.dart';
import 'package:kanji_flutter/features/kanji/bloc/kanji_bloc.dart';
import 'package:kanji_flutter/features/kanji/bloc/kanji_event.dart';
import 'package:kanji_flutter/features/kanji/bloc/kanji_state.dart';
import 'package:kanji_flutter/features/kanji/models/kanji.dart';
import 'package:kanji_flutter/features/kanji/models/kanji_exception.dart';

@GenerateMocks([KanjiService])
import 'kanji_bloc_test.mocks.dart';

void main() {
  late KanjiBloc kanjiBloc;
  late MockKanjiService mockKanjiService;

  setUp(() {
    mockKanjiService = MockKanjiService();
    kanjiBloc = KanjiBloc(kanjiService: mockKanjiService);
  });

  tearDown(() {
    kanjiBloc.close();
  });

  final testKanji = Kanji(
    id: 1,
    character: '一',
    jlptLevel: 'N5',
    grade: 1,
    strokeCount: 1,
    meanings: const ['one', 'first'],
    frequency: 2,
    onyomi: 'イチ、イツ',
    kunyomi: 'ひと、ひと.つ',
    hanviet: 'nhất',
    createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
    updatedAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
  );

  group('KanjiBloc Tests', () {
    group('KanjiLoadRequested', () {
      blocTest<KanjiBloc, KanjiState>(
        'should emit [KanjiLoading, KanjiListLoaded] when load succeeds',
        build: () {
          when(
            mockKanjiService.getKanjiList(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenAnswer((_) async => [testKanji]);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(KanjiLoadRequested()),
        expect: () => [
          KanjiLoading(),
          isA<KanjiListLoaded>()
              .having((s) => s.kanjiList.length, 'list length', 1)
              .having((s) => s.kanjiList.first.character, 'first kanji', '一')
              .having((s) => s.currentPage, 'current page', 1)
              .having((s) => s.hasMore, 'has more', false), // 1 < 50 = no more
        ],
        verify: (_) {
          verify(
            mockKanjiService.getKanjiList(
              page: 1,
              limit: 50,
              jlptLevel: null,
              grade: null,
              search: null,
            ),
          ).called(1);
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        'should emit [KanjiLoading, KanjiListLoaded] with filters',
        build: () {
          when(
            mockKanjiService.getKanjiList(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenAnswer((_) async => [testKanji]);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(
          KanjiLoadRequested(
            page: 2,
            limit: 100,
            jlptLevel: 'N5',
            grade: 1,
            search: 'one',
          ),
        ),
        expect: () => [
          KanjiLoading(),
          isA<KanjiListLoaded>()
              .having((s) => s.currentPage, 'current page', 2)
              .having((s) => s.appliedJlptFilter, 'jlpt filter', 'N5')
              .having((s) => s.appliedGradeFilter, 'grade filter', 1)
              .having((s) => s.appliedSearch, 'search', 'one'),
        ],
        verify: (_) {
          verify(
            mockKanjiService.getKanjiList(
              page: 2,
              limit: 100,
              jlptLevel: 'N5',
              grade: 1,
              search: 'one',
            ),
          ).called(1);
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        'should emit [KanjiLoading, KanjiListLoaded] with empty list',
        build: () {
          when(
            mockKanjiService.getKanjiList(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenAnswer((_) async => []);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(KanjiLoadRequested()),
        expect: () => [
          KanjiLoading(),
          isA<KanjiListLoaded>()
              .having((s) => s.kanjiList, 'list', isEmpty)
              .having((s) => s.hasMore, 'has more', false),
        ],
      );

      blocTest<KanjiBloc, KanjiState>(
        'should emit [KanjiLoading, KanjiError] when load fails with KanjiException',
        build: () {
          when(
            mockKanjiService.getKanjiList(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenThrow(KanjiException('Network error'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(KanjiLoadRequested()),
        expect: () => [
          KanjiLoading(),
          isA<KanjiError>().having(
            (s) => s.message,
            'error message',
            'Network error',
          ),
        ],
      );

      blocTest<KanjiBloc, KanjiState>(
        'should emit [KanjiLoading, KanjiError] when load fails with generic error',
        build: () {
          when(
            mockKanjiService.getKanjiList(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenThrow(Exception('Unexpected error'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(KanjiLoadRequested()),
        expect: () => [
          KanjiLoading(),
          isA<KanjiError>().having(
            (s) => s.message,
            'error message',
            'Failed to load kanji list',
          ),
        ],
      );
    });

    group('KanjiDetailRequested', () {
      blocTest<KanjiBloc, KanjiState>(
        'should emit [KanjiLoading, KanjiDetailLoaded] when detail load succeeds',
        build: () {
          when(
            mockKanjiService.getKanjiById(any),
          ).thenAnswer((_) async => testKanji);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(KanjiDetailRequested(1)),
        expect: () => [
          KanjiLoading(),
          isA<KanjiDetailLoaded>()
              .having((s) => s.kanji.id, 'kanji id', 1)
              .having((s) => s.kanji.character, 'kanji character', '一'),
        ],
        verify: (_) {
          verify(mockKanjiService.getKanjiById(1)).called(1);
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        'should emit [KanjiLoading, KanjiError] when detail load fails',
        build: () {
          when(
            mockKanjiService.getKanjiById(any),
          ).thenThrow(KanjiException('Kanji not found'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(KanjiDetailRequested(999)),
        expect: () => [
          KanjiLoading(),
          isA<KanjiError>().having(
            (s) => s.message,
            'error message',
            'Kanji not found',
          ),
        ],
      );
    });

    group('KanjiCreateRequested', () {
      blocTest<KanjiBloc, KanjiState>(
        'should emit [KanjiLoading, KanjiOperationSuccess] when create succeeds',
        build: () {
          when(
            mockKanjiService.createKanji(any),
          ).thenAnswer((_) async => testKanji);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(
          KanjiCreateRequested({
            'character': '二',
            'strokeCount': 2,
            'meanings': ['two'],
          }),
        ),
        expect: () => [
          KanjiLoading(),
          isA<KanjiOperationSuccess>().having(
            (s) => s.message,
            'success message',
            'Kanji created successfully',
          ),
        ],
        verify: (_) {
          verify(mockKanjiService.createKanji(any)).called(1);
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        'should emit [KanjiLoading, KanjiError] when create fails',
        build: () {
          when(
            mockKanjiService.createKanji(any),
          ).thenThrow(KanjiException('Invalid kanji data'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(KanjiCreateRequested({})),
        expect: () => [
          KanjiLoading(),
          isA<KanjiError>().having(
            (s) => s.message,
            'error message',
            'Invalid kanji data',
          ),
        ],
      );
    });

    group('KanjiUpdateRequested', () {
      blocTest<KanjiBloc, KanjiState>(
        'should emit [KanjiLoading, KanjiOperationSuccess] when update succeeds',
        build: () {
          when(
            mockKanjiService.updateKanji(any, any),
          ).thenAnswer((_) async => testKanji);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(
          KanjiUpdateRequested(1, {
            'meanings': ['one', 'first', 'unity'],
          }),
        ),
        expect: () => [
          KanjiLoading(),
          isA<KanjiOperationSuccess>().having(
            (s) => s.message,
            'success message',
            'Kanji updated successfully',
          ),
        ],
        verify: (_) {
          verify(mockKanjiService.updateKanji(1, any)).called(1);
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        'should emit [KanjiLoading, KanjiError] when update fails',
        build: () {
          when(
            mockKanjiService.updateKanji(any, any),
          ).thenThrow(KanjiException('Kanji not found'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(KanjiUpdateRequested(999, {})),
        expect: () => [
          KanjiLoading(),
          isA<KanjiError>().having(
            (s) => s.message,
            'error message',
            'Kanji not found',
          ),
        ],
      );
    });

    group('KanjiDeleteRequested', () {
      blocTest<KanjiBloc, KanjiState>(
        'should emit [KanjiLoading, KanjiOperationSuccess] when delete succeeds',
        build: () {
          when(
            mockKanjiService.deleteKanji(any),
          ).thenAnswer((_) async => Future.value());
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(KanjiDeleteRequested(1)),
        expect: () => [
          KanjiLoading(),
          isA<KanjiOperationSuccess>().having(
            (s) => s.message,
            'success message',
            'Kanji deleted successfully',
          ),
        ],
        verify: (_) {
          verify(mockKanjiService.deleteKanji(1)).called(1);
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        'should emit [KanjiLoading, KanjiError] when delete fails',
        build: () {
          when(
            mockKanjiService.deleteKanji(any),
          ).thenThrow(KanjiException('Forbidden'));
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(KanjiDeleteRequested(1)),
        expect: () => [
          KanjiLoading(),
          isA<KanjiError>().having(
            (s) => s.message,
            'error message',
            'Forbidden',
          ),
        ],
      );
    });

    group('KanjiRefreshRequested', () {
      blocTest<KanjiBloc, KanjiState>(
        'should reload with current filters when refreshing from loaded state',
        build: () {
          when(
            mockKanjiService.getKanjiList(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenAnswer((_) async => [testKanji]);
          return kanjiBloc;
        },
        seed: () => KanjiListLoaded(
          kanjiList: [testKanji],
          currentPage: 2,
          hasMore: true,
          appliedJlptFilter: 'N5',
          appliedGradeFilter: 1,
        ),
        act: (bloc) => bloc.add(KanjiRefreshRequested()),
        expect: () => [
          KanjiLoading(),
          isA<KanjiListLoaded>()
              .having((s) => s.currentPage, 'reset to page 1', 1)
              .having((s) => s.appliedJlptFilter, 'keeps jlpt filter', 'N5')
              .having((s) => s.appliedGradeFilter, 'keeps grade filter', 1),
        ],
      );

      blocTest<KanjiBloc, KanjiState>(
        'should load default list when refreshing from non-loaded state',
        build: () {
          when(
            mockKanjiService.getKanjiList(
              page: anyNamed('page'),
              limit: anyNamed('limit'),
              jlptLevel: anyNamed('jlptLevel'),
              grade: anyNamed('grade'),
              search: anyNamed('search'),
            ),
          ).thenAnswer((_) async => [testKanji]);
          return kanjiBloc;
        },
        act: (bloc) => bloc.add(KanjiRefreshRequested()),
        expect: () => [
          KanjiLoading(),
          isA<KanjiListLoaded>()
              .having((s) => s.currentPage, 'page 1', 1)
              .having((s) => s.appliedJlptFilter, 'no filter', null)
              .having((s) => s.appliedGradeFilter, 'no filter', null),
        ],
      );
    });
  });
}
