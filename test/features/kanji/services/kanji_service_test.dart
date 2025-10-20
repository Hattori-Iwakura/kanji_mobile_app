import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:kanji_flutter/core/network/api_client.dart';
import 'package:kanji_flutter/features/kanji/services/kanji_service.dart';
import 'package:kanji_flutter/features/kanji/models/kanji.dart';
import 'package:kanji_flutter/features/kanji/models/kanji_exception.dart';

@GenerateMocks([ApiClient])
import 'kanji_service_test.mocks.dart';

void main() {
  late KanjiService kanjiService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    kanjiService = KanjiService(apiClient: mockApiClient);
  });

  group('KanjiService Tests', () {
    final testKanjiJson = {
      'id': 1,
      'character': '一',
      'jlptLevel': 'N5',
      'grade': 1,
      'strokeCount': 1,
      'meanings': ['one', 'first'],
      'frequency': 2,
      'onyomi': 'イチ、イツ',
      'kunyomi': 'ひと、ひと.つ',
      'hanviet': 'nhất',
      'meaningMnemonic': 'Single horizontal stroke',
      'readingMnemonic': 'Read as ichi',
      'createdAt': '2025-01-01T00:00:00.000Z',
      'updatedAt': '2025-01-01T00:00:00.000Z',
    };

    group('getKanjiList', () {
      test('should return list of kanji successfully', () async {
        when(
          mockApiClient.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji'),
            statusCode: 200,
            data: {
              'data': [testKanjiJson],
              'meta': {'total': 1, 'page': 1, 'limit': 50},
            },
          ),
        );

        final result = await kanjiService.getKanjiList();

        expect(result, isA<List<Kanji>>());
        expect(result.length, 1);
        expect(result.first.character, '一');
        verify(
          mockApiClient.get(any, queryParameters: anyNamed('queryParameters')),
        ).called(1);
      });

      test('should pass correct query parameters for filters', () async {
        when(
          mockApiClient.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji'),
            statusCode: 200,
            data: {
              'data': [],
              'meta': {'total': 0, 'page': 1, 'limit': 50},
            },
          ),
        );

        await kanjiService.getKanjiList(
          page: 2,
          limit: 100,
          jlptLevel: 'N5',
          grade: 1,
          search: 'one',
        );

        verify(
          mockApiClient.get(
            any,
            queryParameters: {
              'page': 2,
              'limit': 100,
              'jlptLevel': 'N5',
              'grade': 1,
              'search': 'one',
            },
          ),
        ).called(1);
      });

      test('should return empty list when no kanji found', () async {
        when(
          mockApiClient.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji'),
            statusCode: 200,
            data: {
              'data': [],
              'meta': {'total': 0, 'page': 1, 'limit': 50},
            },
          ),
        );

        final result = await kanjiService.getKanjiList();

        expect(result, isEmpty);
      });

      test('should throw KanjiException on DioException', () async {
        when(
          mockApiClient.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji'),
              statusCode: 500,
              data: {'message': 'Server error'},
            ),
          ),
        );

        expect(
          () => kanjiService.getKanjiList(),
          throwsA(isA<KanjiException>()),
        );
      });

      test('should throw KanjiException on generic error', () async {
        when(
          mockApiClient.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenThrow(Exception('Unexpected error'));

        expect(
          () => kanjiService.getKanjiList(),
          throwsA(isA<KanjiException>()),
        );
      });
    });

    group('getKanjiById', () {
      test('should return kanji by ID successfully', () async {
        when(mockApiClient.get(any)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji/1'),
            statusCode: 200,
            data: testKanjiJson,
          ),
        );

        final result = await kanjiService.getKanjiById(1);

        expect(result, isA<Kanji>());
        expect(result.id, 1);
        expect(result.character, '一');
        verify(mockApiClient.get(any)).called(1);
      });

      test('should throw KanjiException when kanji not found', () async {
        when(mockApiClient.get(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji/999'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji/999'),
              statusCode: 404,
              data: {'message': 'Kanji not found'},
            ),
          ),
        );

        expect(
          () => kanjiService.getKanjiById(999),
          throwsA(isA<KanjiException>()),
        );
      });
    });

    group('getKanjiByCharacter', () {
      test('should return kanji by character successfully', () async {
        when(mockApiClient.get(any)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji/character/一'),
            statusCode: 200,
            data: testKanjiJson,
          ),
        );

        final result = await kanjiService.getKanjiByCharacter('一');

        expect(result, isA<Kanji>());
        expect(result.character, '一');
        verify(mockApiClient.get(any)).called(1);
      });

      test('should throw KanjiException when character not found', () async {
        when(mockApiClient.get(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji/character/invalid'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji/character/invalid'),
              statusCode: 404,
              data: {'message': 'Kanji not found'},
            ),
          ),
        );

        expect(
          () => kanjiService.getKanjiByCharacter('invalid'),
          throwsA(isA<KanjiException>()),
        );
      });
    });

    group('createKanji', () {
      test('should create kanji successfully', () async {
        final newKanjiData = {
          'character': '二',
          'strokeCount': 2,
          'meanings': ['two'],
        };

        when(mockApiClient.post(any, any)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji'),
            statusCode: 201,
            data: {...testKanjiJson, ...newKanjiData, 'id': 2},
          ),
        );

        final result = await kanjiService.createKanji(newKanjiData);

        expect(result, isA<Kanji>());
        expect(result.character, '二');
        verify(mockApiClient.post(any, newKanjiData)).called(1);
      });

      test('should throw KanjiException on validation error', () async {
        when(mockApiClient.post(any, any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji'),
              statusCode: 400,
              data: {'message': 'Invalid kanji data'},
            ),
          ),
        );

        expect(
          () => kanjiService.createKanji({}),
          throwsA(isA<KanjiException>()),
        );
      });
    });

    group('updateKanji', () {
      test('should update kanji successfully', () async {
        final updateData = {
          'meanings': ['one', 'first', 'unity'],
        };

        when(mockApiClient.put(any, any)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji/1'),
            statusCode: 200,
            data: {...testKanjiJson, ...updateData},
          ),
        );

        final result = await kanjiService.updateKanji(1, updateData);

        expect(result, isA<Kanji>());
        expect(result.meanings.length, 3);
        verify(mockApiClient.put(any, updateData)).called(1);
      });

      test('should throw KanjiException when kanji not found', () async {
        when(mockApiClient.put(any, any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji/999'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji/999'),
              statusCode: 404,
              data: {'message': 'Kanji not found'},
            ),
          ),
        );

        expect(
          () => kanjiService.updateKanji(999, {}),
          throwsA(isA<KanjiException>()),
        );
      });
    });

    group('deleteKanji', () {
      test('should delete kanji successfully', () async {
        when(mockApiClient.delete(any)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/kanji/1'),
            statusCode: 200,
            data: {'message': 'Kanji deleted'},
          ),
        );

        await kanjiService.deleteKanji(1);

        verify(mockApiClient.delete(any)).called(1);
      });

      test('should throw KanjiException when delete fails', () async {
        when(mockApiClient.delete(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/kanji/1'),
            response: Response(
              requestOptions: RequestOptions(path: '/kanji/1'),
              statusCode: 403,
              data: {'message': 'Forbidden'},
            ),
          ),
        );

        expect(
          () => kanjiService.deleteKanji(1),
          throwsA(isA<KanjiException>()),
        );
      });
    });
  });
}
