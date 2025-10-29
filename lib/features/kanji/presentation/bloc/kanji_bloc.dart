import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_kanji_list.dart';
import '../../domain/usecases/get_kanji_detail.dart';
import '../../domain/usecases/search_kanji.dart';
import '../../domain/usecases/update_kanji.dart';
import '../../domain/repositories/kanji_repository.dart';
import '../../domain/entities/kanji.dart';
import 'kanji_event.dart';
import 'kanji_state.dart';

class KanjiBloc extends Bloc<KanjiEvent, KanjiState> {
  final GetKanjiList getKanjiList;
  final GetKanjiDetail getKanjiDetail;
  final SearchKanji searchKanji;
  final UpdateKanji updateKanji;
  final KanjiRepository kanjiRepository;

  KanjiBloc({
    required this.getKanjiList,
    required this.getKanjiDetail,
    required this.searchKanji,
    required this.updateKanji,
    required this.kanjiRepository,
  }) : super(KanjiInitial()) {
    on<LoadKanjiListEvent>(_onLoadKanjiList);
    on<LoadMoreKanjiEvent>(_onLoadMoreKanji);
    on<SearchKanjiEvent>(_onSearchKanji);
    on<LoadKanjiDetailEvent>(_onLoadKanjiDetail);
    on<SearchByCanvasEvent>(_onSearchByCanvas);
    on<UpdateKanjiEvent>(_onUpdateKanji);
  }

  Future<void> _onLoadKanjiList(
    LoadKanjiListEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiLoading());

    final result = await getKanjiList(
      jlpt: event.jlpt,
      grade: event.grade,
      search: event.search,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(KanjiError(failure.message)),
      (kanjiList) => emit(
        KanjiListLoaded(
          kanjiList,
          hasMore: event.limit != null && kanjiList.length >= event.limit!,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreKanji(
    LoadMoreKanjiEvent event,
    Emitter<KanjiState> emit,
  ) async {
    final currentState = state;
    if (currentState is! KanjiListLoaded) return;

    // Emit loading more state
    emit(currentState.copyWith(isLoadingMore: true));

    final result = await getKanjiList(
      jlpt: event.jlpt,
      grade: event.grade,
      search: event.search,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) {
        // Revert to previous state on error
        emit(currentState.copyWith(isLoadingMore: false));
        emit(KanjiError(failure.message));
      },
      (newKanjiList) {
        // Append new kanji to existing list
        final updatedList = List<Kanji>.from(currentState.kanjiList)
          ..addAll(newKanjiList);

        emit(
          KanjiListLoaded(
            updatedList,
            hasMore: event.limit != null && newKanjiList.length >= event.limit!,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> _onSearchKanji(
    SearchKanjiEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiLoading());

    final result = await searchKanji(
      query: event.query,
      jlptLevels: event.jlptLevels,
      grades: event.grades,
      minStrokes: event.minStrokes,
      maxStrokes: event.maxStrokes,
      page: event.page,
      limit: event.limit,
      sortBy: event.sortBy,
    );

    result.fold((failure) => emit(KanjiError(failure.message)), (searchResult) {
      // Parse search result
      final kanjiData = searchResult['kanji'] as List;
      final kanjiList = kanjiData
          .map(
            (json) => Kanji(
              id: json['id'],
              character: json['character'],
              meanings: json['meanings'],
              onyomi: json['onyomi'],
              kunyomi: json['kunyomi'],
              jlpt: json['jlpt'],
              grade: json['grade'],
              strokeCount: json['strokeCount'],
              frequency: json['frequency'],
              radical: json['radical'],
              radicalMeaning: json['radicalMeaning'],
              createdAt: DateTime.parse(json['createdAt']),
              updatedAt: DateTime.parse(json['updatedAt']),
            ),
          )
          .toList();

      final total = searchResult['total'] as int;
      final currentPage = searchResult['page'] as int;
      final limit = searchResult['limit'] as int;
      final totalPages = (total / limit).ceil();

      emit(
        KanjiSearchResult(
          kanjiList: kanjiList,
          total: total,
          currentPage: currentPage,
          totalPages: totalPages,
        ),
      );
    });
  }

  Future<void> _onLoadKanjiDetail(
    LoadKanjiDetailEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiLoading());

    final result = await getKanjiDetail(event.character);

    result.fold(
      (failure) => emit(KanjiError(failure.message)),
      (kanjiDetail) => emit(KanjiDetailLoaded(kanjiDetail)),
    );
  }

  Future<void> _onSearchByCanvas(
    SearchByCanvasEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiLoading());

    final result = await kanjiRepository.searchByCanvas(event.imageBase64);

    result.fold(
      (failure) => emit(KanjiError(failure.message)),
      (kanjiList) => emit(KanjiCanvasSearchLoaded(kanjiList)),
    );
  }

  Future<void> _onUpdateKanji(
    UpdateKanjiEvent event,
    Emitter<KanjiState> emit,
  ) async {
    // Don't emit loading state to avoid disrupting current UI
    final result = await updateKanji(
      UpdateKanjiParams(
        id: event.id,
        character: event.character,
        meanings: event.meanings,
        onReadings: event.onReadings,
        kunReadings: event.kunReadings,
        jlptLevel: event.jlptLevel,
        grade: event.grade,
        strokeCount: event.strokeCount,
        frequency: event.frequency,
        tags: event.tags,
      ),
    );

    result.fold((failure) => emit(KanjiError(failure.message)), (updatedKanji) {
      // Emit a success state without disrupting the current kanji detail
      // The UI will handle reloading the detail after success
      emit(KanjiUpdateSuccess());
    });
  }
}
