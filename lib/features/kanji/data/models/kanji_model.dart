import '../../domain/entities/kanji.dart';

class KanjiModel extends Kanji {
  const KanjiModel({
    required super.id,
    required super.character,
    super.onyomi,
    super.kunyomi,
    required super.meanings,
    super.strokeCount,
    super.jlpt,
    super.grade,
    super.frequency,
    super.radicals,
    required super.createAt,
    required super.updateAt,
  });

  factory KanjiModel.fromJson(Map<String, dynamic> json) {
    return KanjiModel(
      id: json['id'] as int,
      character: json['character'] as String,
      onyomi: json['onyomi'] as String?,
      kunyomi: json['kunyomi'] as String?,
      meanings: json['meanings'] as String,
      strokeCount: json['stroke_count'] as int?,
      jlpt: json['jlpt'] as int?,
      grade: json['grade'] as int?,
      frequency: json['frequency'] as int?,
      radicals: json['radicals'] as String?,
      createAt: DateTime.parse(json['create_at'] as String),
      updateAt: DateTime.parse(json['update_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'character': character,
      'onyomi': onyomi,
      'kunyomi': kunyomi,
      'meanings': meanings,
      'stroke_count': strokeCount,
      'jlpt': jlpt,
      'grade': grade,
      'frequency': frequency,
      'radicals': radicals,
      'create_at': createAt.toIso8601String(),
      'update_at': updateAt.toIso8601String(),
    };
  }
}
