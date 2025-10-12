import 'package:equatable/equatable.dart';

class Kanji extends Equatable {
  final int id;
  final String character;
  final int strokes;
  final int? grade;
  final int? freq;
  final int? jlptOld;
  final int? jlptNew;
  final List<String> meanings;
  final List<String> readingsOn;
  final List<String> readingsKun;
  final int? wkLevel;
  final List<String>? wkMeanings;
  final List<String>? wkReadingsOn;
  final List<String>? wkReadingsKun;
  final List<String>? wkRadicals;

  const Kanji({
    required this.id,
    required this.character,
    required this.strokes,
    this.grade,
    this.freq,
    this.jlptOld,
    this.jlptNew,
    required this.meanings,
    required this.readingsOn,
    required this.readingsKun,
    this.wkLevel,
    this.wkMeanings,
    this.wkReadingsOn,
    this.wkReadingsKun,
    this.wkRadicals,
  });

  @override
  List<Object?> get props => [
    id,
    character,
    strokes,
    grade,
    freq,
    jlptOld,
    jlptNew,
    meanings,
    readingsOn,
    readingsKun,
    wkLevel,
    wkMeanings,
    wkReadingsOn,
    wkReadingsKun,
    wkRadicals,
  ];
}
