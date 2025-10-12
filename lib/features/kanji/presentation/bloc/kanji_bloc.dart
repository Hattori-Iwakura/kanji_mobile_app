import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_all_kanji.dart';
import '../../domain/usecases/get_kanji_by_grade.dart';
import '../../domain/usecases/search_kanji.dart';
import 'kanji_event.dart';
import 'kanji_state.dart';

const String databaseFailureMessage = 'Database Error';

class KanjiBloc extends Bloc<KanjiEvent, KanjiState> {
  final GetAllKanji getAllKanji;
  final GetKanjiByGrade getKanjiByGrade;
  final SearchKanji searchKanji;

  KanjiBloc({
    required this.getAllKanji,
    required this.getKanjiByGrade,
    required this.searchKanji,
  }) : super(KanjiInitial()) {
    on<LoadAllKanjiEvent>(_onLoadAllKanji);
    on<LoadKanjiByGradeEvent>(_onLoadKanjiByGrade);
    on<SearchKanjiEvent>(_onSearchKanji);
  }

  Future<void> _onLoadAllKanji(
    LoadAllKanjiEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiLoading());
    final failureOrKanji = await getAllKanji(NoParams());
    failureOrKanji.fold(
      (failure) => emit(const KanjiError(message: databaseFailureMessage)),
      (kanji) => emit(KanjiLoaded(kanjiList: kanji)),
    );
  }

  Future<void> _onLoadKanjiByGrade(
    LoadKanjiByGradeEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiLoading());
    final failureOrKanji = await getKanjiByGrade(
      GradeParams(grade: event.grade),
    );
    failureOrKanji.fold(
      (failure) => emit(const KanjiError(message: databaseFailureMessage)),
      (kanji) => emit(KanjiLoaded(kanjiList: kanji)),
    );
  }

  Future<void> _onSearchKanji(
    SearchKanjiEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiLoading());
    final failureOrKanji = await searchKanji(SearchParams(query: event.query));
    failureOrKanji.fold(
      (failure) => emit(const KanjiError(message: databaseFailureMessage)),
      (kanji) => emit(KanjiLoaded(kanjiList: kanji)),
    );
  }
}
