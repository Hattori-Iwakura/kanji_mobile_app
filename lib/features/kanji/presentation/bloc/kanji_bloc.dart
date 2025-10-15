import 'package:flutter_bloc/flutter_bloc.dart';
import 'kanji_event.dart';
import 'kanji_state.dart';
import '../../domain/usecases/get_all_kanji.dart';
import '../../domain/usecases/get_kanji_by_id.dart';
import '../../domain/usecases/get_kanji_by_character.dart';

class KanjiBloc extends Bloc<KanjiEvent, KanjiState> {
  final GetAllKanji getAllKanjiUseCase;
  final GetKanjiById getKanjiByIdUseCase;
  final GetKanjiByCharacter getKanjiByCharacterUseCase;

  KanjiBloc({
    required this.getAllKanjiUseCase,
    required this.getKanjiByIdUseCase,
    required this.getKanjiByCharacterUseCase,
  }) : super(const KanjiInitial()) {
    on<LoadAllKanjiEvent>(_onLoadAllKanji);
    on<LoadKanjiByIdEvent>(_onLoadKanjiById);
    on<LoadKanjiByCharacterEvent>(_onLoadKanjiByCharacter);
    on<FilterKanjiByJlptEvent>(_onFilterByJlpt);
    on<FilterKanjiByGradeEvent>(_onFilterByGrade);
    on<SearchKanjiEvent>(_onSearchKanji);
  }

  Future<void> _onLoadAllKanji(
    LoadAllKanjiEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(const KanjiLoading());

    final result = await getAllKanjiUseCase.call();

    await result.fold(
      (failure) async {
        emit(KanjiError(failure.message));
      },
      (kanjiList) async {
        emit(KanjiListLoaded(kanjiList: kanjiList, filteredList: kanjiList));
      },
    );
  }

  Future<void> _onLoadKanjiById(
    LoadKanjiByIdEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(const KanjiLoading());

    final result = await getKanjiByIdUseCase.call(event.id);

    await result.fold(
      (failure) async {
        emit(KanjiError(failure.message));
      },
      (kanji) async {
        emit(KanjiDetailLoaded(kanji));
      },
    );
  }

  Future<void> _onLoadKanjiByCharacter(
    LoadKanjiByCharacterEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(const KanjiLoading());

    final result = await getKanjiByCharacterUseCase.call(event.character);

    await result.fold(
      (failure) async {
        emit(KanjiError(failure.message));
      },
      (kanji) async {
        emit(KanjiDetailLoaded(kanji));
      },
    );
  }

  Future<void> _onFilterByJlpt(
    FilterKanjiByJlptEvent event,
    Emitter<KanjiState> emit,
  ) async {
    if (state is KanjiListLoaded) {
      final currentState = state as KanjiListLoaded;
      final filtered = currentState.kanjiList
          .where((k) => k.jlpt == event.level)
          .toList();

      emit(
        currentState.copyWith(
          filteredList: filtered,
          filterType: 'jlpt_${event.level}',
        ),
      );
    }
  }

  Future<void> _onFilterByGrade(
    FilterKanjiByGradeEvent event,
    Emitter<KanjiState> emit,
  ) async {
    if (state is KanjiListLoaded) {
      final currentState = state as KanjiListLoaded;
      final filtered = currentState.kanjiList
          .where((k) => k.grade == event.grade)
          .toList();

      emit(
        currentState.copyWith(
          filteredList: filtered,
          filterType: 'grade_${event.grade}',
        ),
      );
    }
  }

  Future<void> _onSearchKanji(
    SearchKanjiEvent event,
    Emitter<KanjiState> emit,
  ) async {
    if (state is KanjiListLoaded) {
      final currentState = state as KanjiListLoaded;

      if (event.query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredList: currentState.kanjiList,
            filterType: null,
          ),
        );
        return;
      }

      final query = event.query.toLowerCase();
      final filtered = currentState.kanjiList.where((k) {
        return k.character.contains(event.query) ||
            k.meanings.toLowerCase().contains(query) ||
            (k.onyomi?.toLowerCase().contains(query) ?? false) ||
            (k.kunyomi?.toLowerCase().contains(query) ?? false);
      }).toList();

      emit(currentState.copyWith(filteredList: filtered, filterType: 'search'));
    }
  }
}
