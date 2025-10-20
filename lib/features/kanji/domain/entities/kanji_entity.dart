import 'package:equatable/equatable.dart';

class KanjiEntity extends Equatable {
  final int id;
  final String character;
  final String? jlptLevel;
  final int? grade;
  final int strokeCount;
  final List<String> meanings;
  final int? frequency;
  final String? onyomi;
  final String? kunyomi;
  final String? hanviet;
  final String? meaningMnemonic;
  final String? readingMnemonic;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KanjiEntity({
    required this.id,
    required this.character,
    this.jlptLevel,
    this.grade,
    required this.strokeCount,
    required this.meanings,
    this.frequency,
    this.onyomi,
    this.kunyomi,
    this.hanviet,
    this.meaningMnemonic,
    this.readingMnemonic,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    character,
    jlptLevel,
    grade,
    strokeCount,
    meanings,
    frequency,
    onyomi,
    kunyomi,
    hanviet,
    meaningMnemonic,
    readingMnemonic,
    createdAt,
    updatedAt,
  ];
}
