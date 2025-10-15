import 'package:equatable/equatable.dart';

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
  final String? radicals;
  final DateTime createAt;
  final DateTime updateAt;

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
    this.radicals,
    required this.createAt,
    required this.updateAt,
  });

  // Parse meanings from comma-separated string to list
  List<String> get meaningsList {
    return meanings.split(',').map((e) => e.trim()).toList();
  }

  // Parse radicals from comma-separated string to list
  List<String> get radicalsList {
    if (radicals == null || radicals!.isEmpty) return [];
    return radicals!.split(',').map((e) => e.trim()).toList();
  }

  // Get JLPT level as string (N5, N4, N3, N2, N1)
  String? get jlptLevel {
    if (jlpt == null) return null;
    return 'N$jlpt';
  }

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
    radicals,
    createAt,
    updateAt,
  ];
}
