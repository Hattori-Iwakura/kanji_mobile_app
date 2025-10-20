import 'package:dio/dio.dart';

/// Service để lấy dữ liệu từ KanjiVG và các nguồn stroke order
class KanjiVGService {
  final Dio _dio;

  // KanjiVG GitHub raw content
  static const String _kanjiVGBase =
      'https://raw.githubusercontent.com/KanjiVG/kanjivg/master/kanji';

  // Jisho.org stroke diagram
  static const String _jishoStrokeBase =
      'https://classic.jisho.org/static/images/stroke_diagrams';

  KanjiVGService(this._dio);

  /// Lấy URL của SVG stroke order từ KanjiVG
  /// Returns: URL trực tiếp đến file SVG
  String getKanjiVGUrl(String character) {
    // Convert character to Unicode hex (e.g., 漢 -> 6f22)
    final unicode = character.codeUnitAt(0).toRadixString(16).padLeft(5, '0');
    return '$_kanjiVGBase/$unicode.svg';
  }

  /// Lấy URL của stroke diagram từ Jisho.org
  /// Returns: URL trực tiếp đến PNG image
  String getJishoStrokeDiagramUrl(String character) {
    final unicode = character.codeUnitAt(0).toRadixString(16);
    return '$_jishoStrokeBase/$unicode.png';
  }

  /// Lấy SVG content từ KanjiVG
  Future<String?> getKanjiVGSvg(String character) async {
    try {
      final url = getKanjiVGUrl(character);
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error fetching KanjiVG SVG: $e');
      return null;
    }
  }

  /// Kiểm tra xem kanji có stroke diagram không
  Future<bool> hasStrokeDiagram(String character) async {
    try {
      final url = getJishoStrokeDiagramUrl(character);
      final response = await _dio.head(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Lấy nhiều URLs cho animated stroke order
  /// Jisho.org có animated GIF cho một số kanji
  List<String> getAnimatedStrokeUrls(String character) {
    final unicode = character.codeUnitAt(0).toRadixString(16);

    return [
      // Jisho.org stroke diagram (static)
      '$_jishoStrokeBase/$unicode.png',

      // Alternative: AnimCJK project (if available)
      'https://raw.githubusercontent.com/parsimonhi/animCJK/master/svgsJa/${unicode.toUpperCase()}.svg',
    ];
  }

  /// Parse SVG để lấy số nét
  int? getStrokeCountFromSvg(String svgContent) {
    try {
      // Count <path> elements in SVG
      final pathMatches = RegExp(r'<path').allMatches(svgContent);
      return pathMatches.length;
    } catch (e) {
      return null;
    }
  }

  /// Lấy thông tin đầy đủ về stroke order
  Future<KanjiStrokeInfo?> getStrokeInfo(String character) async {
    try {
      final svgContent = await getKanjiVGSvg(character);

      if (svgContent == null) {
        return null;
      }

      final strokeCount = getStrokeCountFromSvg(svgContent);
      final svgUrl = getKanjiVGUrl(character);
      final diagramUrl = getJishoStrokeDiagramUrl(character);
      final animatedUrls = getAnimatedStrokeUrls(character);

      return KanjiStrokeInfo(
        character: character,
        svgUrl: svgUrl,
        svgContent: svgContent,
        strokeCount: strokeCount,
        diagramUrl: diagramUrl,
        animatedUrls: animatedUrls,
      );
    } catch (e) {
      print('Error getting stroke info: $e');
      return null;
    }
  }
}

/// Model cho thông tin stroke order
class KanjiStrokeInfo {
  final String character;
  final String svgUrl;
  final String svgContent;
  final int? strokeCount;
  final String diagramUrl;
  final List<String> animatedUrls;

  KanjiStrokeInfo({
    required this.character,
    required this.svgUrl,
    required this.svgContent,
    this.strokeCount,
    required this.diagramUrl,
    required this.animatedUrls,
  });

  /// Có SVG data không
  bool get hasSvg => svgContent.isNotEmpty;

  /// Có diagram URL không
  bool get hasDiagram => diagramUrl.isNotEmpty;

  /// Có animated URLs không
  bool get hasAnimated => animatedUrls.isNotEmpty;
}
