import 'package:dio/dio.dart';
import '../utils/logger.dart';

/// Service for fetching stroke order SVG data from KanjiVG GitHub repository
/// KanjiVG: https://github.com/KanjiVG/kanjivg
class KanjiVGService {
  final Dio _dio;
  static const String _baseUrl =
      'https://raw.githubusercontent.com/KanjiVG/kanjivg/master/kanji';

  KanjiVGService({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetch stroke order SVG for a given kanji character
  ///
  /// The SVG filename is the Unicode hex code of the kanji character
  /// Example: 漢 (U+6F22) → 06f22.svg
  ///
  /// Returns the SVG XML string if successful, null otherwise
  Future<String?> fetchStrokeSvg(String kanji) async {
    try {
      // Convert kanji to Unicode hex code
      final codePoint = kanji.codeUnitAt(0);
      final hexCode = codePoint.toRadixString(16).padLeft(5, '0');
      final url = '$_baseUrl/$hexCode.svg';

      logger.d('Fetching KanjiVG SVG from: $url');

      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        logger.i('Successfully fetched KanjiVG SVG for: $kanji');
        return response.data as String;
      } else if (response.statusCode == 404) {
        logger.w('KanjiVG SVG not found for: $kanji (code: $hexCode)');
        return null;
      } else {
        logger.e('Failed to fetch KanjiVG SVG: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      logger.e(
        'Error fetching KanjiVG SVG for: $kanji',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Check if KanjiVG data exists for a kanji character
  Future<bool> hasStrokeData(String kanji) async {
    final svg = await fetchStrokeSvg(kanji);
    return svg != null;
  }

  /// Get the KanjiVG URL for a kanji character
  String getStrokeUrl(String kanji) {
    final codePoint = kanji.codeUnitAt(0);
    final hexCode = codePoint.toRadixString(16).padLeft(5, '0');
    return '$_baseUrl/$hexCode.svg';
  }
}
