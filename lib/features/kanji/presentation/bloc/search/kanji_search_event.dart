import 'package:equatable/equatable.dart';
import '../../../domain/usecases/search_kanji.dart';

abstract class KanjiSearchEvent extends Equatable {
  const KanjiSearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchKanjiRequested extends KanjiSearchEvent {
  final SearchKanjiParams params;

  const SearchKanjiRequested(this.params);

  @override
  List<Object?> get props => [params];
}

class LoadMoreResults extends KanjiSearchEvent {
  const LoadMoreResults();
}

class ClearSearch extends KanjiSearchEvent {
  const ClearSearch();
}

class UpdateFilters extends KanjiSearchEvent {
  final List<int>? jlptLevels;
  final List<int>? grades;
  final int? minStrokes;
  final int? maxStrokes;
  final String? radical;
  final String? sortBy;

  const UpdateFilters({
    this.jlptLevels,
    this.grades,
    this.minStrokes,
    this.maxStrokes,
    this.radical,
    this.sortBy,
  });

  @override
  List<Object?> get props => [
    jlptLevels,
    grades,
    minStrokes,
    maxStrokes,
    radical,
    sortBy,
  ];
}
