import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/entities/kanji.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/get_all_kanji.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/get_kanji_by_id.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/search_kanji.dart';
import 'package:kanji_mobile_v1/features/kanji/presentation/bloc/kanji_bloc.dart';
import 'package:kanji_mobile_v1/features/kanji/presentation/bloc/kanji_event.dart';
import 'package:kanji_mobile_v1/features/kanji/presentation/bloc/kanji_state.dart';

class MockGetAllKanji extends Mock implements GetAllKanji {}

class MockGetKanjiById extends Mock implements GetKanjiById {}

class MockSearchKanji extends Mock implements SearchKanji {}

void main() {
  late KanjiBloc bloc;
  late MockGetAllKanji mockGetAllKanji;
  late MockGetKanjiById mockGetKanjiById;
  late MockSearchKanji mockSearchKanji;

  setUp(() {
    mockGetAllKanji = MockGetAllKanji();
    mockGetKanjiById = MockGetKanjiById();
    mockSearchKanji = MockSearchKanji();
    bloc = KanjiBloc(
      getAllKanji: mockGetAllKanji,
      getKanjiById: mockGetKanjiById,
      searchKanji: mockSearchKanji,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final testKanji = Kanji(
    id: 1,
    character: '日',
    onyomi: 'ニチ、ジツ',
    kunyomi: 'ひ、か',
    meanings: 'sun, day',
    strokeCount: 4,
    jlpt: 5,
    grade: 1,
    frequency: 1,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final testKanjiList = [testKanji];

  group('KanjiBloc', () {
    test('initial state is KanjiInitial', () {
      expect(bloc.state, equals(KanjiInitial()));
    });

    group('LoadAllKanjiEvent', () {
      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiListLoaded] when getAllKanji succeeds',
        build: () {
          when(
            () => mockGetAllKanji(
              jlpt: any(named: 'jlpt'),
              grade: any(named: 'grade'),
              search: any(named: 'search'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          ).thenAnswer((_) async => Right(testKanjiList));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadAllKanjiEvent()),
        expect: () => [KanjiLoading(), KanjiListLoaded(testKanjiList)],
        verify: (_) {
          verify(
            () => mockGetAllKanji(
              jlpt: null,
              grade: null,
              search: null,
              limit: null,
              offset: null,
            ),
          ).called(1);
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiListLoaded] with JLPT filter',
        build: () {
          when(
            () => mockGetAllKanji(
              jlpt: any(named: 'jlpt'),
              grade: any(named: 'grade'),
              search: any(named: 'search'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          ).thenAnswer((_) async => Right(testKanjiList));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadAllKanjiEvent(jlpt: 5)),
        expect: () => [KanjiLoading(), KanjiListLoaded(testKanjiList)],
        verify: (_) {
          verify(
            () => mockGetAllKanji(
              jlpt: 5,
              grade: null,
              search: null,
              limit: null,
              offset: null,
            ),
          ).called(1);
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when getAllKanji fails with server error',
        build: () {
          when(
            () => mockGetAllKanji(
              jlpt: any(named: 'jlpt'),
              grade: any(named: 'grade'),
              search: any(named: 'search'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          ).thenAnswer((_) async => Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadAllKanjiEvent()),
        expect: () => [KanjiLoading(), const KanjiError('Server error')],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when getAllKanji fails with network error',
        build: () {
          when(
            () => mockGetAllKanji(
              jlpt: any(named: 'jlpt'),
              grade: any(named: 'grade'),
              search: any(named: 'search'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          ).thenAnswer((_) async => Left(NetworkFailure('No internet')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadAllKanjiEvent()),
        expect: () => [KanjiLoading(), const KanjiError('No internet')],
      );
    });

    group('LoadKanjiByIdEvent', () {
      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiDetailLoaded] when getKanjiById succeeds',
        build: () {
          when(
            () => mockGetKanjiById(any()),
          ).thenAnswer((_) async => Right(testKanji));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadKanjiByIdEvent(1)),
        expect: () => [KanjiLoading(), KanjiDetailLoaded(testKanji)],
        verify: (_) {
          verify(() => mockGetKanjiById(1)).called(1);
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when getKanjiById fails with not found',
        build: () {
          when(
            () => mockGetKanjiById(any()),
          ).thenAnswer((_) async => Left(ServerFailure('Kanji not found')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadKanjiByIdEvent(999)),
        expect: () => [KanjiLoading(), const KanjiError('Kanji not found')],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when getKanjiById fails with network error',
        build: () {
          when(
            () => mockGetKanjiById(any()),
          ).thenAnswer((_) async => Left(NetworkFailure('No internet')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadKanjiByIdEvent(1)),
        expect: () => [KanjiLoading(), const KanjiError('No internet')],
      );
    });

    group('SearchKanjiEvent', () {
      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiSearchLoaded] when searchKanji succeeds',
        build: () {
          when(
            () => mockSearchKanji(
              query: any(named: 'query'),
              jlptLevels: any(named: 'jlptLevels'),
              grades: any(named: 'grades'),
              minStrokes: any(named: 'minStrokes'),
              maxStrokes: any(named: 'maxStrokes'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              sortBy: any(named: 'sortBy'),
            ),
          ).thenAnswer((_) async => Right(testKanjiList));
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchKanjiEvent(query: 'sun')),
        expect: () => [
          KanjiLoading(),
          KanjiSearchLoaded(
            results: testKanjiList,
            page: 1,
            hasMore: false, // testKanjiList.length (1) < limit (20)
          ),
        ],
        verify: (_) {
          verify(
            () => mockSearchKanji(
              query: 'sun',
              jlptLevels: null,
              grades: null,
              minStrokes: null,
              maxStrokes: null,
              page: 1,
              limit: 20,
              sortBy: null,
            ),
          ).called(1);
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiSearchLoaded] with hasMore=true when results equal limit',
        build: () {
          final fullPageResults = List.generate(
            20,
            (i) => Kanji(
              id: i,
              character: '日',
              onyomi: 'ニチ',
              kunyomi: 'ひ',
              meanings: 'sun',
              strokeCount: 4,
              jlpt: 5,
              grade: 1,
              frequency: i,
              createdAt: DateTime(2024, 1, 1),
              updatedAt: DateTime(2024, 1, 1),
            ),
          );
          when(
            () => mockSearchKanji(
              query: any(named: 'query'),
              jlptLevels: any(named: 'jlptLevels'),
              grades: any(named: 'grades'),
              minStrokes: any(named: 'minStrokes'),
              maxStrokes: any(named: 'maxStrokes'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              sortBy: any(named: 'sortBy'),
            ),
          ).thenAnswer((_) async => Right(fullPageResults));
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchKanjiEvent(query: 'sun')),
        expect: () => [
          KanjiLoading(),
          isA<KanjiSearchLoaded>()
              .having((state) => state.hasMore, 'hasMore', true)
              .having((state) => state.results.length, 'results length', 20),
        ],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiSearchLoaded] with multiple filters',
        build: () {
          when(
            () => mockSearchKanji(
              query: any(named: 'query'),
              jlptLevels: any(named: 'jlptLevels'),
              grades: any(named: 'grades'),
              minStrokes: any(named: 'minStrokes'),
              maxStrokes: any(named: 'maxStrokes'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              sortBy: any(named: 'sortBy'),
            ),
          ).thenAnswer((_) async => Right(testKanjiList));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const SearchKanjiEvent(
            query: 'sun',
            jlptLevels: [5],
            grades: [1],
            minStrokes: 1,
            maxStrokes: 5,
            sortBy: 'frequency',
          ),
        ),
        expect: () => [
          KanjiLoading(),
          KanjiSearchLoaded(results: testKanjiList, page: 1, hasMore: false),
        ],
        verify: (_) {
          verify(
            () => mockSearchKanji(
              query: 'sun',
              jlptLevels: [5],
              grades: [1],
              minStrokes: 1,
              maxStrokes: 5,
              page: 1,
              limit: 20,
              sortBy: 'frequency',
            ),
          ).called(1);
        },
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when searchKanji fails with server error',
        build: () {
          when(
            () => mockSearchKanji(
              query: any(named: 'query'),
              jlptLevels: any(named: 'jlptLevels'),
              grades: any(named: 'grades'),
              minStrokes: any(named: 'minStrokes'),
              maxStrokes: any(named: 'maxStrokes'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              sortBy: any(named: 'sortBy'),
            ),
          ).thenAnswer((_) async => Left(ServerFailure('Search failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchKanjiEvent(query: 'invalid')),
        expect: () => [KanjiLoading(), const KanjiError('Search failed')],
      );

      blocTest<KanjiBloc, KanjiState>(
        'emits [KanjiLoading, KanjiError] when searchKanji fails with network error',
        build: () {
          when(
            () => mockSearchKanji(
              query: any(named: 'query'),
              jlptLevels: any(named: 'jlptLevels'),
              grades: any(named: 'grades'),
              minStrokes: any(named: 'minStrokes'),
              maxStrokes: any(named: 'maxStrokes'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              sortBy: any(named: 'sortBy'),
            ),
          ).thenAnswer((_) async => Left(NetworkFailure('No internet')));
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchKanjiEvent(query: 'sun')),
        expect: () => [KanjiLoading(), const KanjiError('No internet')],
      );
    });
  });
}
