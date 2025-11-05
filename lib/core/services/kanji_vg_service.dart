import 'package:dio/dio.dart';
import 'cache_service.dart';

/// KanjiVGService - Service để lấy stroke order (thứ tự nét viết) từ KanjiVG
///
/// API: GitHub Repository - https://github.com/KanjiVG/kanjivg
///
/// Chức năng:
/// - Lấy SVG data cho stroke order animation
/// - Parse SVG paths để animate từng nét viết
/// - Cache SVG data (ít khi thay đổi)
///
/// KanjiVG là open-source project chứa stroke order cho hầu hết các kanji
/// SVG files được host trên GitHub và có thể fetch trực tiếp
///
/// Sử dụng trong:
/// - Kanji detail page để hiển thị animated stroke order
/// - Practice mode để học cách viết kanji
class KanjiVGService {
  // Raw URL từ GitHub repository
  static const String _baseUrl =
      'https://raw.githubusercontent.com/KanjiVG/kanjivg/master/kanji';

  final Dio _dio;
  final CacheService _cacheService;

  KanjiVGService(this._dio, this._cacheService);

  /// Lấy SVG paths cho stroke order animation
  ///
  /// Params:
  /// - character: Kanji character (vd: '日', '月', '火')
  ///
  /// Returns: List of SVG path strings, mỗi path là 1 nét viết
  /// VD: ['M 25,39 L 72,39', 'M 48,14 L 48,88', ...]
  ///
  /// Flow:
  /// 1. Check cache
  /// 2. Convert character -> Unicode hex (日 -> 65e5)
  /// 3. Fetch SVG từ GitHub: /kanji/065e5.svg
  /// 4. Parse SVG để extract <path> elements
  /// 5. Cache trong 30 ngày (SVG ít khi thay đổi)
  Future<List<String>?> getStrokeOrderSVG(String character) async {
    try {
      // Check cache trước
      final cacheKey = 'kanjivg_$character';
      final cached = await _cacheService.getList(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached.map((e) => e['path'] as String).toList();
      }

      // Convert character thành Unicode hex code
      // VD: '漢' (U+6F22) -> '06f22'
      final unicode = character.codeUnitAt(0).toRadixString(16).padLeft(5, '0');
      final url = '$_baseUrl/$unicode.svg';

      // Fetch SVG file từ GitHub
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        // Parse SVG content để extract paths
        final paths = _parseSVGPaths(response.data as String);

        // Cache trong 30 ngày (SVG data rarely changes)
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

  /// Parse SVG content để extract stroke paths
  ///
  /// SVG structure:
  /// <svg>
  ///   <g id="kvg:StrokePaths_...">
  ///     <path d="M 25,39 L 72,39" />  <- Nét 1
  ///     <path d="M 48,14 L 48,88" />  <- Nét 2
  ///     ...
  ///   </g>
  /// </svg>
  ///
  /// Dùng RegEx để extract 'd' attribute từ <path> elements
  List<String> _parseSVGPaths(String svgContent) {
    final paths = <String>[];

    // Regex để match <path> elements và extract 'd' attribute
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

  /// Lấy full SVG content (không parse)
  ///
  /// Dùng khi muốn hiển thị complete kanji thay vì animate
  /// Hữu ích cho:
  /// - Preview kanji
  /// - Export as image
  /// - Display static stroke diagram
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
