import 'package:equatable/equatable.dart';

class KanjiExample extends Equatable {
  final int id;
  final int kanjiId;
  final String word;
  final String reading;
  final String meaning;
  final String? wordType;
  final int? jlptLevel;
  final int? frequency;
  final DateTime createAt;

  const KanjiExample({
    required this.id,
    required this.kanjiId,
    required this.word,
    required this.reading,
    required this.meaning,
    this.wordType,
    this.jlptLevel,
    this.frequency,
    required this.createAt,
  });

  // Get JLPT level as string (N5, N4, N3, N2, N1)
  String? get jlptLevelString {
    if (jlptLevel == null) return null;
    return 'N$jlptLevel';
  }

  @override
  List<Object?> get props => [
    id,
    kanjiId,
    word,
    reading,
    meaning,
    wordType,
    jlptLevel,
    frequency,
    createAt,
  ];
}
