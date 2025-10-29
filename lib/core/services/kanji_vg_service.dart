import 'package:dio/dio.dart';
import 'cache_service.dart';

/// Service to get stroke order SVG data from KanjiVG
/// https://github.com/KanjiVG/kanjivg
class KanjiVGService {
  static const String _baseUrl =
      'https://raw.githubusercontent.com/KanjiVG/kanjivg/master/kanji';

  final Dio _dio;
  final CacheService _cacheService;

  KanjiVGService(this._dio, this._cacheService);

  /// Get SVG data for stroke order animation
  /// Returns list of SVG paths for each stroke
  Future<List<String>?> getStrokeOrderSVG(String character) async {
    try {
      // Check cache first
      final cacheKey = 'kanjivg_$character';
      final cached = await _cacheService.getList(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached.map((e) => e['path'] as String).toList();
      }

      // Convert character to Unicode hex (e.g., '漢' -> '6f22')
      final unicode = character.codeUnitAt(0).toRadixString(16).padLeft(5, '0');
      final url = '$_baseUrl/$unicode.svg';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final paths = _parseSVGPaths(response.data as String);

        // Cache the paths for 30 days (SVG data rarely changes)
        await _cacheService.saveList(
          key: cacheKey,
          data: paths.map((path) => {'path': path}).toList(),
          duration: const Duration(days: 30),
        );

        return paths;
      }

      return null;
    } catch (e) {
      print('KanjiVG Error: $e');
      return null;
    }
  }

  /// Parse SVG content to extract stroke paths
  List<String> _parseSVGPaths(String svgContent) {
    final paths = <String>[];

    // Simple regex to extract <path> elements
    final pathRegex = RegExp(r'<path[^>]*d="([^"]*)"[^>]*/>');
    final matches = pathRegex.allMatches(svgContent);

    for (final match in matches) {
      final pathData = match.group(1);
      if (pathData != null && pathData.isNotEmpty) {
        paths.add(pathData);
      }
    }

    return paths;
  }

  /// Get full SVG content (for displaying complete kanji)
  Future<String?> getFullSVG(String character) async {
    try {
      final unicode = character.codeUnitAt(0).toRadixString(16).padLeft(5, '0');
      final url = '$_baseUrl/$unicode.svg';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return response.data as String;
      }

      return null;
    } catch (e) {
      print('KanjiVG Error: $e');
      return null;
    }
  }
}
