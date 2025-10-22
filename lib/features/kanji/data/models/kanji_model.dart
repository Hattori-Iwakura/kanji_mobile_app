import '../../domain/entities/kanji.dart';

/// Kanji model for data layer with JSON serialization
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
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from JSON
  factory KanjiModel.fromJson(Map<String, dynamic> json) {
    return KanjiModel(
      id: json['id'] as int,
      character: json['character'] as String,
      onyomi: json['onyomi'] as String?,
      kunyomi: json['kunyomi'] as String?,
      meanings: json['meanings'] as String,
      strokeCount: json['strokeCount'] as int?,
      jlpt: json['jlpt'] as int?,
      grade: json['grade'] as int?,
      frequency: json['frequency'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'character': character,
      'onyomi': onyomi,
      'kunyomi': kunyomi,
      'meanings': meanings,
      'strokeCount': strokeCount,
      'jlpt': jlpt,
      'grade': grade,
      'frequency': frequency,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert model to entity
  Kanji toEntity() {
    return Kanji(
      id: id,
      character: character,
      onyomi: onyomi,
      kunyomi: kunyomi,
      meanings: meanings,
      strokeCount: strokeCount,
      jlpt: jlpt,
      grade: grade,
      frequency: frequency,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model from entity
  factory KanjiModel.fromEntity(Kanji entity) {
    return KanjiModel(
      id: entity.id,
      character: entity.character,
      onyomi: entity.onyomi,
      kunyomi: entity.kunyomi,
      meanings: entity.meanings,
      strokeCount: entity.strokeCount,
      jlpt: entity.jlpt,
      grade: entity.grade,
      frequency: entity.frequency,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
