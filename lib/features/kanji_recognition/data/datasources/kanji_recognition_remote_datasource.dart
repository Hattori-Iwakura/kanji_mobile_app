import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/kanji_recognition_result_model.dart';

abstract class KanjiRecognitionRemoteDataSource {
  Future<KanjiRecognitionResultModel> recognizeKanji(String base64Image);
}

class KanjiRecognitionRemoteDataSourceImpl
    implements KanjiRecognitionRemoteDataSource {
  final ApiClient apiClient;

  KanjiRecognitionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<KanjiRecognitionResultModel> recognizeKanji(String base64Image) async {
    try {
      final response = await apiClient.post('/kanji-recognition/recognize', {
        'image': base64Image,
      });

      return KanjiRecognitionResultModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to recognize kanji: ${e.message}');
    }
  }
}
