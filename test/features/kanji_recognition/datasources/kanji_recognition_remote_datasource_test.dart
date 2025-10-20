import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:kanji_flutter/core/network/api_client.dart';
import 'package:kanji_flutter/features/kanji_recognition/data/datasources/kanji_recognition_remote_datasource.dart';
import 'package:kanji_flutter/features/kanji_recognition/data/models/kanji_recognition_result_model.dart';

@GenerateMocks([ApiClient])
import 'kanji_recognition_remote_datasource_test.mocks.dart';

void main() {
  late KanjiRecognitionRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = KanjiRecognitionRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('KanjiRecognitionRemoteDataSource Tests', () {
    const testBase64Image = 'data:image/png;base64,iVBORw0KGgoAAAANS';

    final testResponseJson = {
      'character': '一',
      'confidence': 0.95,
      'top5': [
        {'character': '一', 'confidence': 0.95},
        {'character': '二', 'confidence': 0.03},
        {'character': '三', 'confidence': 0.01},
        {'character': '十', 'confidence': 0.005},
        {'character': '七', 'confidence': 0.003},
      ],
    };

    group('recognizeKanji', () {
      test(
        'should return KanjiRecognitionResultModel when API call succeeds',
        () async {
          when(
            mockApiClient.post('/kanji-recognition/recognize', any),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(
                path: '/kanji-recognition/recognize',
              ),
              statusCode: 200,
              data: testResponseJson,
            ),
          );

          final result = await dataSource.recognizeKanji(testBase64Image);

          expect(result, isA<KanjiRecognitionResultModel>());
          expect(result.character, '一');
          expect(result.confidence, 0.95);
          expect(result.top5.length, 5);
          verify(
            mockApiClient.post(
              '/kanji-recognition/recognize',
              argThat(containsPair('image', testBase64Image)),
            ),
          ).called(1);
        },
      );

      test('should throw Exception when API call fails', () async {
        when(mockApiClient.post('/kanji-recognition/recognize', any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/kanji-recognition/recognize',
            ),
            response: Response(
              requestOptions: RequestOptions(
                path: '/kanji-recognition/recognize',
              ),
              statusCode: 500,
              data: {'message': 'Server error'},
            ),
          ),
        );

        expect(
          () => dataSource.recognizeKanji(testBase64Image),
          throwsA(isA<Exception>()),
        );
      });

      test('should pass correct payload to API', () async {
        when(
          mockApiClient.post('/kanji-recognition/recognize', any),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: '/kanji-recognition/recognize',
            ),
            statusCode: 200,
            data: testResponseJson,
          ),
        );

        await dataSource.recognizeKanji(testBase64Image);

        verify(
          mockApiClient.post('/kanji-recognition/recognize', {
            'image': testBase64Image,
          }),
        ).called(1);
      });

      test('should handle low confidence results', () async {
        final lowConfidenceJson = {
          'character': '一',
          'confidence': 0.15,
          'top5': [
            {'character': '一', 'confidence': 0.15},
            {'character': '二', 'confidence': 0.14},
            {'character': '三', 'confidence': 0.13},
            {'character': '十', 'confidence': 0.12},
            {'character': '七', 'confidence': 0.11},
          ],
        };

        when(
          mockApiClient.post('/kanji-recognition/recognize', any),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: '/kanji-recognition/recognize',
            ),
            statusCode: 200,
            data: lowConfidenceJson,
          ),
        );

        final result = await dataSource.recognizeKanji(testBase64Image);

        expect(result.confidence, 0.15);
        expect(result.top5.first.confidence, 0.15);
      });

      test('should handle network timeout', () async {
        when(mockApiClient.post('/kanji-recognition/recognize', any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/kanji-recognition/recognize',
            ),
            type: DioExceptionType.connectionTimeout,
            error: 'Connection timeout',
          ),
        );

        expect(
          () => dataSource.recognizeKanji(testBase64Image),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle invalid base64 image', () async {
        when(mockApiClient.post('/kanji-recognition/recognize', any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/kanji-recognition/recognize',
            ),
            response: Response(
              requestOptions: RequestOptions(
                path: '/kanji-recognition/recognize',
              ),
              statusCode: 400,
              data: {'message': 'Invalid image format'},
            ),
          ),
        );

        expect(
          () => dataSource.recognizeKanji('invalid-base64'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
