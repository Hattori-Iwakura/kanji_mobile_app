import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'cache_service.dart';

/// Service to interact with KanjiAlive API (RapidAPI)
/// https://rapidapi.com/KanjiAlive/api/learn-to-read-and-write-japanese-kanji
class KanjiAliveService {
  static const String _baseUrl =
      'https://kanjialive-api.p.rapidapi.com/api/public';

  final Dio _dio;
  final CacheService _cacheService;

  KanjiAliveService(this._dio, this._cacheService);

  Map<String, String> get _headers {
    final apiKey = dotenv.env['RAPIDAPI_KEY'] ?? '';
    return {
      'X-RapidAPI-Key': apiKey,
      'X-RapidAPI-Host': 'kanjialive-api.p.rapidapi.com',
    };
  }

  /// Get detailed kanji information
  /// Returns: {
  ///   kanji: { character, meaning, strokes { count, images } },
  ///   radical: { character, meaning, strokes },
  ///   examples: [ { japanese, meaning, audio { opus, aac, ogg, mp3 } } ]
  /// }
  Future<Map<String, dynamic>?> getKanjiInfo(String character) async {
    try {
      // Check cache first
      final cacheKey = 'kanjialive_$character';
      final cached = await _cacheService.get(cacheKey);
      if (cached != null) {
        return cached;
      }

      // Make API request
      final response = await _dio.get(
        '$_baseUrl/kanji/$character',
        options: Options(headers: _headers),
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
      print('KanjiAlive API Error: $e');
      return null;
    }
  }

  /// Get example words/sentences for a kanji
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

  /// Get audio URL for pronunciation
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
