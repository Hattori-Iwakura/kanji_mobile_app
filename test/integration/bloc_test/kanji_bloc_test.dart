import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:kanji_mobile_app/features/kanji/presentation/bloc/kanji_bloc.dart';
import 'package:kanji_mobile_app/features/kanji/presentation/bloc/kanji_event.dart';
import 'package:kanji_mobile_app/features/kanji/presentation/bloc/kanji_state.dart';
import 'package:kanji_mobile_app/injection_container.dart' as di;
import '../../helpers/test_helper.dart';

void main() {
  setUpAll(() async {
    TestHelper.printSection('INITIALIZING KANJI BLOC TESTS');
    await TestHelper.initializeDependencies();
    TestHelper.printSuccess('✓ Dependencies initialized');
  });

  group('KanjiBloc Integration Tests -', () {
    late KanjiBloc kanjiBloc;

    setUp(() {
      kanjiBloc = di.sl<KanjiBloc>();
    });

    tearDown(() {
      kanjiBloc.close();
    });

    group('1. LoadKanjiList Event -', () {
      blocTest<KanjiBloc, KanjiState>(
        '1.1. Should emit [Loading, ListLoaded] when loading kanji list',
        build: () => kanjiBloc,
        act: (bloc) => bloc.add(
          const LoadKanjiListEvent(
            jlpt: null,
            grade: null,
            search: null,
            limit: 20,
            offset: 0,
          ),
        ),
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          KanjiLoading(),
          isA<KanjiListLoaded>().having(
            (state) => state.kanjiList.length,
            'kanji list',
            greaterThan(0),
          ),
        ],
        verify: (bloc) {
          final state = bloc.state as KanjiListLoaded;
          TestHelper.printSuccess('✓ Loaded ${state.kanjiList.length} kanji');
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        '1.2. Should filter by JLPT level',
        build: () => kanjiBloc,
        act: (bloc) => bloc.add(
          const LoadKanjiListEvent(
            jlpt: 5,
            grade: null,
            search: null,
            limit: 20,
            offset: 0,
          ),
        ),
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          KanjiLoading(),
          isA<KanjiListLoaded>().having(
            (state) => state.kanjiList.every((k) => k.jlpt == 5),
            'all kanji are JLPT 5',
            true,
          ),
        ],
        verify: (bloc) {
          final state = bloc.state as KanjiListLoaded;
          TestHelper.printSuccess(
            '✓ Found ${state.kanjiList.length} JLPT N5 kanji',
          );
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        '1.3. Should filter by grade',
        build: () => kanjiBloc,
        act: (bloc) => bloc.add(
          const LoadKanjiListEvent(
            jlpt: null,
            grade: 1,
            search: null,
            limit: 20,
            offset: 0,
          ),
        ),
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          KanjiLoading(),
          isA<KanjiListLoaded>().having(
            (state) => state.kanjiList.every((k) => k.grade == 1),
            'all kanji are grade 1',
            true,
          ),
        ],
        verify: (bloc) {
          final state = bloc.state as KanjiListLoaded;
          TestHelper.printSuccess(
            '✓ Found ${state.kanjiList.length} Grade 1 kanji',
          );
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        '1.4. Should search by character',
        build: () => kanjiBloc,
        act: (bloc) => bloc.add(
          const LoadKanjiListEvent(
            jlpt: null,
            grade: null,
            search: '日',
            limit: 20,
            offset: 0,
          ),
        ),
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          KanjiLoading(),
          isA<KanjiListLoaded>().having(
            (state) => state.kanjiList.length,
            'found kanji',
            greaterThan(0),
          ),
        ],
        verify: (bloc) {
          final state = bloc.state as KanjiListLoaded;
          TestHelper.printSuccess(
            '✓ Found ${state.kanjiList.length} kanji matching "日"',
          );
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        '1.5. Should support pagination',
        build: () => kanjiBloc,
        act: (bloc) async {
          bloc.add(
            const LoadKanjiListEvent(
              jlpt: null,
              grade: null,
              search: null,
              limit: 10,
              offset: 0,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 1000));
          bloc.add(
            const LoadKanjiListEvent(
              jlpt: null,
              grade: null,
              search: null,
              limit: 10,
              offset: 10,
            ),
          );
        },
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          KanjiLoading(),
          isA<KanjiListLoaded>(),
          KanjiLoading(),
          isA<KanjiListLoaded>(),
        ],
        verify: (bloc) {
          TestHelper.printSuccess('✓ Pagination works correctly');
        },
      );
    });

    group('2. SearchKanji Event -', () {
      blocTest<KanjiBloc, KanjiState>(
        '2.1. Should emit [Loading, SearchResult] when searching',
        build: () => kanjiBloc,
        act: (bloc) => bloc.add(
          const SearchKanjiEvent(
            query: '水',
            jlptLevels: null,
            grades: null,
            minStrokes: null,
            maxStrokes: null,
            page: 1,
            limit: 10,
            sortBy: null,
          ),
        ),
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          KanjiLoading(),
          isA<KanjiSearchResult>().having(
            (state) => state.kanjiList.length,
            'search results',
            greaterThan(0),
          ),
        ],
        verify: (bloc) {
          final state = bloc.state as KanjiSearchResult;
          TestHelper.printSuccess(
            '✓ Found ${state.kanjiList.length} kanji, total: ${state.total}',
          );
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        '2.2. Should filter by JLPT levels',
        build: () => kanjiBloc,
        act: (bloc) => bloc.add(
          const SearchKanjiEvent(
            query: null,
            jlptLevels: [5, 4],
            grades: null,
            minStrokes: null,
            maxStrokes: null,
            page: 1,
            limit: 10,
            sortBy: null,
          ),
        ),
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          KanjiLoading(),
          isA<KanjiSearchResult>().having(
            (state) => state.kanjiList.length,
            'found JLPT N5/N4 kanji',
            greaterThan(0),
          ),
        ],
        verify: (bloc) {
          final state = bloc.state as KanjiSearchResult;
          TestHelper.printSuccess(
            '✓ Found ${state.kanjiList.length} JLPT N5/N4 kanji',
          );
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        '2.3. Should filter by stroke count range',
        build: () => kanjiBloc,
        act: (bloc) => bloc.add(
          const SearchKanjiEvent(
            query: null,
            jlptLevels: null,
            grades: null,
            minStrokes: 1,
            maxStrokes: 5,
            page: 1,
            limit: 10,
            sortBy: null,
          ),
        ),
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          KanjiLoading(),
          isA<KanjiSearchResult>().having(
            (state) => state.kanjiList.length,
            'found kanji with 1-5 strokes',
            greaterThan(0),
          ),
        ],
        verify: (bloc) {
          final state = bloc.state as KanjiSearchResult;
          TestHelper.printSuccess(
            '✓ Found ${state.kanjiList.length} kanji with 1-5 strokes',
          );
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        '2.4. Should filter by grade levels',
        build: () => kanjiBloc,
        act: (bloc) => bloc.add(
          const SearchKanjiEvent(
            query: null,
            jlptLevels: null,
            grades: [1, 2],
            minStrokes: null,
            maxStrokes: null,
            page: 1,
            limit: 10,
            sortBy: null,
          ),
        ),
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          KanjiLoading(),
          isA<KanjiSearchResult>().having(
            (state) => state.kanjiList.length,
            'found grade 1-2 kanji',
            greaterThan(0),
          ),
        ],
        verify: (bloc) {
          final state = bloc.state as KanjiSearchResult;
          TestHelper.printSuccess(
            '✓ Found ${state.kanjiList.length} Grade 1-2 kanji',
          );
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        '2.5. Should handle pagination in search',
        build: () => kanjiBloc,
        act: (bloc) async {
          bloc.add(
            const SearchKanjiEvent(
              query: null,
              jlptLevels: [5],
              grades: null,
              minStrokes: null,
              maxStrokes: null,
              page: 1,
              limit: 5,
              sortBy: null,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 1000));
          bloc.add(
            const SearchKanjiEvent(
              query: null,
              jlptLevels: [5],
              grades: null,
              minStrokes: null,
              maxStrokes: null,
              page: 2,
              limit: 5,
              sortBy: null,
            ),
          );
        },
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          KanjiLoading(),
          isA<KanjiSearchResult>(),
          KanjiLoading(),
          isA<KanjiSearchResult>(),
        ],
        verify: (bloc) {
          TestHelper.printSuccess('✓ Search pagination works correctly');
        },
      );
    });

    group('3. LoadKanjiDetail Event -', () {
      blocTest<KanjiBloc, KanjiState>(
        '3.1. Should emit [Loading, DetailLoaded] when loading detail',
        build: () => kanjiBloc,
        act: (bloc) => bloc.add(const LoadKanjiDetailEvent('日')),
        wait: const Duration(milliseconds: 2000),
        skip: 1, // Skip Loading state
        expect: () => [
          isA<KanjiDetailLoaded>().having(
            (state) => state.kanjiDetail.character,
            'character',
            '日',
          ),
        ],
        verify: (bloc) {
          final state = bloc.state as KanjiDetailLoaded;
          TestHelper.printSuccess(
            '✓ Loaded detail for "${state.kanjiDetail.character}"',
          );
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        '3.2. Should load multiple kanji details sequentially',
        build: () => kanjiBloc,
        act: (bloc) async {
          bloc.add(const LoadKanjiDetailEvent('日'));
          await Future.delayed(const Duration(milliseconds: 1500));
          bloc.add(const LoadKanjiDetailEvent('月'));
          await Future.delayed(const Duration(milliseconds: 1500));
          bloc.add(const LoadKanjiDetailEvent('水'));
        },
        wait: const Duration(milliseconds: 2000),
        skip: 5, // Skip all Loading states
        expect: () => [
          isA<KanjiDetailLoaded>().having(
            (state) => state.kanjiDetail.character,
            'third character',
            '水',
          ),
        ],
        verify: (bloc) {
          final state = bloc.state as KanjiDetailLoaded;
          expect(state.kanjiDetail.character, '水');
          TestHelper.printSuccess('✓ Loaded 3 kanji details sequentially');
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        '3.3. Should emit error for invalid character',
        build: () => kanjiBloc,
        act: (bloc) => bloc.add(const LoadKanjiDetailEvent('ABC123')),
        wait: const Duration(milliseconds: 1000),
        expect: () => [KanjiLoading(), isA<KanjiError>()],
        verify: (bloc) {
          final state = bloc.state as KanjiError;
          expect(state.message, contains('404'));
          TestHelper.printSuccess('✓ Handled invalid character correctly');
        },
      );
    });

    group('4. Error Handling -', () {
      blocTest<KanjiBloc, KanjiState>(
        '4.1. Should recover from error when making new request',
        build: () => kanjiBloc,
        act: (bloc) async {
          // First, trigger an error
          bloc.add(const LoadKanjiDetailEvent('INVALID'));
          await Future.delayed(const Duration(milliseconds: 1000));
          // Then, make a valid request
          bloc.add(
            const LoadKanjiListEvent(
              jlpt: null,
              grade: null,
              search: null,
              limit: 10,
              offset: 0,
            ),
          );
        },
        wait: const Duration(milliseconds: 500),
        expect: () => [
          KanjiLoading(),
          isA<KanjiError>(),
          KanjiLoading(),
          isA<KanjiListLoaded>(),
        ],
        verify: (bloc) {
          expect(bloc.state, isA<KanjiListLoaded>());
          TestHelper.printSuccess('✓ Recovered from error state');
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        '4.2. Should handle network errors gracefully',
        build: () => kanjiBloc,
        act: (bloc) => bloc.add(
          const SearchKanjiEvent(
            query: null,
            jlptLevels: null,
            grades: null,
            minStrokes: null,
            maxStrokes: null,
            page: 999999, // Invalid page
            limit: 10,
            sortBy: null,
          ),
        ),
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          KanjiLoading(),
          isA<KanjiSearchResult>().having(
            (state) => state.kanjiList.isEmpty,
            'empty results for invalid page',
            true,
          ),
        ],
        verify: (bloc) {
          final state = bloc.state as KanjiSearchResult;
          expect(state.kanjiList, isEmpty);
          TestHelper.printSuccess('✓ Handled invalid page gracefully');
        },
      );
    });

    group('5. State Persistence -', () {
      blocTest<KanjiBloc, KanjiState>(
        '5.1. Should maintain state through multiple operations',
        build: () => kanjiBloc,
        act: (bloc) async {
          // Load list
          bloc.add(
            const LoadKanjiListEvent(
              jlpt: 5,
              grade: null,
              search: null,
              limit: 10,
              offset: 0,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 800));

          // Search
          bloc.add(
            const SearchKanjiEvent(
              query: '水',
              jlptLevels: null,
              grades: null,
              minStrokes: null,
              maxStrokes: null,
              page: 1,
              limit: 10,
              sortBy: null,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 800));

          // Load detail
          bloc.add(const LoadKanjiDetailEvent('日'));
        },
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          KanjiLoading(),
          isA<KanjiListLoaded>(),
          KanjiLoading(),
          isA<KanjiSearchResult>(),
          KanjiLoading(),
          isA<KanjiDetailLoaded>(),
        ],
        verify: (bloc) {
          expect(bloc.state, isA<KanjiDetailLoaded>());
          final state = bloc.state as KanjiDetailLoaded;
          expect(state.kanjiDetail.character, '日');
          TestHelper.printSuccess(
            '✓ State persisted correctly through multiple operations',
          );
        },
      );
    });
  });
}
