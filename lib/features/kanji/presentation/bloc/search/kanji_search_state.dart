import 'package:equatable/equatable.dart';
import '../../../domain/entities/kanji_search_result.dart';
import '../../../domain/usecases/search_kanji.dart';

abstract class KanjiSearchState extends Equatable {
  const KanjiSearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends KanjiSearchState {
  const SearchInitial();
}

class SearchLoading extends KanjiSearchState {
  const SearchLoading();
}

class SearchLoadingMore extends KanjiSearchState {
  final KanjiSearchResult currentResult;
  final SearchKanjiParams params;

  const SearchLoadingMore({required this.currentResult, required this.params});

  @override
  List<Object?> get props => [currentResult, params];
}

class SearchLoaded extends KanjiSearchState {
  final KanjiSearchResult result;
  final SearchKanjiParams params;
  final bool hasReachedMax;

  const SearchLoaded({
    required this.result,
    required this.params,
    this.hasReachedMax = false,
  });

  SearchLoaded copyWith({
    KanjiSearchResult? result,
    SearchKanjiParams? params,
    bool? hasReachedMax,
  }) {
    return SearchLoaded(
      result: result ?? this.result,
      params: params ?? this.params,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [result, params, hasReachedMax];
}

class SearchError extends KanjiSearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
