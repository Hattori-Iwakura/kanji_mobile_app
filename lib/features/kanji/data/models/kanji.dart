import '../../domain/entities/kanji_entity.dart';

class KanjiModel extends KanjiEntity {
  const KanjiModel({
    required super.id,
    required super.character,
    super.jlptLevel,
    super.grade,
    required super.strokeCount,
    required super.meanings,
    super.frequency,
    super.onyomi,
    super.kunyomi,
    super.hanviet,
    super.meaningMnemonic,
    super.readingMnemonic,
    required super.createdAt,
    required super.updatedAt,
  });

  factory KanjiModel.fromJson(Map<String, dynamic> json) {
    // Backend returns 'jlpt' (int 5) but we need 'jlptLevel' (string "N5")
    String? jlptLevel;
    if (json['jlpt'] != null) {
      jlptLevel = 'N${json['jlpt']}';
    } else if (json['jlptLevel'] != null) {
      jlptLevel = json['jlptLevel'] as String;
    }

    // Backend returns 'meanings' as String "one, two" but we need List<String>
    List<String> meanings;
    if (json['meanings'] is String) {
      meanings = (json['meanings'] as String)
          .split(',')
          .map((e) => e.trim())
          .toList();
    } else if (json['meanings'] is List) {
      meanings = (json['meanings'] as List<dynamic>)
          .map((e) => e as String)
          .toList();
    } else {
      meanings = [];
    }

    return KanjiModel(
      id: json['id'] as int,
      character: json['character'] as String,
      jlptLevel: jlptLevel,
      grade: json['grade'] as int?,
      strokeCount: json['strokeCount'] as int,
      meanings: meanings,
      frequency: json['frequency'] as int?,
      onyomi: json['onyomi'] as String?,
      kunyomi: json['kunyomi'] as String?,
      hanviet: json['hanviet'] as String?,
      meaningMnemonic: json['meaningMnemonic'] as String?,
      readingMnemonic: json['readingMnemonic'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'character': character,
      'jlptLevel': jlptLevel,
      'grade': grade,
      'strokeCount': strokeCount,
      'meanings': meanings,
      'frequency': frequency,
      'onyomi': onyomi,
      'kunyomi': kunyomi,
      'hanviet': hanviet,
      'meaningMnemonic': meaningMnemonic,
      'readingMnemonic': readingMnemonic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  KanjiEntity toEntity() {
    return KanjiEntity(
      id: id,
      character: character,
      jlptLevel: jlptLevel,
      grade: grade,
      strokeCount: strokeCount,
      meanings: meanings,
      frequency: frequency,
      onyomi: onyomi,
      kunyomi: kunyomi,
      hanviet: hanviet,
      meaningMnemonic: meaningMnemonic,
      readingMnemonic: readingMnemonic,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
