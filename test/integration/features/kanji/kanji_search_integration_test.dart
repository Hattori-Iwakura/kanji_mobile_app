import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/kanji/data/datasources/kanji_remote_datasource.dart';
import 'package:kanji_mobile_v1/features/kanji/data/repositories/kanji_repository_impl.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/get_all_kanji.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/get_kanji_by_id.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/search_kanji.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/usecases/recognize_kanji.dart';
import 'package:kanji_mobile_v1/features/kanji/presentation/bloc/kanji_bloc.dart';
import 'package:kanji_mobile_v1/features/kanji/presentation/bloc/kanji_event.dart';
import 'package:kanji_mobile_v1/features/kanji/presentation/bloc/kanji_state.dart';

import '../../../helpers/fixtures/kanji_fixtures.dart';

/// Integration tests for complete Kanji feature flow:
/// BLoC → UseCase → Repository → RemoteDataSource → HTTP
void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late KanjiRemoteDataSourceImpl remoteDataSource;
  late KanjiRepositoryImpl repository;
  late GetAllKanji getAllKanjiUseCase;
  late GetKanjiById getKanjiByIdUseCase;
  late SearchKanji searchKanjiUseCase;
  late RecognizeKanji recognizeKanjiUseCase;
  late KanjiBloc kanjiBloc;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api'));
    dioAdapter = DioAdapter(dio: dio);
    remoteDataSource = KanjiRemoteDataSourceImpl(dio: dio);
    repository = KanjiRepositoryImpl(remoteDataSource: remoteDataSource);
    getAllKanjiUseCase = GetAllKanji(repository);
    getKanjiByIdUseCase = GetKanjiById(repository);
    searchKanjiUseCase = SearchKanji(repository);
    recognizeKanjiUseCase = RecognizeKanji(repository);
    kanjiBloc = KanjiBloc(
      getAllKanji: getAllKanjiUseCase,
      getKanjiById: getKanjiByIdUseCase,
      searchKanji: searchKanjiUseCase,
      recognizeKanji: recognizeKanjiUseCase,
    );
  });

  tearDown(() {
    kanjiBloc.close();
  });

  group('Kanji Search Integration Tests', () {
    group('LoadAllKanjiEvent → Complete Flow', () {
      test(
        'should load all kanji successfully through complete stack',
        () async {
          // arrange
          final responseData = {
            'statusCode': 200,
            'data': {
              'data': tKanjiListJson,
              'total': 3,
              'limit': 20,
              'offset': 0,
            },
            'timestamp': '2024-01-01T00:00:00.000Z',
          };

          dioAdapter.onGet(
            '/kanji',
            (server) => server.reply(200, responseData),
          );

          // act
          kanjiBloc.add(const LoadAllKanjiEvent());

          // assert
          await expectLater(
            kanjiBloc.stream,
            emitsInOrder([
              isA<KanjiLoading>(),
              isA<KanjiListLoaded>()
                  .having((state) => state.kanjiList.length, 'kanji count', 3)
                  .having(
                    (state) => state.kanjiList[0].character,
                    'first kanji character',
                    '日',
                  ),
            ]),
          );
        },
      );

      test(
        'should filter kanji by JLPT level through complete stack',
        () async {
          // arrange
          final responseData = {
            'statusCode': 200,
            'data': {
              'data': [tKanjiJson],
              'total': 1,
              'limit': 20,
              'offset': 0,
            },
            'timestamp': '2024-01-01T00:00:00.000Z',
          };

          dioAdapter.onGet(
            '/kanji',
            (server) => server.reply(200, responseData),
            queryParameters: {'jlpt': 5},
          );

          // act
          kanjiBloc.add(const LoadAllKanjiEvent(jlpt: 5));

          // assert
          await expectLater(
            kanjiBloc.stream,
            emitsInOrder([
              isA<KanjiLoading>(),
              isA<KanjiListLoaded>()
                  .having(
                    (state) => state.kanjiList.length,
                    'filtered count',
                    1,
                  )
                  .having((state) => state.kanjiList[0].jlpt, 'JLPT level', 5),
            ]),
          );
        },
      );

      test('should emit error when server returns 500', () async {
        // arrange
        dioAdapter.onGet(
          '/kanji',
          (server) => server.reply(500, {'message': 'Internal Server Error'}),
        );

        // act
        kanjiBloc.add(const LoadAllKanjiEvent());

        // assert
        await expectLater(
          kanjiBloc.stream,
          emitsInOrder([
            isA<KanjiLoading>(),
            isA<KanjiError>().having(
              (state) => state.message,
              'error message',
              contains('Server error'),
            ),
          ]),
        );
      });

      test('should emit error when network timeout occurs', () async {
        // arrange
        dioAdapter.onGet(
          '/kanji',
          (server) => server.throws(
            0,
            DioException(
              requestOptions: RequestOptions(path: '/kanji'),
              type: DioExceptionType.connectionTimeout,
            ),
          ),
        );

        // act
        kanjiBloc.add(const LoadAllKanjiEvent());

        // assert
        await expectLater(
          kanjiBloc.stream,
          emitsInOrder([
            isA<KanjiLoading>(),
            isA<KanjiError>().having(
              (state) => state.message,
              'error message',
              'Network connection failed',
            ),
          ]),
        );
      });
    });

    group('LoadKanjiByIdEvent → Complete Flow', () {
      test(
        'should load kanji detail successfully through complete stack',
        () async {
          // arrange
          final responseData = {
            'statusCode': 200,
            'data': tKanjiJson,
            'timestamp': '2024-01-01T00:00:00.000Z',
          };

          dioAdapter.onGet(
            '/kanji/1',
            (server) => server.reply(200, responseData),
          );

          // act
          kanjiBloc.add(const LoadKanjiByIdEvent(1));

          // assert
          await expectLater(
            kanjiBloc.stream,
            emitsInOrder([
              isA<KanjiLoading>(),
              isA<KanjiDetailLoaded>()
                  .having((state) => state.kanji.id, 'kanji id', 1)
                  .having(
                    (state) => state.kanji.character,
                    'kanji character',
                    '日',
                  ),
            ]),
          );
        },
      );

      test('should emit error when kanji not found (404)', () async {
        // arrange
        dioAdapter.onGet(
          '/kanji/999',
          (server) => server.reply(404, {'message': 'Kanji not found'}),
        );

        // act
        kanjiBloc.add(const LoadKanjiByIdEvent(999));

        // assert
        await expectLater(
          kanjiBloc.stream,
          emitsInOrder([
            isA<KanjiLoading>(),
            isA<KanjiError>().having(
              (state) => state.message,
              'error message',
              'Resource not found',
            ),
          ]),
        );
      });
    });

    group('SearchKanjiEvent → Complete Flow', () {
      test('should search kanji successfully through complete stack', () async {
        // arrange
        final responseData = {
          'statusCode': 200,
          'data': {
            'data': tKanjiListJson,
            'total': 3,
            'limit': 20,
            'offset': 0,
          },
          'timestamp': '2024-01-01T00:00:00.000Z',
        };

        dioAdapter.onGet(
          '/kanji/search',
          (server) => server.reply(200, responseData),
        );

        // act
        kanjiBloc.add(const SearchKanjiEvent(query: 'sun'));

        // assert
        await expectLater(
          kanjiBloc.stream,
          emitsInOrder([
            isA<KanjiLoading>(),
            isA<KanjiSearchLoaded>()
                .having(
                  (state) => state.results.length,
                  'search results count',
                  3,
                )
                .having((state) => state.page, 'page number', 1),
          ]),
        );
      });

      test(
        'should search with multiple filters through complete stack',
        () async {
          // arrange
          final responseData = {
            'statusCode': 200,
            'data': {
              'data': [tKanjiJson],
              'total': 1,
              'limit': 10,
              'offset': 0,
            },
            'timestamp': '2024-01-01T00:00:00.000Z',
          };

          dioAdapter.onGet(
            '/kanji/search',
            (server) => server.reply(200, responseData),
          );

          // act
          kanjiBloc.add(
            const SearchKanjiEvent(
              query: 'sun',
              jlptLevels: [5, 4],
              grades: [1, 2],
              minStrokes: 1,
              maxStrokes: 5,
              page: 1,
              limit: 10,
            ),
          );

          // assert
          await expectLater(
            kanjiBloc.stream,
            emitsInOrder([
              isA<KanjiLoading>(),
              isA<KanjiSearchLoaded>().having(
                (state) => state.results.length,
                'filtered results',
                1,
              ),
            ]),
          );
        },
      );

      test('should handle empty search results gracefully', () async {
        // arrange
        final responseData = {
          'statusCode': 200,
          'data': {'data': [], 'total': 0, 'limit': 20, 'offset': 0},
          'timestamp': '2024-01-01T00:00:00.000Z',
        };

        dioAdapter.onGet(
          '/kanji/search',
          (server) => server.reply(200, responseData),
        );

        // act
        kanjiBloc.add(const SearchKanjiEvent(query: 'notfound'));

        // assert
        await expectLater(
          kanjiBloc.stream,
          emitsInOrder([
            isA<KanjiLoading>(),
            isA<KanjiSearchLoaded>().having(
              (state) => state.results.isEmpty,
              'empty results',
              true,
            ),
          ]),
        );
      });

      test('should emit error when bad request (400)', () async {
        // arrange
        dioAdapter.onGet(
          '/kanji/search',
          (server) =>
              server.reply(400, {'message': 'Invalid query parameters'}),
        );

        // act
        kanjiBloc.add(const SearchKanjiEvent(query: ''));

        // assert
        await expectLater(
          kanjiBloc.stream,
          emitsInOrder([
            isA<KanjiLoading>(),
            isA<KanjiError>().having(
              (state) => state.message,
              'error message',
              contains('Bad request'),
            ),
          ]),
        );
      });
    });

    group('BLoC State Transitions', () {
      blocTest<KanjiBloc, KanjiState>(
        'should transition from Initial → Loading → Loaded',
        build: () {
          final testDio = Dio(
            BaseOptions(baseUrl: 'http://localhost:3000/api'),
          );
          final testAdapter = DioAdapter(dio: testDio);
          final responseData = {
            'statusCode': 200,
            'data': {
              'data': tKanjiListJson,
              'total': 3,
              'limit': 20,
              'offset': 0,
            },
            'timestamp': '2024-01-01T00:00:00.000Z',
          };

          testAdapter.onGet(
            '/kanji',
            (server) => server.reply(200, responseData),
          );

          final testRemoteDataSource = KanjiRemoteDataSourceImpl(dio: testDio);
          final testRepository = KanjiRepositoryImpl(
            remoteDataSource: testRemoteDataSource,
          );
          final testGetAllKanji = GetAllKanji(testRepository);
          final testGetKanjiById = GetKanjiById(testRepository);
          final testSearchKanji = SearchKanji(testRepository);
          final testRecognizeKanji = RecognizeKanji(testRepository);

          return KanjiBloc(
            getAllKanji: testGetAllKanji,
            getKanjiById: testGetKanjiById,
            searchKanji: testSearchKanji,
            recognizeKanji: testRecognizeKanji,
          );
        },
        act: (bloc) => bloc.add(const LoadAllKanjiEvent()),
        wait: const Duration(milliseconds: 500),
        expect: () => [isA<KanjiLoading>(), isA<KanjiListLoaded>()],
      );

      blocTest<KanjiBloc, KanjiState>(
        'should transition from Initial → Loading → Error on failure',
        build: () {
          final testDio = Dio(
            BaseOptions(baseUrl: 'http://localhost:3000/api'),
          );
          final testAdapter = DioAdapter(dio: testDio);

          testAdapter.onGet(
            '/kanji',
            (server) => server.reply(500, {'message': 'Server Error'}),
          );

          final testRemoteDataSource = KanjiRemoteDataSourceImpl(dio: testDio);
          final testRepository = KanjiRepositoryImpl(
            remoteDataSource: testRemoteDataSource,
          );
          final testGetAllKanji = GetAllKanji(testRepository);
          final testGetKanjiById = GetKanjiById(testRepository);
          final testSearchKanji = SearchKanji(testRepository);
          final testRecognizeKanji = RecognizeKanji(testRepository);

          return KanjiBloc(
            getAllKanji: testGetAllKanji,
            getKanjiById: testGetKanjiById,
            searchKanji: testSearchKanji,
            recognizeKanji: testRecognizeKanji,
          );
        },
        act: (bloc) => bloc.add(const LoadAllKanjiEvent()),
        wait: const Duration(milliseconds: 500),
        expect: () => [isA<KanjiLoading>(), isA<KanjiError>()],
      );
    });
  });
}
