import 'package:dio/dio.dart';
import '../utils/logger.dart';

/// Service for fetching kanji data from Kanji Alive API (RapidAPI)
/// API: https://rapidapi.com/KanjiAlive/api/learn-to-read-and-write-japanese-kanji
class RapidAPIService {
  final Dio _dio;
  static const String _baseUrl =
      'https://kanjialive-api.p.rapidapi.com/api/public/kanji';
  static const String _apiKey =
      'ab84e2d5d7mshec320cda6671a01p122264jsnfa7b71b22317';
  static const String _apiHost = 'kanjialive-api.p.rapidapi.com';

  RapidAPIService({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetch detailed kanji data including examples, readings, and audio
  ///
  /// Returns a Map containing:
  /// - kanji: { character, meaning, strokes }
  /// - radical: { character, meaning, strokes, image }
  /// - references: { grade, kodansha, classic_nelson }
  /// - examples: [{ japanese, meaning, audio: { opus, aac, ogg, mp3 } }]
  Future<Map<String, dynamic>?> getKanjiData(String kanji) async {
    try {
      final url = '$_baseUrl/$kanji';
      logger.d('Fetching Kanji Alive data from: $url');

      final response = await _dio.get(
        url,
        options: Options(
          headers: {'x-rapidapi-key': _apiKey, 'x-rapidapi-host': _apiHost},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        logger.i('Successfully fetched Kanji Alive data for: $kanji');
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        logger.w('Kanji Alive data not found for: $kanji');
        return null;
      } else if (response.statusCode == 429) {
        logger.e('RapidAPI rate limit exceeded');
        return null;
      } else {
        logger.e('Failed to fetch Kanji Alive data: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      logger.e(
        'Error fetching Kanji Alive data for: $kanji',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Get example words for a kanji
  /// Returns list of examples with japanese text, meaning, and audio URLs
  Future<List<KanjiExample>> getExamples(String kanji) async {
    final data = await getKanjiData(kanji);
    if (data == null || !data.containsKey('examples')) {
      return [];
    }

    final examples = data['examples'] as List;
    return examples
        .map((ex) => KanjiExample.fromJson(ex as Map<String, dynamic>))
        .toList();
  }

  /// Check if Kanji Alive has data for a kanji character
  Future<bool> hasKanjiData(String kanji) async {
    final data = await getKanjiData(kanji);
    return data != null;
  }
}

/// Model for kanji example word with audio
class KanjiExample {
  final String japanese;
  final String meaning;
  final KanjiExampleAudio audio;

  KanjiExample({
    required this.japanese,
    required this.meaning,
    required this.audio,
  });

  factory KanjiExample.fromJson(Map<String, dynamic> json) {
    return KanjiExample(
      japanese: json['japanese'] as String? ?? '',
      meaning: json['meaning']['english'] as String? ?? '',
      audio: KanjiExampleAudio.fromJson(
        json['audio'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// Audio URLs for example word
class KanjiExampleAudio {
  final String? opus;
  final String? aac;
  final String? ogg;
  final String? mp3;

  KanjiExampleAudio({this.opus, this.aac, this.ogg, this.mp3});

  factory KanjiExampleAudio.fromJson(Map<String, dynamic> json) {
    return KanjiExampleAudio(
      opus: json['opus'] as String?,
      aac: json['aac'] as String?,
      ogg: json['ogg'] as String?,
      mp3: json['mp3'] as String?,
    );
  }

  /// Get the best available audio URL (prioritize mp3 for compatibility)
  String? get bestUrl => mp3 ?? aac ?? opus ?? ogg;
}
