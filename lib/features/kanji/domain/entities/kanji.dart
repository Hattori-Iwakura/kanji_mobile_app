import 'package:equatable/equatable.dart';

/// Kanji entity representing a Japanese character with its properties
class Kanji extends Equatable {
  final int id;
  final String character;
  final String? onyomi;
  final String? kunyomi;
  final String meanings;
  final int? strokeCount;
  final int? jlpt;
  final int? grade;
  final int? frequency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Kanji({
    required this.id,
    required this.character,
    this.onyomi,
    this.kunyomi,
    required this.meanings,
    this.strokeCount,
    this.jlpt,
    this.grade,
    this.frequency,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    character,
    onyomi,
    kunyomi,
    meanings,
    strokeCount,
    jlpt,
    grade,
    frequency,
    createdAt,
    updatedAt,
  ];

  /// Get list of meanings as array
  List<String> get meaningsList =>
      meanings.split(',').map((e) => e.trim()).toList();

  /// Get JLPT level as string (e.g., "N5", "N4")
  String? get jlptLevel => jlpt != null ? 'N$jlpt' : null;

  /// Get grade level label (e.g., "Grade 1")
  String? get gradeLevel => grade != null ? 'Grade $grade' : null;
}
