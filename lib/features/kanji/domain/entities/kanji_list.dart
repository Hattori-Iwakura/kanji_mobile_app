import 'package:equatable/equatable.dart';

enum ListFilterType { jlptLevel, frequency, grade, custom }

class KanjiList extends Equatable {
  final int id;
  final String name;
  final String? description;
  final ListFilterType filterType;
  final int? filterValue; // JLPT level, grade, or frequency range
  final int? frequencyMin; // For frequency range filter
  final int? frequencyMax; // For frequency range filter
  final DateTime createdAt;
  final DateTime updatedAt;
  final int kanjiCount; // Number of kanji in this list

  const KanjiList({
    required this.id,
    required this.name,
    this.description,
    required this.filterType,
    this.filterValue,
    this.frequencyMin,
    this.frequencyMax,
    required this.createdAt,
    required this.updatedAt,
    required this.kanjiCount,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    filterType,
    filterValue,
    frequencyMin,
    frequencyMax,
    createdAt,
    updatedAt,
    kanjiCount,
  ];
}
