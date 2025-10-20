import 'package:dio/dio.dart';

/// Service để lấy thông tin kanji từ KanjiAlive API
/// API Documentation: https://rapidapi.com/KanjiAlive/api/learn-to-read-and-write-japanese-kanji
class KanjiAliveService {
  final Dio _dio;

  // KanjiAlive API trên RapidAPI
  static const String _baseUrl =
      'https://kanjialive-api.p.rapidapi.com/api/public';

  // RapidAPI credentials
  static const String _apiKey =
      'ab84e2d5d7mshec320cda6671a01p122264jsnfa7b71b22317';
  static const String _apiHost = 'kanjialive-api.p.rapidapi.com';

  KanjiAliveService(this._dio);

  /// Lấy thông tin đầy đủ về kanji
  Future<KanjiAliveInfo?> getKanjiInfo(String character) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/kanji/$character',
        options: Options(
          headers: {'X-RapidAPI-Key': _apiKey, 'X-RapidAPI-Host': _apiHost},
        ),
      );

      if (response.statusCode == 200) {
        return KanjiAliveInfo.fromJson(response.data);
      }
      return null;
    } catch (e, stackTrace) {
      print('Error fetching kanji from KanjiAlive: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Tìm kiếm kanji theo radical
  Future<List<KanjiAliveInfo>> searchByRadical(String radical) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search/advanced',
        queryParameters: {'rad': radical},
        options: Options(
          headers: {'X-RapidAPI-Key': _apiKey, 'X-RapidAPI-Host': _apiHost},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => KanjiAliveInfo.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching kanji by radical: $e');
      return [];
    }
  }

  /// Tìm kiếm kanji theo grade
  Future<List<KanjiAliveInfo>> searchByGrade(int grade) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search/advanced',
        queryParameters: {'grade': grade},
        options: Options(
          headers: {'X-RapidAPI-Key': _apiKey, 'X-RapidAPI-Host': _apiHost},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => KanjiAliveInfo.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching kanji by grade: $e');
      return [];
    }
  }
}

/// Model đầy đủ cho thông tin kanji từ KanjiAlive
class KanjiAliveInfo {
  final KanjiCharacter kanji;
  final RadicalInfo radical;
  final List<Reference> references;
  final List<KanjiExample> examples;

  KanjiAliveInfo({
    required this.kanji,
    required this.radical,
    required this.references,
    required this.examples,
  });

  factory KanjiAliveInfo.fromJson(Map<String, dynamic> json) {
    // Map API response structure to our models
    return KanjiAliveInfo(
      kanji: KanjiCharacter.fromJson({
        'character': json['kanji']?['character'] ?? '',
        'stroke': json['kstroke'] ?? 0,
        'meaning': {'english': json['meaning'] ?? ''},
        'onyomi': {
          'romaji': json['onyomi'] ?? '',
          'katakana': json['ka_utf'] ?? '',
          'hiragana': json['ka_utf'] ?? '',
        },
        'kunyomi': {
          'romaji': json['kunyomi'] ?? '',
          'katakana': json['kun_utf'] ?? '',
          'hiragana': json['kun_utf'] ?? '',
        },
        'video': json['kanji']?['video'] ?? {},
      }),
      radical: RadicalInfo.fromJson({
        'character': json['radical']?['character'] ?? '',
        'stroke': json['radical']?['stroke'] ?? 0,
        'meaning': json['radical']?['meaning'] ?? {},
        'image': json['radical']?['image'] ?? '',
        'position': json['radical']?['position'] ?? '',
        'name': json['rad_name_ja'] ?? '',
        'animation': json['radical']?['animation'] ?? {},
      }),
      references: [
        Reference(name: 'grade', value: json['grade']?.toString() ?? ''),
        Reference(
          name: 'hint_group',
          value: json['hint_group']?.toString() ?? '',
        ),
      ],
      examples:
          (json['examples'] as List<dynamic>?)
              ?.map((item) => KanjiExample.fromJson(item))
              .toList() ??
          [],
    );
  }
}

/// Thông tin về ký tự kanji
class KanjiCharacter {
  final String character;
  final int stroke;
  final KanjiMeaning meaning;
  final KanjiReading onyomi;
  final KanjiReading kunyomi;
  final VideoInfo video;

  KanjiCharacter({
    required this.character,
    required this.stroke,
    required this.meaning,
    required this.onyomi,
    required this.kunyomi,
    required this.video,
  });

  factory KanjiCharacter.fromJson(Map<String, dynamic> json) {
    return KanjiCharacter(
      character: json['character']?.toString() ?? '',
      stroke: json['stroke'] is int
          ? json['stroke']
          : int.tryParse(json['stroke']?.toString() ?? '0') ?? 0,
      meaning: KanjiMeaning.fromJson(
        json['meaning'] is Map<String, dynamic> ? json['meaning'] : {},
      ),
      onyomi: KanjiReading.fromJson(
        json['onyomi'] is Map<String, dynamic> ? json['onyomi'] : {},
      ),
      kunyomi: KanjiReading.fromJson(
        json['kunyomi'] is Map<String, dynamic> ? json['kunyomi'] : {},
      ),
      video: VideoInfo.fromJson(
        json['video'] is Map<String, dynamic> ? json['video'] : {},
      ),
    );
  }
}

/// Nghĩa của kanji
class KanjiMeaning {
  final String english;

  KanjiMeaning({required this.english});

  factory KanjiMeaning.fromJson(Map<String, dynamic> json) {
    return KanjiMeaning(english: json['english']?.toString() ?? '');
  }

  List<String> get meanings => english.split(', ');
}

/// Thông tin đọc (Onyomi/Kunyomi)
class KanjiReading {
  final String romaji;
  final String katakana;
  final String hiragana;

  KanjiReading({
    required this.romaji,
    required this.katakana,
    required this.hiragana,
  });

  factory KanjiReading.fromJson(Map<String, dynamic> json) {
    return KanjiReading(
      romaji: json['romaji']?.toString() ?? '',
      katakana: json['katakana']?.toString() ?? '',
      hiragana: json['hiragana']?.toString() ?? '',
    );
  }

  bool get isEmpty => romaji.isEmpty && katakana.isEmpty && hiragana.isEmpty;
}

/// Thông tin video hướng dẫn viết
class VideoInfo {
  final String poster;
  final String mp4;
  final String webm;

  VideoInfo({required this.poster, required this.mp4, required this.webm});

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      poster: json['poster']?.toString() ?? '',
      mp4: json['mp4']?.toString() ?? '',
      webm: json['webm']?.toString() ?? '',
    );
  }

  bool get hasVideo => mp4.isNotEmpty || webm.isNotEmpty;
}

/// Thông tin về bộ thủ (radical)
class RadicalInfo {
  final String character;
  final int stroke;
  final RadicalMeaning meaning;
  final String image;
  final String position;
  final RadicalName name;
  final AudioInfo animation;

  RadicalInfo({
    required this.character,
    required this.stroke,
    required this.meaning,
    required this.image,
    required this.position,
    required this.name,
    required this.animation,
  });

  factory RadicalInfo.fromJson(Map<String, dynamic> json) {
    final nameData = json['name'];
    final RadicalName radicalName;

    if (nameData is Map<String, dynamic>) {
      radicalName = RadicalName.fromJson(nameData);
    } else if (nameData is String) {
      // rad_name_ja is Japanese hiragana name
      radicalName = RadicalName(hiragana: nameData, romaji: '');
    } else {
      radicalName = RadicalName(hiragana: '', romaji: '');
    }

    return RadicalInfo(
      character: json['character']?.toString() ?? '',
      stroke: json['stroke'] is int
          ? json['stroke']
          : int.tryParse(json['stroke']?.toString() ?? '0') ?? 0,
      meaning: RadicalMeaning.fromJson(
        json['meaning'] is Map<String, dynamic> ? json['meaning'] : {},
      ),
      image: json['image']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      name: radicalName,
      animation: AudioInfo.fromJson(
        json['animation'] is Map<String, dynamic> ? json['animation'] : {},
      ),
    );
  }
}

/// Nghĩa của radical
class RadicalMeaning {
  final String english;

  RadicalMeaning({required this.english});

  factory RadicalMeaning.fromJson(Map<String, dynamic> json) {
    return RadicalMeaning(english: json['english']?.toString() ?? '');
  }
}

/// Tên của radical
class RadicalName {
  final String hiragana;
  final String romaji;

  RadicalName({required this.hiragana, required this.romaji});

  factory RadicalName.fromJson(Map<String, dynamic> json) {
    return RadicalName(
      hiragana: json['hiragana']?.toString() ?? '',
      romaji: json['romaji']?.toString() ?? '',
    );
  }

  static RadicalName fromString(String name) {
    return RadicalName(hiragana: name, romaji: '');
  }
}

/// Thông tin audio/animation
class AudioInfo {
  final String mp4;
  final String webm;
  final String poster;

  AudioInfo({required this.mp4, required this.webm, required this.poster});

  factory AudioInfo.fromJson(Map<String, dynamic> json) {
    return AudioInfo(
      mp4: json['mp4']?.toString() ?? '',
      webm: json['webm']?.toString() ?? '',
      poster: json['poster']?.toString() ?? '',
    );
  }

  bool get hasAudio => mp4.isNotEmpty || webm.isNotEmpty;
}

/// Ví dụ sử dụng kanji
class KanjiExample {
  final String japanese;
  final KanjiExampleMeaning meaning;
  final AudioExamples audio;

  KanjiExample({
    required this.japanese,
    required this.meaning,
    required this.audio,
  });

  factory KanjiExample.fromJson(Map<String, dynamic> json) {
    return KanjiExample(
      japanese: json['japanese']?.toString() ?? '',
      meaning: KanjiExampleMeaning.fromJson(
        json['meaning'] is Map<String, dynamic> ? json['meaning'] : {},
      ),
      audio: AudioExamples.fromJson(
        json['audio'] is Map<String, dynamic> ? json['audio'] : {},
      ),
    );
  }
}

/// Nghĩa của example
class KanjiExampleMeaning {
  final String english;

  KanjiExampleMeaning({required this.english});

  factory KanjiExampleMeaning.fromJson(Map<String, dynamic> json) {
    return KanjiExampleMeaning(english: json['english']?.toString() ?? '');
  }
}

/// Audio cho examples
class AudioExamples {
  final String opus;
  final String aac;
  final String ogg;
  final String mp3;

  AudioExamples({
    required this.opus,
    required this.aac,
    required this.ogg,
    required this.mp3,
  });

  factory AudioExamples.fromJson(Map<String, dynamic> json) {
    // Helper function to extract URL from either String or Map
    String extractUrl(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        // Try common keys for URL
        return value['url'] ?? value['mp3'] ?? value['file'] ?? '';
      }
      return '';
    }

    return AudioExamples(
      opus: extractUrl(json['opus']),
      aac: extractUrl(json['aac']),
      ogg: extractUrl(json['ogg']),
      mp3: extractUrl(json['mp3']),
    );
  }

  bool get hasAudio =>
      opus.isNotEmpty || aac.isNotEmpty || ogg.isNotEmpty || mp3.isNotEmpty;

  /// Get best audio format for current platform
  String get bestAudioUrl {
    if (mp3.isNotEmpty) return mp3;
    if (aac.isNotEmpty) return aac;
    if (opus.isNotEmpty) return opus;
    if (ogg.isNotEmpty) return ogg;
    return '';
  }
}

/// Reference information (grade, JLPT, etc.)
class Reference {
  final String name;
  final String value;

  Reference({required this.name, required this.value});
}
