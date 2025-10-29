import '../../domain/entities/kanji.dart';

class KanjiModel extends Kanji {
  const KanjiModel({
    required super.id,
    required super.character,
    required super.meanings,
    super.onyomi,
    super.kunyomi,
    super.jlpt,
    super.grade,
    super.strokeCount,
    super.frequency,
    super.radical,
    super.radicalMeaning,
    required super.createdAt,
    required super.updatedAt,
  });

  factory KanjiModel.fromJson(Map<String, dynamic> json) {
    return KanjiModel(
      id: json['id'] as int,
      character: json['character'] as String,
      meanings: json['meanings'] as String,
      onyomi: json['onyomi'] as String?,
      kunyomi: json['kunyomi'] as String?,
      jlpt: json['jlpt'] as int?,
      grade: json['grade'] as int?,
      strokeCount: json['strokeCount'] as int?,
      frequency: json['frequency'] as int?,
      radical: json['radical'] as String?,
      radicalMeaning: json['radicalMeaning'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'character': character,
      'meanings': meanings,
      'onyomi': onyomi,
      'kunyomi': kunyomi,
      'jlpt': jlpt,
      'grade': grade,
      'strokeCount': strokeCount,
      'frequency': frequency,
      'radical': radical,
      'radicalMeaning': radicalMeaning,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
