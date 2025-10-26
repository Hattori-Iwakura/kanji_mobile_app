import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_kanji.dart';
import '../../domain/usecases/get_kanji_by_id.dart';
import '../../domain/usecases/search_kanji.dart';
import '../../domain/usecases/recognize_kanji.dart';
import 'kanji_event.dart';
import 'kanji_state.dart';

/// BLoC for managing Kanji state
class KanjiBloc extends Bloc<KanjiEvent, KanjiState> {
  final GetAllKanji getAllKanji;
  final GetKanjiById getKanjiById;
  final SearchKanji searchKanji;
  final RecognizeKanji recognizeKanji;

  KanjiBloc({
    required this.getAllKanji,
    required this.getKanjiById,
    required this.searchKanji,
    required this.recognizeKanji,
  }) : super(KanjiInitial()) {
    on<LoadAllKanjiEvent>(_onLoadAllKanji);
    on<LoadKanjiByIdEvent>(_onLoadKanjiById);
    on<SearchKanjiEvent>(_onSearchKanji);
    on<RecognizeKanjiEvent>(_onRecognizeKanji);
  }

  Future<void> _onLoadAllKanji(
    LoadAllKanjiEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiLoading());

    final result = await getAllKanji(
      jlpt: event.jlpt,
      grade: event.grade,
      search: event.search,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(KanjiError(failure.message)),
      (kanjiList) => emit(KanjiListLoaded(kanjiList)),
    );
  }

  Future<void> _onLoadKanjiById(
    LoadKanjiByIdEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiLoading());

    final result = await getKanjiById(event.id);

    result.fold(
      (failure) => emit(KanjiError(failure.message)),
      (kanji) => emit(KanjiDetailLoaded(kanji)),
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

    result.fold(
      (failure) => emit(KanjiError(failure.message)),
      (results) => emit(
        KanjiSearchLoaded(
          results: results,
          page: event.page,
          hasMore: results.length >= event.limit,
        ),
      ),
    );
  }

  Future<void> _onRecognizeKanji(
    RecognizeKanjiEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiRecognitionInProgress());

    final result = await recognizeKanji(event.base64Image);

    result.fold(
      (failure) => emit(KanjiRecognitionFailure(failure.message)),
      (recognitionResult) => emit(KanjiRecognitionSuccess(recognitionResult)),
    );
  }
}
