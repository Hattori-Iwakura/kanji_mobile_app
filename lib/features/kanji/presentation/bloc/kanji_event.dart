import 'package:equatable/equatable.dart';

abstract class KanjiEvent extends Equatable {
  const KanjiEvent();

  @override
  List<Object?> get props => [];
}

class LoadKanjiListEvent extends KanjiEvent {
  final int? jlpt;
  final int? grade;
  final String? search;
  final int? limit;
  final int? offset;

  const LoadKanjiListEvent({
    this.jlpt,
    this.grade,
    this.search,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [jlpt, grade, search, limit, offset];
}

class LoadMoreKanjiEvent extends KanjiEvent {
  final int? jlpt;
  final int? grade;
  final String? search;
  final int? limit;
  final int? offset;

  const LoadMoreKanjiEvent({
    this.jlpt,
    this.grade,
    this.search,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [jlpt, grade, search, limit, offset];
}

class SearchKanjiEvent extends KanjiEvent {
  final String? query;
  final List<int>? jlptLevels;
  final List<int>? grades;
  final int? minStrokes;
  final int? maxStrokes;
  final int page;
  final int limit;
  final String? sortBy;

  const SearchKanjiEvent({
    this.query,
    this.jlptLevels,
    this.grades,
    this.minStrokes,
    this.maxStrokes,
    this.page = 1,
    this.limit = 20,
    this.sortBy,
  });

  @override
  List<Object?> get props => [
    query,
    jlptLevels,
    grades,
    minStrokes,
    maxStrokes,
    page,
    limit,
    sortBy,
  ];
}

class LoadKanjiDetailEvent extends KanjiEvent {
  final String character;

  const LoadKanjiDetailEvent(this.character);

  @override
  List<Object?> get props => [character];
}

class SearchByCanvasEvent extends KanjiEvent {
  final String imageBase64;

  const SearchByCanvasEvent(this.imageBase64);

  @override
  List<Object?> get props => [imageBase64];
}

class UpdateKanjiEvent extends KanjiEvent {
  final int id;
  final String? character;
  final String? meanings;
  final String? onReadings;
  final String? kunReadings;
  final int? jlptLevel;
  final int? grade;
  final int? strokeCount;
  final int? frequency;
  final List<String>? tags;

  const UpdateKanjiEvent({
    required this.id,
    this.character,
    this.meanings,
    this.onReadings,
    this.kunReadings,
    this.jlptLevel,
    this.grade,
    this.strokeCount,
    this.frequency,
    this.tags,
  });

  @override
  List<Object?> get props => [
    id,
    character,
    meanings,
    onReadings,
    kunReadings,
    jlptLevel,
    grade,
    strokeCount,
    frequency,
    tags,
  ];
}
