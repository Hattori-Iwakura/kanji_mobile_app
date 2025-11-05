import 'package:dio/dio.dart';
import 'cache_service.dart';

/// JishoService - Service để search và lấy thông tin từ Jisho.org API
///
/// API Documentation: https://jisho.org/forum/54fefc1f6e73340b1f160000-is-there-any-kind-of-search-api
///
/// Chức năng:
/// - Search kanji/words với keyword
/// - Lấy readings (on-yomi, kun-yomi, nanori)
/// - Lấy meanings và example sentences
/// - Free API, không cần API key
///
/// Jisho.org là dictionary phổ biến cho người học tiếng Nhật
///
/// Sử dụng trong:
/// - KanjiRepository để enrich kanji data
/// - Search functionality
class JishoService {
  static const String _baseUrl = 'https://jisho.org/api/v1';

  final Dio _dio;
  final CacheService _cacheService;

  JishoService(this._dio, this._cacheService);

  /// Search kanji/word với keyword
  ///
  /// Params:
  /// - keyword: Kanji character hoặc word để search
  ///
  /// Returns: Map chứa search results:
  /// {
  ///   data: [
  ///     {
  ///       slug: "日",
  ///       is_common: true,
  ///       tags: ["jlpt-n5"],
  ///       jlpt: ["jlpt-n5"],
  ///       japanese: [
  ///         { word: "日", reading: "ひ" },
  ///         { word: "日", reading: "にち" }
  ///       ],
  ///       senses: [
  ///         {
  ///           english_definitions: ["day", "sun", "Japan"],
  ///           parts_of_speech: ["noun"],
  ///           tags: [],
  ///           info: []
  ///         }
  ///       ]
  ///     }
  ///   ]
  /// }
  Future<Map<String, dynamic>?> searchWord(String keyword) async {
    try {
      // Check cache trước
      final cacheKey = 'jisho_$keyword';
      final cached = await _cacheService.get(cacheKey);
      if (cached != null) {
        return cached;
      }

      // Gọi Jisho API
      final response = await _dio.get(
        '$_baseUrl/search/words',
        queryParameters: {'keyword': keyword},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Cache trong 7 ngày
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

  /// Lấy readings (cách đọc) của kanji
  ///
  /// Returns: Map với 3 loại readings:
  /// - on: On-yomi (âm Hán Việt, đọc theo tiếng Trung)
  /// - kun: Kun-yomi (âm Nhật, đọc theo tiếng Nhật gốc)
  /// - nanori: Cách đọc dùng trong tên người
  ///
  /// VD: 日 -> { on: ['ニチ', 'ジツ'], kun: ['ひ', 'か'], nanori: [] }
  Future<Map<String, List<String>>> getReadings(String character) async {
    try {
      final result = await searchWord(character);
      if (result != null && result['data'] != null) {
        final data = result['data'] as List;
        if (data.isNotEmpty) {
          // Extract readings từ API response
          // final japanese = data[0]['japanese'] as List;
          // final readings = japanese[0]['reading'];

          // TODO: Parse và phân loại readings thành on/kun/nanori
          // Hiện tại return empty vì API không phân loại rõ ràng
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
