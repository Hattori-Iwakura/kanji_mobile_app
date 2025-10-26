import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/kanji_list/data/datasources/kanji_list_remote_datasource.dart';
import 'package:kanji_mobile_v1/features/kanji_list/data/models/kanji_list_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures/kanji_list_fixtures.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late KanjiListRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = KanjiListRemoteDataSourceImpl(dio: mockDio);
  });

  group('getAllLists', () {
    test('should perform GET request on /kanji-lists endpoint', () async {
      // arrange
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          data: tAllKanjiListsResponseJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/kanji-lists'),
        ),
      );

      // act
      await dataSource.getAllLists();

      // assert
      verify(
        () => mockDio.get(
          '/kanji-lists',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });

    test('should return KanjiListsResponse when successful', () async {
      // arrange
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          data: tAllKanjiListsResponseJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/kanji-lists'),
        ),
      );

      // act
      final result = await dataSource.getAllLists();

      // assert
      expect(result, isA<KanjiListsResponse>());
      expect(result.data.length, tAllKanjiLists.length);
    });

    test('should include search query parameter when provided', () async {
      // arrange
      const tSearch = 'JLPT N5';
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          data: tAllKanjiListsResponseJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/kanji-lists'),
        ),
      );

      // act
      await dataSource.getAllLists(search: tSearch);

      // assert
      verify(
        () => mockDio.get('/kanji-lists', queryParameters: {'search': tSearch}),
      ).called(1);
    });

    test('should include limit and offset when provided', () async {
      // arrange
      const tLimit = 10;
      const tOffset = 5;
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          data: tAllKanjiListsResponseJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/kanji-lists'),
        ),
      );

      // act
      await dataSource.getAllLists(limit: tLimit, offset: tOffset);

      // assert
      verify(
        () => mockDio.get(
          '/kanji-lists',
          queryParameters: {'limit': tLimit, 'offset': tOffset},
        ),
      ).called(1);
    });

    test('should throw exception on connection timeout', () async {
      // arrange
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/kanji-lists'),
        ),
      );

      // act & assert
      expect(() => dataSource.getAllLists(), throwsA(isA<Exception>()));
    });
  });

  group('getListById', () {
    const tId = 1;

    test('should perform GET request on /kanji-lists/:id endpoint', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tKanjiListJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/kanji-lists/$tId'),
        ),
      );

      // act
      await dataSource.getListById(tId);

      // assert
      verify(() => mockDio.get('/kanji-lists/$tId')).called(1);
    });

    test('should return KanjiListModel when successful', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tKanjiListJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/kanji-lists/$tId'),
        ),
      );

      // act
      final result = await dataSource.getListById(tId);

      // assert
      expect(result, isA<KanjiListModel>());
      expect(result.id, tId);
    });

    test('should throw exception when list not found (404)', () async {
      // arrange
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            data: {'message': 'Kanji list not found'},
            requestOptions: RequestOptions(path: '/kanji-lists/$tId'),
          ),
          requestOptions: RequestOptions(path: '/kanji-lists/$tId'),
        ),
      );

      // act & assert
      expect(() => dataSource.getListById(tId), throwsA(isA<Exception>()));
    });
  });

  group('createList', () {
    const tName = 'My Kanji List';
    const tDescription = 'Test description';
    final tKanjiIds = [1, 2, 3];

    test('should perform POST request on /kanji-lists endpoint', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tKanjiListJson,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/kanji-lists'),
        ),
      );

      // act
      await dataSource.createList(name: tName);

      // assert
      verify(
        () => mockDio.post('/kanji-lists', data: any(named: 'data')),
      ).called(1);
    });

    test('should include all parameters in request body', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tKanjiListJson,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/kanji-lists'),
        ),
      );

      // act
      await dataSource.createList(
        name: tName,
        description: tDescription,
        kanjiIds: tKanjiIds,
      );

      // assert
      verify(
        () => mockDio.post(
          '/kanji-lists',
          data: {
            'name': tName,
            'description': tDescription,
            'kanjiIds': tKanjiIds,
          },
        ),
      ).called(1);
    });

    test('should return KanjiListModel when successful', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tKanjiListJson,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/kanji-lists'),
        ),
      );

      // act
      final result = await dataSource.createList(name: tName);

      // assert
      expect(result, isA<KanjiListModel>());
    });

    test('should throw exception on bad request (400)', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {'message': 'Invalid request'},
            requestOptions: RequestOptions(path: '/kanji-lists'),
          ),
          requestOptions: RequestOptions(path: '/kanji-lists'),
        ),
      );

      // act & assert
      expect(
        () => dataSource.createList(name: tName),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateList', () {
    const tId = 1;
    const tName = 'Updated Name';

    test('should perform PUT request on /kanji-lists/:id endpoint', () async {
      // arrange
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tKanjiListJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/kanji-lists/$tId'),
        ),
      );

      // act
      await dataSource.updateList(id: tId, name: tName);

      // assert
      verify(
        () => mockDio.put('/kanji-lists/$tId', data: any(named: 'data')),
      ).called(1);
    });

    test('should include only provided fields in request', () async {
      // arrange
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tKanjiListJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/kanji-lists/$tId'),
        ),
      );

      // act
      await dataSource.updateList(id: tId, name: tName, isPublic: true);

      // assert
      verify(
        () => mockDio.put(
          '/kanji-lists/$tId',
          data: {'name': tName, 'isPublic': true},
        ),
      ).called(1);
    });

    test('should return updated KanjiListModel', () async {
      // arrange
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tKanjiListJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/kanji-lists/$tId'),
        ),
      );

      // act
      final result = await dataSource.updateList(id: tId, name: tName);

      // assert
      expect(result, isA<KanjiListModel>());
    });
  });

  group('deleteList', () {
    const tId = 1;

    test(
      'should perform DELETE request on /kanji-lists/:id endpoint',
      () async {
        // arrange
        when(() => mockDio.delete(any())).thenAnswer(
          (_) async => Response(
            statusCode: 204,
            requestOptions: RequestOptions(path: '/kanji-lists/$tId'),
          ),
        );

        // act
        await dataSource.deleteList(tId);

        // assert
        verify(() => mockDio.delete('/kanji-lists/$tId')).called(1);
      },
    );

    test('should throw exception when unauthorized (401)', () async {
      // arrange
      when(() => mockDio.delete(any())).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            data: {'message': 'Unauthorized'},
            requestOptions: RequestOptions(path: '/kanji-lists/$tId'),
          ),
          requestOptions: RequestOptions(path: '/kanji-lists/$tId'),
        ),
      );

      // act & assert
      expect(() => dataSource.deleteList(tId), throwsA(isA<Exception>()));
    });
  });

  group('addKanjiToList', () {
    const tListId = 1;
    const tKanjiId = 100;

    test('should perform POST request on correct endpoint', () async {
      // arrange
      when(() => mockDio.post(any())).thenAnswer(
        (_) async => Response(
          data: tKanjiListJson,
          statusCode: 200,
          requestOptions: RequestOptions(
            path: '/kanji-lists/$tListId/kanji/$tKanjiId',
          ),
        ),
      );

      // act
      await dataSource.addKanjiToList(tListId, tKanjiId);

      // assert
      verify(
        () => mockDio.post('/kanji-lists/$tListId/kanji/$tKanjiId'),
      ).called(1);
    });

    test('should return updated KanjiListModel', () async {
      // arrange
      when(() => mockDio.post(any())).thenAnswer(
        (_) async => Response(
          data: tKanjiListJson,
          statusCode: 200,
          requestOptions: RequestOptions(
            path: '/kanji-lists/$tListId/kanji/$tKanjiId',
          ),
        ),
      );

      // act
      final result = await dataSource.addKanjiToList(tListId, tKanjiId);

      // assert
      expect(result, isA<KanjiListModel>());
    });
  });

  group('removeKanjiFromList', () {
    const tListId = 1;
    const tKanjiId = 100;

    test('should perform DELETE request on correct endpoint', () async {
      // arrange
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async => Response(
          data: tKanjiListJson,
          statusCode: 200,
          requestOptions: RequestOptions(
            path: '/kanji-lists/$tListId/kanji/$tKanjiId',
          ),
        ),
      );

      // act
      await dataSource.removeKanjiFromList(tListId, tKanjiId);

      // assert
      verify(
        () => mockDio.delete('/kanji-lists/$tListId/kanji/$tKanjiId'),
      ).called(1);
    });

    test('should return updated KanjiListModel', () async {
      // arrange
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async => Response(
          data: tKanjiListJson,
          statusCode: 200,
          requestOptions: RequestOptions(
            path: '/kanji-lists/$tListId/kanji/$tKanjiId',
          ),
        ),
      );

      // act
      final result = await dataSource.removeKanjiFromList(tListId, tKanjiId);

      // assert
      expect(result, isA<KanjiListModel>());
    });
  });

  group('getListsByJlpt', () {
    const tJlptLevel = 'N5';

    test(
      'should perform GET request on /kanji-lists/jlpt/:level endpoint',
      () async {
        // arrange
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: tAllKanjiListsResponseJson,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/kanji-lists/jlpt/$tJlptLevel',
            ),
          ),
        );

        // act
        await dataSource.getListsByJlpt(tJlptLevel);

        // assert
        verify(() => mockDio.get('/kanji-lists/jlpt/$tJlptLevel')).called(1);
      },
    );

    test('should return KanjiListsResponse', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tAllKanjiListsResponseJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/kanji-lists/jlpt/$tJlptLevel'),
        ),
      );

      // act
      final result = await dataSource.getListsByJlpt(tJlptLevel);

      // assert
      expect(result, isA<KanjiListsResponse>());
    });
  });
}
