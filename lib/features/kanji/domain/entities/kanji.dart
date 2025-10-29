import 'package:equatable/equatable.dart';

class Kanji extends Equatable {
  final int id;
  final String character;
  final String meanings;
  final String? onyomi;
  final String? kunyomi;
  final int? jlpt;
  final int? grade;
  final int? strokeCount;
  final int? frequency;
  final String? radical;
  final String? radicalMeaning;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Kanji({
    required this.id,
    required this.character,
    required this.meanings,
    this.onyomi,
    this.kunyomi,
    this.jlpt,
    this.grade,
    this.strokeCount,
    this.frequency,
    this.radical,
    this.radicalMeaning,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    character,
    meanings,
    onyomi,
    kunyomi,
    jlpt,
    grade,
    strokeCount,
    frequency,
    radical,
    radicalMeaning,
    createdAt,
    updatedAt,
  ];
}
