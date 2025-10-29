import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/kanji_model.dart';
import 'package:dio/dio.dart';

abstract class KanjiRemoteDataSource {
  Future<List<KanjiModel>> getKanjiList({
    int? jlpt,
    int? grade,
    String? search,
    int? limit,
    int? offset,
  });

  Future<Map<String, dynamic>> searchKanji({
    String? query,
    List<int>? jlptLevels,
    List<int>? grades,
    int? minStrokes,
    int? maxStrokes,
    int page = 1,
    int limit = 20,
    String? sortBy,
  });

  Future<KanjiModel> getKanjiById(int id);
  Future<KanjiModel> getKanjiByCharacter(String character);
  Future<List<KanjiModel>> searchByCanvas(String imageBase64);

  // Admin operations
  Future<KanjiModel> createKanji(Map<String, dynamic> data);
  Future<KanjiModel> updateKanji(int id, Map<String, dynamic> data);
  Future<void> deleteKanji(int id);
}

class KanjiRemoteDataSourceImpl implements KanjiRemoteDataSource {
  final ApiClient apiClient;

  KanjiRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<KanjiModel>> getKanjiList({
    int? jlpt,
    int? grade,
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (jlpt != null) queryParams['jlpt'] = jlpt;
      if (grade != null) queryParams['grade'] = grade;
      if (search != null) queryParams['search'] = search;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await apiClient.dio.get(
        '/kanji',
        queryParameters: queryParams,
      );

      // Backend returns: {statusCode, data: {data: [...kanji], total, limit, offset}, timestamp}
      final responseData = response.data['data'];

      // Handle both formats: nested {data: [...]} or direct [...]
      final List<dynamic> kanjiList;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('data')) {
        kanjiList = responseData['data'] as List;
      } else if (responseData is List) {
        kanjiList = responseData;
      } else {
        throw ServerException('Unexpected response format: $responseData');
      }

      return kanjiList.map((json) => KanjiModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get kanji list: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> searchKanji({
    String? query,
    List<int>? jlptLevels,
    List<int>? grades,
    int? minStrokes,
    int? maxStrokes,
    int page = 1,
    int limit = 20,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (query != null) queryParams['query'] = query;
      if (jlptLevels != null && jlptLevels.isNotEmpty) {
        queryParams['jlptLevels'] = jlptLevels.join(',');
      }
      if (grades != null && grades.isNotEmpty) {
        queryParams['grades'] = grades.join(',');
      }
      if (minStrokes != null) queryParams['minStrokes'] = minStrokes;
      if (maxStrokes != null) queryParams['maxStrokes'] = maxStrokes;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final response = await apiClient.dio.get(
        '/kanji/search',
        queryParameters: queryParams,
      );

      // Backend returns: {statusCode, data: {data: [], total, page, limit, totalPages}, timestamp}
      final responseData = response.data['data'] as Map<String, dynamic>;
      // Map 'data' field to 'kanji' for consistency with expected format
      return {
        'kanji': responseData['data'] ?? [],
        'total': responseData['total'] ?? 0,
        'page': responseData['page'] ?? page,
        'limit': responseData['limit'] ?? limit,
        'totalPages': responseData['totalPages'] ?? 0,
      };
    } catch (e) {
      throw ServerException('Failed to search kanji: $e');
    }
  }

  @override
  Future<KanjiModel> getKanjiById(int id) async {
    try {
      final response = await apiClient.dio.get('/kanji/$id');

      // Backend returns: {statusCode, data: {...kanji}, timestamp}
      final data = response.data['data'] as Map<String, dynamic>;
      return KanjiModel.fromJson(data);
    } catch (e) {
      throw ServerException('Failed to get kanji: $e');
    }
  }

  @override
  Future<KanjiModel> getKanjiByCharacter(String character) async {
    try {
      final response = await apiClient.dio.get('/kanji/character/$character');

      // Backend returns: {statusCode, data: {...kanji}, timestamp}
      final data = response.data['data'] as Map<String, dynamic>;
      return KanjiModel.fromJson(data);
    } catch (e) {
      throw ServerException('Failed to get kanji by character: $e');
    }
  }

  @override
  Future<List<KanjiModel>> searchByCanvas(String imageBase64) async {
    try {
      final response = await apiClient.dio.post(
        '/kanji-recognition/recognize',
        data: {'image': imageBase64},
      );

      // Backend returns: {statusCode, data: {character, confidence, top5: [{character, confidence}]}, timestamp}
      final data = response.data['data'] as Map<String, dynamic>;

      // Get top 5 predictions
      final top5 = data['top5'] as List<dynamic>?;

      if (top5 == null || top5.isEmpty) {
        // If no top5, use main prediction
        final character = data['character'] as String;
        try {
          final kanji = await getKanjiByCharacter(character);
          return [kanji];
        } catch (e) {
          // Main prediction not found, return empty list
          return [];
        }
      }

      // Fetch kanji details for top predictions (with error handling)
      final results = <KanjiModel>[];

      for (final pred in top5) {
        try {
          final char = pred['character'] as String;
          final kanji = await getKanjiByCharacter(char);
          results.add(kanji);
        } catch (e) {
          // Skip kanji that don't exist in database
          print(
            '⚠️ Kanji ${pred['character']} not found in database, skipping...',
          );
        }
      }

      return results;
    } catch (e) {
      throw ServerException('Failed to search by canvas: $e');
    }
  }

  @override
  Future<KanjiModel> createKanji(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post('/kanji', data: data);

      // Backend returns: {statusCode, data: {...kanji}, timestamp}
      final responseData = response.data['data'] as Map<String, dynamic>;
      return KanjiModel.fromJson(responseData);
    } catch (e) {
      throw _handleError(e, 'Failed to create kanji');
    }
  }

  @override
  Future<KanjiModel> updateKanji(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.put('/kanji/$id', data: data);

      // Backend returns: {statusCode, data: {...kanji}, timestamp}
      final responseData = response.data['data'] as Map<String, dynamic>;
      return KanjiModel.fromJson(responseData);
    } catch (e) {
      throw _handleError(e, 'Failed to update kanji');
    }
  }

  @override
  Future<void> deleteKanji(int id) async {
    try {
      await apiClient.dio.delete('/kanji/$id');
    } catch (e) {
      throw _handleError(e, 'Failed to delete kanji');
    }
  }

  /// Helper method to extract meaningful error messages from DioException
  ServerException _handleError(dynamic error, String defaultMessage) {
    if (error is DioException) {
      final response = error.response;
      if (response != null && response.data is Map) {
        // Backend returns: {statusCode, error: "message", timestamp}
        final errorMessage = response.data['error'] ?? response.data['message'];
        if (errorMessage != null) {
          return ServerException('$defaultMessage: $errorMessage');
        }
      }
      // Fallback to status code message
      if (response?.statusCode == 401) {
        return ServerException('$defaultMessage: Unauthorized');
      } else if (response?.statusCode == 404) {
        return ServerException('$defaultMessage: Not Found');
      }
    }
    return ServerException('$defaultMessage: $error');
  }
}
