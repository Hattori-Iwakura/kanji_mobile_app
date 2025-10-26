import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:kanji_mobile_v1/features/kanji/data/datasources/kanji_remote_datasource.dart';
import 'package:kanji_mobile_v1/features/kanji/data/models/kanji_model.dart';

import '../../../helpers/fixtures/kanji_fixtures.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late KanjiRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api'));
    dioAdapter = DioAdapter(dio: dio);
    dataSource = KanjiRemoteDataSourceImpl(dio: dio);
  });

  group('KanjiRemoteDataSource', () {
    group('getAllKanji', () {
      test(
        'should return list of KanjiModel when response is successful',
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
          final result = await dataSource.getAllKanji();

          // assert
          expect(result, isA<List<KanjiModel>>());
          expect(result.length, 3);
          expect(result[0].character, '日');
          expect(result[1].character, '月');
          expect(result[2].character, '火');
        },
      );

      test(
        'should return filtered kanji when JLPT filter is applied',
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
          final result = await dataSource.getAllKanji(jlpt: 5);

          // assert
          expect(result, isA<List<KanjiModel>>());
          expect(result.length, 1);
          expect(result[0].jlpt, 5);
        },
      );

      test('should throw exception when 404 Not Found error occurs', () async {
        // arrange
        dioAdapter.onGet(
          '/kanji',
          (server) => server.reply(404, {'message': 'Not found'}),
        );

        // act & assert
        expect(
          () => dataSource.getAllKanji(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Not found'),
            ),
          ),
        );
      });

      test('should throw exception when 500 Server Error occurs', () async {
        // arrange
        dioAdapter.onGet(
          '/kanji',
          (server) => server.reply(500, {'message': 'Internal Server Error'}),
        );

        // act & assert
        expect(
          () => dataSource.getAllKanji(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Server error'),
            ),
          ),
        );
      });

      test(
        'should throw exception when 401 Unauthorized error occurs',
        () async {
          // arrange
          dioAdapter.onGet(
            '/kanji',
            (server) => server.reply(401, {'message': 'Unauthorized'}),
          );

          // act & assert
          expect(
            () => dataSource.getAllKanji(),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Unauthorized'),
              ),
            ),
          );
        },
      );

      test('should throw exception when network timeout occurs', () async {
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

        // act & assert
        expect(
          () => dataSource.getAllKanji(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Connection timeout'),
            ),
          ),
        );
      });
    });

    group('getKanjiById', () {
      test('should return KanjiModel when response is successful', () async {
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
        final result = await dataSource.getKanjiById(1);

        // assert
        expect(result, isA<KanjiModel>());
        expect(result.id, 1);
        expect(result.character, '日');
      });

      test('should throw exception when kanji not found', () async {
        // arrange
        dioAdapter.onGet(
          '/kanji/999',
          (server) => server.reply(404, {'message': 'Kanji not found'}),
        );

        // act & assert
        expect(
          () => dataSource.getKanjiById(999),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Not found'),
            ),
          ),
        );
      });
    });

    group('getKanjiByCharacter', () {
      test('should return KanjiModel when response is successful', () async {
        // arrange
        final responseData = {
          'statusCode': 200,
          'data': tKanjiJson,
          'timestamp': '2024-01-01T00:00:00.000Z',
        };

        dioAdapter.onGet(
          '/kanji/character/日',
          (server) => server.reply(200, responseData),
        );

        // act
        final result = await dataSource.getKanjiByCharacter('日');

        // assert
        expect(result, isA<KanjiModel>());
        expect(result.character, '日');
      });

      test('should throw exception when character not found', () async {
        // arrange
        dioAdapter.onGet(
          '/kanji/character/X',
          (server) => server.reply(404, {'message': 'Character not found'}),
        );

        // act & assert
        expect(
          () => dataSource.getKanjiByCharacter('X'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Not found'),
            ),
          ),
        );
      });
    });

    group('searchKanji', () {
      test(
        'should return search results when response is successful',
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
            '/kanji/search',
            (server) => server.reply(200, responseData),
            queryParameters: {'query': 'sun', 'page': 1, 'limit': 20},
          );

          // act
          final result = await dataSource.searchKanji(
            query: 'sun',
            page: 1,
            limit: 20,
          );

          // assert
          expect(result, isA<List<KanjiModel>>());
          expect(result.length, 3);
        },
      );

      test('should search with all filters applied', () async {
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
        final result = await dataSource.searchKanji(
          query: 'sun',
          jlptLevels: [5, 4],
          grades: [1, 2],
          minStrokes: 1,
          maxStrokes: 5,
          page: 1,
          limit: 10,
          sortBy: 'frequency',
        );

        // assert
        expect(result, isA<List<KanjiModel>>());
        expect(result.length, 1);
      });

      test('should throw exception when bad request', () async {
        // arrange
        dioAdapter.onGet(
          '/kanji/search',
          (server) =>
              server.reply(400, {'message': 'Invalid query parameters'}),
          queryParameters: {'query': '', 'page': 1, 'limit': 20},
        );

        // act & assert
        expect(
          () => dataSource.searchKanji(query: '', page: 1, limit: 20),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Bad request'),
            ),
          ),
        );
      });

      test('should return empty list when no results found', () async {
        // arrange
        final responseData = {
          'statusCode': 200,
          'data': {'data': [], 'total': 0, 'limit': 20, 'offset': 0},
          'timestamp': '2024-01-01T00:00:00.000Z',
        };

        dioAdapter.onGet(
          '/kanji/search',
          (server) => server.reply(200, responseData),
          queryParameters: {'query': 'xyz', 'page': 1, 'limit': 20},
        );

        // act
        final result = await dataSource.searchKanji(
          query: 'xyz',
          page: 1,
          limit: 20,
        );

        // assert
        expect(result, isA<List<KanjiModel>>());
        expect(result.isEmpty, true);
      });
    });
  });
}
