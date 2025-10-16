import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/kanji.dart';
import '../../../domain/entities/kanji_search_result.dart';
import '../../../domain/usecases/search_kanji.dart';
import 'kanji_search_event.dart';
import 'kanji_search_state.dart';

class KanjiSearchBloc extends Bloc<KanjiSearchEvent, KanjiSearchState> {
  final SearchKanjiUseCase searchKanji;

  KanjiSearchBloc({required this.searchKanji}) : super(const SearchInitial()) {
    on<SearchKanjiRequested>(_onSearchKanjiRequested);
    on<LoadMoreResults>(_onLoadMoreResults);
    on<ClearSearch>(_onClearSearch);
    on<UpdateFilters>(_onUpdateFilters);
  }

  Future<void> _onSearchKanjiRequested(
    SearchKanjiRequested event,
    Emitter<KanjiSearchState> emit,
  ) async {
    emit(const SearchLoading());

    final result = await searchKanji(event.params);

    result.fold((failure) => emit(SearchError(failure.message)), (
      searchResult,
    ) {
      final hasReachedMax = !searchResult.hasNextPage;
      emit(
        SearchLoaded(
          result: searchResult,
          params: event.params,
          hasReachedMax: hasReachedMax,
        ),
      );
    });
  }

  Future<void> _onLoadMoreResults(
    LoadMoreResults event,
    Emitter<KanjiSearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchLoaded) return;
    if (currentState.hasReachedMax) return;

    // Emit loading more state
    emit(
      SearchLoadingMore(
        currentResult: currentState.result,
        params: currentState.params,
      ),
    );

    // Create new params with incremented page
    final nextPage = currentState.params.page! + 1;
    final newParams = currentState.params.copyWith(page: nextPage);

    final result = await searchKanji(newParams);

    result.fold(
      (failure) {
        // On error, go back to previous loaded state
        emit(currentState);
        emit(SearchError(failure.message));
      },
      (searchResult) {
        // Combine old and new data
        final allKanji = List<Kanji>.from(currentState.result.data)
          ..addAll(searchResult.data);

        final combinedResult = KanjiSearchResult(
          data: allKanji,
          meta: searchResult.meta,
        );

        final hasReachedMax = !searchResult.hasNextPage;

        emit(
          SearchLoaded(
            result: combinedResult,
            params: newParams,
            hasReachedMax: hasReachedMax,
          ),
        );
      },
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<KanjiSearchState> emit) {
    emit(const SearchInitial());
  }

  Future<void> _onUpdateFilters(
    UpdateFilters event,
    Emitter<KanjiSearchState> emit,
  ) async {
    final currentState = state;

    SearchKanjiParams params;

    if (currentState is SearchLoaded) {
      // Update existing params with new filters
      params = currentState.params.copyWith(
        jlptLevels: event.jlptLevels,
        grades: event.grades,
        minStrokes: event.minStrokes,
        maxStrokes: event.maxStrokes,
        radical: event.radical,
        sortBy: event.sortBy,
        page: 1, // Reset to first page when filters change
      );
    } else {
      // Create new params with filters
      params = SearchKanjiParams(
        jlptLevels: event.jlptLevels,
        grades: event.grades,
        minStrokes: event.minStrokes,
        maxStrokes: event.maxStrokes,
        radical: event.radical,
        sortBy: event.sortBy,
        page: 1,
      );
    }

    // Trigger new search with updated filters
    add(SearchKanjiRequested(params));
  }
}
