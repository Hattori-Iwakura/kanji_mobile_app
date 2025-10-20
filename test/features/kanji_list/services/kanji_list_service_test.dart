import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:kanji_flutter/core/network/api_client.dart';
import 'package:kanji_flutter/features/kanji_list/services/kanji_list_service.dart';
import 'package:kanji_flutter/features/kanji_list/models/kanji_list.dart';
import 'package:kanji_flutter/features/kanji_list/models/kanji_list_exception.dart';

@GenerateMocks([ApiClient])
import 'kanji_list_service_test.mocks.dart';

void main() {
  late KanjiListService kanjiListService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    kanjiListService = KanjiListService(apiClient: mockApiClient);
  });

  group('KanjiListService Tests', () {
    final testKanjiListJson = {
      'id': 1,
      'name': 'JLPT N5',
      'description': 'N5 kanji list',
      'type': 'SYSTEM',
      'level': 'N5',
      'kanjiCount': 80,
      'userId': null,
      'createdAt': '2025-01-01T00:00:00.000Z',
      'updatedAt': '2025-01-01T00:00:00.000Z',
    };

    final testKanjiJson = {
      'id': 1,
      'character': '一',
      'jlptLevel': 'N5',
      'meanings': ['one'],
    };

    group('getKanjiLists', () {
      test('should return list of kanji lists successfully', () async {
        when(mockApiClient.get('/kanji-list')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji-list'),
            statusCode: 200,
            data: [testKanjiListJson],
          ),
        );

        final result = await kanjiListService.getKanjiLists();

        expect(result, isA<List<KanjiList>>());
        expect(result.length, 1);
        expect(result.first.name, 'JLPT N5');
        expect(result.first.type, 'SYSTEM');
        verify(mockApiClient.get('/kanji-list')).called(1);
      });

      test('should throw KanjiListException when API fails', () async {
        when(mockApiClient.get('/kanji-list')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji-list'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji-list'),
              statusCode: 500,
              data: {'message': 'Server error'},
            ),
          ),
        );

        expect(
          () => kanjiListService.getKanjiLists(),
          throwsA(isA<KanjiListException>()),
        );
      });

      test('should return empty list when no data', () async {
        when(mockApiClient.get('/kanji-list')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji-list'),
            statusCode: 200,
            data: [],
          ),
        );

        final result = await kanjiListService.getKanjiLists();

        expect(result, isEmpty);
      });
    });

    group('getKanjiListById', () {
      test('should return kanji list detail with kanjis', () async {
        when(mockApiClient.get('/kanji-list/1')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji-list/1'),
            statusCode: 200,
            data: {
              'list': testKanjiListJson,
              'kanjis': [testKanjiJson],
            },
          ),
        );

        final result = await kanjiListService.getKanjiListById(1);

        expect(result, isA<Map<String, dynamic>>());
        expect(result['list'], isA<Map<String, dynamic>>());
        expect(result['kanjis'], isA<List>());
        expect(result['kanjis'].length, 1);
        verify(mockApiClient.get('/kanji-list/1')).called(1);
      });

      test('should throw KanjiListException when list not found', () async {
        when(mockApiClient.get('/kanji-list/999')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji-list/999'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji-list/999'),
              statusCode: 404,
              data: {'message': 'Kanji list not found'},
            ),
          ),
        );

        expect(
          () => kanjiListService.getKanjiListById(999),
          throwsA(
            isA<KanjiListException>().having(
              (e) => e.message,
              'message',
              contains('not found'),
            ),
          ),
        );
      });
    });

    group('createKanjiList', () {
      test('should create kanji list successfully', () async {
        when(mockApiClient.post('/kanji-list', any)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji-list'),
            statusCode: 201,
            data: {
              ...testKanjiListJson,
              'id': 2,
              'name': 'My Custom List',
              'type': 'CUSTOM',
              'userId': 123,
            },
          ),
        );

        final result = await kanjiListService.createKanjiList(
          name: 'My Custom List',
          description: 'Custom description',
        );

        expect(result, isA<KanjiList>());
        expect(result.name, 'My Custom List');
        expect(result.type, 'CUSTOM');
        verify(
          mockApiClient.post(
            '/kanji-list',
            argThat(
              allOf(
                containsPair('name', 'My Custom List'),
                containsPair('description', 'Custom description'),
              ),
            ),
          ),
        ).called(1);
      });

      test('should throw exception when name is too short', () async {
        when(mockApiClient.post('/kanji-list', any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji-list'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji-list'),
              statusCode: 400,
              data: {'message': 'Name must be at least 3 characters'},
            ),
          ),
        );

        expect(
          () =>
              kanjiListService.createKanjiList(name: 'ab', description: 'desc'),
          throwsA(isA<KanjiListException>()),
        );
      });
    });

    group('updateKanjiList', () {
      test('should update kanji list successfully', () async {
        when(mockApiClient.patch('/kanji-list/2', any)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji-list/2'),
            statusCode: 200,
            data: {
              ...testKanjiListJson,
              'id': 2,
              'name': 'Updated Name',
              'description': 'Updated desc',
            },
          ),
        );

        final result = await kanjiListService.updateKanjiList(
          id: 2,
          name: 'Updated Name',
          description: 'Updated desc',
        );

        expect(result, isA<KanjiList>());
        expect(result.name, 'Updated Name');
        verify(mockApiClient.patch('/kanji-list/2', any)).called(1);
      });

      test('should throw exception when updating system list', () async {
        when(mockApiClient.patch('/kanji-list/1', any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji-list/1'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji-list/1'),
              statusCode: 403,
              data: {'message': 'Cannot modify system list'},
            ),
          ),
        );

        expect(
          () => kanjiListService.updateKanjiList(
            id: 1,
            name: 'New Name',
            description: 'desc',
          ),
          throwsA(
            isA<KanjiListException>().having(
              (e) => e.message,
              'message',
              contains('Cannot modify'),
            ),
          ),
        );
      });
    });

    group('deleteKanjiList', () {
      test('should delete kanji list successfully', () async {
        when(mockApiClient.delete('/kanji-list/2')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji-list/2'),
            statusCode: 200,
          ),
        );

        await kanjiListService.deleteKanjiList(2);

        verify(mockApiClient.delete('/kanji-list/2')).called(1);
      });

      test('should throw exception when deleting system list', () async {
        when(mockApiClient.delete('/kanji-list/1')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji-list/1'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji-list/1'),
              statusCode: 403,
              data: {'message': 'Cannot delete system list'},
            ),
          ),
        );

        expect(
          () => kanjiListService.deleteKanjiList(1),
          throwsA(
            isA<KanjiListException>().having(
              (e) => e.message,
              'message',
              contains('Cannot delete'),
            ),
          ),
        );
      });

      test('should throw exception when list not found', () async {
        when(mockApiClient.delete('/kanji-list/999')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji-list/999'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji-list/999'),
              statusCode: 404,
              data: {'message': 'Kanji list not found'},
            ),
          ),
        );

        expect(
          () => kanjiListService.deleteKanjiList(999),
          throwsA(isA<KanjiListException>()),
        );
      });
    });

    group('addKanjiToList', () {
      test('should add kanji to list successfully', () async {
        when(mockApiClient.post('/kanji-list/2/kanji/1', any)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji-list/2/kanji/1'),
            statusCode: 201,
          ),
        );

        await kanjiListService.addKanjiToList(listId: 2, kanjiId: 1);

        verify(mockApiClient.post('/kanji-list/2/kanji/1', {})).called(1);
      });

      test('should throw exception when kanji already in list', () async {
        when(mockApiClient.post('/kanji-list/2/kanji/1', any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji-list/2/kanji/1'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji-list/2/kanji/1'),
              statusCode: 409,
              data: {'message': 'Kanji already in list'},
            ),
          ),
        );

        expect(
          () => kanjiListService.addKanjiToList(listId: 2, kanjiId: 1),
          throwsA(
            isA<KanjiListException>().having(
              (e) => e.message,
              'message',
              contains('already in list'),
            ),
          ),
        );
      });

      test('should throw exception when adding to system list', () async {
        when(mockApiClient.post('/kanji-list/1/kanji/1', any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji-list/1/kanji/1'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji-list/1/kanji/1'),
              statusCode: 403,
              data: {'message': 'Cannot modify system list'},
            ),
          ),
        );

        expect(
          () => kanjiListService.addKanjiToList(listId: 1, kanjiId: 1),
          throwsA(isA<KanjiListException>()),
        );
      });
    });

    group('removeKanjiFromList', () {
      test('should remove kanji from list successfully', () async {
        when(mockApiClient.delete('/kanji-list/2/kanji/1')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji-list/2/kanji/1'),
            statusCode: 200,
          ),
        );

        await kanjiListService.removeKanjiFromList(listId: 2, kanjiId: 1);

        verify(mockApiClient.delete('/kanji-list/2/kanji/1')).called(1);
      });

      test('should throw exception when kanji not in list', () async {
        when(mockApiClient.delete('/kanji-list/2/kanji/999')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji-list/2/kanji/999'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji-list/2/kanji/999'),
              statusCode: 404,
              data: {'message': 'Kanji not found in list'},
            ),
          ),
        );

        expect(
          () => kanjiListService.removeKanjiFromList(listId: 2, kanjiId: 999),
          throwsA(isA<KanjiListException>()),
        );
      });

      test('should throw exception when removing from system list', () async {
        when(mockApiClient.delete('/kanji-list/1/kanji/1')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji-list/1/kanji/1'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji-list/1/kanji/1'),
              statusCode: 403,
              data: {'message': 'Cannot modify system list'},
            ),
          ),
        );

        expect(
          () => kanjiListService.removeKanjiFromList(listId: 1, kanjiId: 1),
          throwsA(isA<KanjiListException>()),
        );
      });
    });
  });
}
