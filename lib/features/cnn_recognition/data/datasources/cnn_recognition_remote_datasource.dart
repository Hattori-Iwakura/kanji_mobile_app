import 'package:dio/dio.dart';
import '../models/prediction_result_model.dart';

/// Remote data source for CNN kanji recognition API
abstract class CnnRecognitionRemoteDataSource {
  Future<List<PredictionResultModel>> predictKanji(List<int> imageBytes);
  Future<bool> checkServerStatus();
}

class CnnRecognitionRemoteDataSourceImpl
    implements CnnRecognitionRemoteDataSource {
  final Dio dio;
  static const String baseUrl = 'http://10.0.2.2:8000'; // FastAPI CNN server

  CnnRecognitionRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PredictionResultModel>> predictKanji(List<int> imageBytes) async {
    try {
      // Create multipart form data with image
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(imageBytes, filename: 'kanji.png'),
      });

      final response = await dio.post(
        '$baseUrl/api/v1/predict',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Expected response: {"predictions": [{"character": "愛", "confidence": 0.95}, ...]}
        final predictions = data['predictions'] as List;

        return predictions
            .asMap()
            .entries
            .map(
              (entry) => PredictionResultModel.fromJson(
                entry.value as Map<String, dynamic>,
                entry.key + 1, // rank starts from 1
              ),
            )
            .toList();
      } else {
        throw Exception('Prediction failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<bool> checkServerStatus() async {
    try {
      final response = await dio.get(
        '$baseUrl/health',
        options: Options(
          validateStatus: (status) => status! < 500,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'CNN server connection timeout. Please check if the server is running.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) {
          return Exception('Invalid image format');
        } else if (statusCode == 413) {
          return Exception('Image too large');
        }
        return Exception('Server error: $statusCode');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception(
          'Cannot connect to CNN server at $baseUrl. Please ensure the FastAPI server is running.',
        );
    }
  }
}
