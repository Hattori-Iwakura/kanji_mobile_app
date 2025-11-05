import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'cache_service.dart';

/// KanjiAliveService - Service để lấy thông tin chi tiết về Kanji từ KanjiAlive API
///
/// API Documentation: https://rapidapi.com/KanjiAlive/api/learn-to-read-and-write-japanese-kanji
///
/// Chức năng:
/// - Lấy thông tin kanji: meaning, strokes, images
/// - Lấy thông tin radical (bộ thủ)
/// - Lấy example sentences với audio pronunciation
/// - Cache responses để giảm API calls (save cost & bandwidth)
///
/// API này có giới hạn request (rate limit), nên cần cache
///
/// Sử dụng trong:
/// - KanjiRepository khi cần enrich kanji data
/// - Kanji detail page để hiển thị thông tin chi tiết
class KanjiAliveService {
  static const String _baseUrl =
      'https://kanjialive-api.p.rapidapi.com/api/public';

  final Dio _dio;
  final CacheService _cacheService;

  KanjiAliveService(this._dio, this._cacheService);

  /// Headers cho RapidAPI authentication
  /// API key được lưu trong .env file (RAPIDAPI_KEY)
  Map<String, String> get _headers {
    final apiKey = dotenv.env['RAPIDAPI_KEY'] ?? '';
    return {
      'X-RapidAPI-Key': apiKey,
      'X-RapidAPI-Host': 'kanjialive-api.p.rapidapi.com',
    };
  }

  /// Lấy thông tin chi tiết về kanji
  ///
  /// Params:
  /// - character: Ký tự kanji (vd: '日', '月', '火')
  ///
  /// Returns: Map chứa:
  /// {
  ///   kanji: {
  ///     character: "日",
  ///     meaning: { english: "sun, day" },
  ///     strokes: {
  ///       count: 4,
  ///       images: [url_to_stroke_diagrams]
  ///     }
  ///   },
  ///   radical: {
  ///     character: "日",
  ///     meaning: { english: "sun" },
  ///     strokes: { count: 4 }
  ///   },
  ///   examples: [
  ///     {
  ///       japanese: "日本",
  ///       meaning: { english: "Japan" },
  ///       audio: {
  ///         opus: "url_to_audio.opus",
  ///         aac: "url_to_audio.aac",
  ///         ogg: "url_to_audio.ogg",
  ///         mp3: "url_to_audio.mp3"
  ///       }
  ///     }
  ///   ]
  /// }
  Future<Map<String, dynamic>?> getKanjiInfo(String character) async {
    try {
      // Check cache trước để tránh gọi API không cần thiết
      final cacheKey = 'kanjialive_$character';
      final cached = await _cacheService.get(cacheKey);
      if (cached != null) {
        return cached;
      }

      // Gọi API nếu không có cache
      final response = await _dio.get(
        '$_baseUrl/kanji/$character',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Cache response trong 7 ngày (kanji data ít khi thay đổi)
        await _cacheService.save(
          key: cacheKey,
          data: data,
          duration: const Duration(days: 7),
        );

        return data;
      }

      return null;
    } catch (e) {
      print('KanjiAlive API Error: $e');
      return null;
    }
  }

  /// Lấy danh sách example words/sentences cho kanji
  ///
  /// Returns: List các examples với Japanese text, English meaning, và audio URLs
  Future<List<Map<String, dynamic>>> getExamples(String character) async {
    try {
      final info = await getKanjiInfo(character);
      if (info != null && info['examples'] != null) {
        return List<Map<String, dynamic>>.from(info['examples']);
      }
      return [];
    } catch (e) {
      print('Error getting examples: $e');
      return [];
    }
  }

  /// Lấy audio URL cho pronunciation
  ///
  /// Returns: MP3 URL của example đầu tiên (most common word)
  /// Dùng để play audio pronunciation khi user tap vào speaker icon
  Future<String?> getAudioUrl(String character) async {
    try {
      final examples = await getExamples(character);
      if (examples.isNotEmpty) {
        final audio = examples[0]['audio'];
        return audio['mp3'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting audio: $e');
      return null;
    }
  }
}
