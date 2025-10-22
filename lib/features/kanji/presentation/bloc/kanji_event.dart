import 'package:equatable/equatable.dart';

/// Base event for Kanji BLoC
abstract class KanjiEvent extends Equatable {
  const KanjiEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all kanji with optional filters
class LoadAllKanjiEvent extends KanjiEvent {
  final int? jlpt;
  final int? grade;
  final String? search;
  final int? limit;
  final int? offset;

  const LoadAllKanjiEvent({
    this.jlpt,
    this.grade,
    this.search,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [jlpt, grade, search, limit, offset];
}

/// Event to load kanji by ID
class LoadKanjiByIdEvent extends KanjiEvent {
  final int id;

  const LoadKanjiByIdEvent(this.id);

  @override
  List<Object> get props => [id];
}

/// Event to search kanji with advanced filters
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
