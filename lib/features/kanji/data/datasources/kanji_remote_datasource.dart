import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoint.dart';
import '../../domain/entities/kanji_exception.dart';
import '../models/kanji.dart';

abstract class KanjiRemoteDataSource {
  Future<List<KanjiModel>> getKanjiList({
    int page = 1,
    int limit = 50,
    String? jlptLevel,
    int? grade,
    String? search,
  });

  Future<KanjiModel> getKanjiById(int id);

  Future<KanjiModel> getKanjiByCharacter(String character);

  Future<KanjiModel> createKanji(Map<String, dynamic> kanjiData);

  Future<KanjiModel> updateKanji(int id, Map<String, dynamic> kanjiData);

  Future<void> deleteKanji(int id);
}

class KanjiRemoteDataSourceImpl implements KanjiRemoteDataSource {
  final ApiClient _apiClient;

  KanjiRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<KanjiModel>> getKanjiList({
    int page = 1,
    int limit = 50,
    String? jlptLevel,
    int? grade,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (jlptLevel != null) queryParams['jlptLevel'] = jlptLevel;
      if (grade != null) queryParams['grade'] = grade;
      if (search != null) queryParams['search'] = search;

      final response = await _apiClient.get(
        ApiEndpoints.kanji,
        queryParameters: queryParams,
      );

      // Backend returns { statusCode, data: { data: [...], total, limit, offset }, timestamp }
      final responseData = response.data['data'];
      if (responseData is Map && responseData.containsKey('data')) {
        // Nested structure: data.data
        final data = responseData['data'] as List<dynamic>;
        return data.map((json) => KanjiModel.fromJson(json)).toList();
      } else {
        // Flat structure: data (fallback)
        final data = response.data['data'] as List<dynamic>;
        return data.map((json) => KanjiModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to load kanji';
      throw KanjiException(message);
    } catch (e) {
      throw KanjiException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<KanjiModel> getKanjiById(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.kanjiById(id));
      // Backend returns { statusCode, data: { ...kanjiObject }, timestamp }
      return KanjiModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to load kanji';
      throw KanjiException(message);
    } catch (e) {
      throw KanjiException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<KanjiModel> getKanjiByCharacter(String character) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.kanjiByCharacter(character),
      );
      return KanjiModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to load kanji';
      throw KanjiException(message);
    } catch (e) {
      throw KanjiException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<KanjiModel> createKanji(Map<String, dynamic> kanjiData) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.kanji, kanjiData);
      return KanjiModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to create kanji';
      throw KanjiException(message);
    } catch (e) {
      throw KanjiException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<KanjiModel> updateKanji(int id, Map<String, dynamic> kanjiData) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.kanjiById(id),
        kanjiData,
      );
      return KanjiModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to update kanji';
      throw KanjiException(message);
    } catch (e) {
      throw KanjiException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> deleteKanji(int id) async {
    try {
      await _apiClient.delete(ApiEndpoints.kanjiById(id));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to delete kanji';
      throw KanjiException(message);
    } catch (e) {
      throw KanjiException('An unexpected error occurred: $e');
    }
  }
}
