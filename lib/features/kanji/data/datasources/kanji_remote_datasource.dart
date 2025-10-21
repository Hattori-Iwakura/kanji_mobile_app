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

  /// Convert jlptLevel string (e.g., "N5") to jlpt integer (e.g., 5)
  /// Backend expects jlpt as integer, not jlptLevel as string
  int? _convertJlptLevelToInt(String? jlptLevel) {
    if (jlptLevel == null || jlptLevel.isEmpty) return null;

    // Remove 'N' prefix and parse: "N5" → 5, "N4" → 4, etc.
    final levelStr = jlptLevel.replaceFirst('N', '');
    return int.tryParse(levelStr);
  }

  /// Transform kanji data from app format to backend format
  /// App uses: jlptLevel (string "N5"), meanings/onyomi/kunyomi (arrays)
  /// Backend uses: jlpt (int 5), meanings/onyomi/kunyomi (strings)
  Map<String, dynamic> _transformKanjiDataForBackend(
    Map<String, dynamic> data,
  ) {
    final transformed = Map<String, dynamic>.from(data);

    // Convert jlptLevel string to jlpt integer
    if (transformed.containsKey('jlptLevel')) {
      transformed['jlpt'] = _convertJlptLevelToInt(transformed['jlptLevel']);
      transformed.remove('jlptLevel');
    }

    // Convert arrays to comma-separated strings if needed
    if (transformed['meanings'] is List) {
      transformed['meanings'] = (transformed['meanings'] as List).join(', ');
    }
    if (transformed['onyomi'] is List) {
      transformed['onyomi'] = (transformed['onyomi'] as List).join(', ');
    }
    if (transformed['kunyomi'] is List) {
      transformed['kunyomi'] = (transformed['kunyomi'] as List).join(', ');
    }

    return transformed;
  }

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

      // Convert jlptLevel string (N5) to jlpt int (5) for backend
      if (jlptLevel != null) {
        final jlptInt = _convertJlptLevelToInt(jlptLevel);
        if (jlptInt != null) queryParams['jlpt'] = jlptInt;
      }
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
      // Transform data from app format to backend format
      final backendData = _transformKanjiDataForBackend(kanjiData);

      final response = await _apiClient.post(
        ApiEndpoints.kanji,
        data: backendData,
      );

      // Unwrap backend response: { statusCode, data: { kanji }, timestamp }
      final wrappedData = response.data as Map<String, dynamic>;
      final actualData = wrappedData['data'] as Map<String, dynamic>;

      return KanjiModel.fromJson(actualData);
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
      // Transform data from app format to backend format
      final backendData = _transformKanjiDataForBackend(kanjiData);

      final response = await _apiClient.put(
        ApiEndpoints.kanjiById(id),
        data: backendData,
      );

      // Unwrap backend response: { statusCode, data: { kanji }, timestamp }
      final wrappedData = response.data as Map<String, dynamic>;
      final actualData = wrappedData['data'] as Map<String, dynamic>;

      return KanjiModel.fromJson(actualData);
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
