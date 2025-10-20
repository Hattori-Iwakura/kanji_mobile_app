import 'package:dio/dio.dart';

/// Model cho thông tin chi tiết từ Jisho API
class JishoKanjiInfo {
  final String character;
  final List<String> meanings;
  final List<String> onyomi;
  final List<String> kunyomi;
  final String? jlptLevel;
  final int? grade;
  final int? strokeCount;
  final List<String> radicals;
  final List<JishoExample> examples;
  final String? strokeOrderImageUrl;
  final String? strokeOrderGifUrl;

  JishoKanjiInfo({
    required this.character,
    required this.meanings,
    required this.onyomi,
    required this.kunyomi,
    this.jlptLevel,
    this.grade,
    this.strokeCount,
    required this.radicals,
    required this.examples,
    this.strokeOrderImageUrl,
    this.strokeOrderGifUrl,
  });

  factory JishoKanjiInfo.fromJson(Map<String, dynamic> json) {
    final senses = json['senses'] as List<dynamic>? ?? [];
    final japanese = json['japanese'] as List<dynamic>? ?? [];

    // Lấy meanings từ senses
    final meanings = <String>[];
    for (var sense in senses) {
      final defs = sense['english_definitions'] as List<dynamic>? ?? [];
      meanings.addAll(defs.map((e) => e.toString()));
    }

    // Lấy readings từ japanese
    final onyomiSet = <String>{};
    final kunyomiSet = <String>{};

    for (var item in japanese) {
      final reading = item['reading'] as String?;
      if (reading != null) {
        if (reading.contains('・')) {
          kunyomiSet.add(reading);
        } else {
          onyomiSet.add(reading);
        }
      }
    }

    // Lấy JLPT level từ tags
    String? jlptLevel;
    for (var sense in senses) {
      final tags = sense['tags'] as List<dynamic>? ?? [];
      for (var tag in tags) {
        final tagStr = tag.toString().toLowerCase();
        if (tagStr.contains('jlpt')) {
          jlptLevel = tagStr.replaceAll('jlpt-', '').toUpperCase();
          break;
        }
      }
      if (jlptLevel != null) break;
    }

    return JishoKanjiInfo(
      character: json['slug'] as String? ?? '',
      meanings: meanings,
      onyomi: onyomiSet.toList(),
      kunyomi: kunyomiSet.toList(),
      jlptLevel: jlptLevel,
      grade: null, // Jisho không cung cấp grade trực tiếp
      strokeCount: null, // Jisho không cung cấp stroke count trực tiếp
      radicals: [],
      examples: [],
      strokeOrderImageUrl: null,
      strokeOrderGifUrl: null,
    );
  }
}

/// Model cho ví dụ câu
class JishoExample {
  final String japanese;
  final String reading;
  final String english;

  JishoExample({
    required this.japanese,
    required this.reading,
    required this.english,
  });

  factory JishoExample.fromJson(Map<String, dynamic> json) {
    return JishoExample(
      japanese: json['japanese'] as String? ?? '',
      reading: json['reading'] as String? ?? '',
      english: json['english'] as String? ?? '',
    );
  }
}

/// Service để gọi Jisho API
class JishoService {
  final Dio _dio;
  static const String _baseUrl = 'https://jisho.org/api/v1';

  JishoService(this._dio);

  /// Tìm kiếm kanji theo từ khóa
  Future<List<JishoKanjiInfo>> searchKanji(String keyword) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search/words',
        queryParameters: {'keyword': keyword},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>? ?? [];
        return data.map((item) => JishoKanjiInfo.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching kanji: $e');
      return [];
    }
  }

  /// Lấy thông tin chi tiết về một kanji
  Future<JishoKanjiInfo?> getKanjiDetail(String character) async {
    try {
      final results = await searchKanji(character);
      if (results.isNotEmpty) {
        return results.first;
      }
      return null;
    } catch (e) {
      print('Error getting kanji detail: $e');
      return null;
    }
  }

  /// Tìm kiếm nhiều kanji cùng lúc
  Future<Map<String, JishoKanjiInfo>> getMultipleKanjiDetails(
    List<String> characters,
  ) async {
    final results = <String, JishoKanjiInfo>{};

    for (var char in characters) {
      final info = await getKanjiDetail(char);
      if (info != null) {
        results[char] = info;
      }
    }

    return results;
  }

  /// Tìm kiếm từ có chứa kanji
  Future<List<Map<String, dynamic>>> searchWords(String kanji) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search/words',
        queryParameters: {'keyword': kanji},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>? ?? [];
        return data.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error searching words: $e');
      return [];
    }
  }
}
