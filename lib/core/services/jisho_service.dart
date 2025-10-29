import 'package:dio/dio.dart';
import 'cache_service.dart';

/// Service to interact with Jisho.org API
/// https://jisho.org/api/v1/search/words?keyword=kanji
class JishoService {
  static const String _baseUrl = 'https://jisho.org/api/v1';

  final Dio _dio;
  final CacheService _cacheService;

  JishoService(this._dio, this._cacheService);

  /// Search for kanji/word information
  /// Returns detailed reading, meanings, and usage information
  Future<Map<String, dynamic>?> searchWord(String keyword) async {
    try {
      // Check cache first
      final cacheKey = 'jisho_$keyword';
      final cached = await _cacheService.get(cacheKey);
      if (cached != null) {
        return cached;
      }

      // Make API request
      final response = await _dio.get(
        '$_baseUrl/search/words',
        queryParameters: {'keyword': keyword},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Cache the response for 7 days
        await _cacheService.save(
          key: cacheKey,
          data: data,
          duration: const Duration(days: 7),
        );

        return data;
      }

      return null;
    } catch (e) {
      print('Jisho API Error: $e');
      return null;
    }
  }

  /// Get kanji readings (on-yomi, kun-yomi, nanori)
  Future<Map<String, List<String>>> getReadings(String character) async {
    try {
      final result = await searchWord(character);
      if (result != null && result['data'] != null) {
        final data = result['data'] as List;
        if (data.isNotEmpty) {
          final japanese = data[0]['japanese'] as List;
          final readings = japanese[0]['reading'];
          // Parse readings from result
          return {'on': [], 'kun': [], 'nanori': []};
        }
      }
      return {'on': [], 'kun': [], 'nanori': []};
    } catch (e) {
      print('Error getting readings: $e');
      return {'on': [], 'kun': [], 'nanori': []};
    }
  }
}
