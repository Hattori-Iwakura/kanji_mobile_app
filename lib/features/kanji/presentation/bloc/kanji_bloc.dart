import 'package:flutter_bloc/flutter_bloc.dart';
import 'kanji_event.dart';
import 'kanji_state.dart';
import '../../domain/usecases/get_all_kanji.dart';
import '../../domain/usecases/get_kanji_by_id.dart';
import '../../domain/usecases/get_kanji_by_character.dart';
import '../../domain/usecases/create_kanji.dart';
import '../../domain/usecases/update_kanji.dart';
import '../../domain/usecases/delete_kanji.dart';

class KanjiBloc extends Bloc<KanjiEvent, KanjiState> {
  final GetAllKanji getAllKanjiUseCase;
  final GetKanjiById getKanjiByIdUseCase;
  final GetKanjiByCharacter getKanjiByCharacterUseCase;
  final CreateKanji createKanjiUseCase;
  final UpdateKanji updateKanjiUseCase;
  final DeleteKanji deleteKanjiUseCase;

  KanjiBloc({
    required this.getAllKanjiUseCase,
    required this.getKanjiByIdUseCase,
    required this.getKanjiByCharacterUseCase,
    required this.createKanjiUseCase,
    required this.updateKanjiUseCase,
    required this.deleteKanjiUseCase,
  }) : super(const KanjiInitial()) {
    on<LoadAllKanjiEvent>(_onLoadAllKanji);
    on<LoadKanjiByIdEvent>(_onLoadKanjiById);
    on<LoadKanjiByCharacterEvent>(_onLoadKanjiByCharacter);
    on<FilterKanjiByJlptEvent>(_onFilterByJlpt);
    on<FilterKanjiByGradeEvent>(_onFilterByGrade);
    on<SearchKanjiEvent>(_onSearchKanji);
    on<CreateKanjiEvent>(_onCreateKanji);
    on<UpdateKanjiEvent>(_onUpdateKanji);
    on<DeleteKanjiEvent>(_onDeleteKanji);
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

  Future<void> _onCreateKanji(
    CreateKanjiEvent event,
    Emitter<KanjiState> emit,
  ) async {
    // Store previous state to update list optimistically
    final previousState = state;

    // Only show loading if we don't have data yet
    if (previousState is! KanjiListLoaded) {
      emit(const KanjiLoading());
    }

    final result = await createKanjiUseCase(event.params);

    await result.fold(
      (failure) async {
        emit(KanjiError(failure.message));
      },
      (kanji) async {
        // If we have existing list, add new kanji to it instead of reloading
        if (previousState is KanjiListLoaded) {
          final updatedList = [kanji, ...previousState.kanjiList];
          emit(
            KanjiListLoaded(
              kanjiList: updatedList,
              filteredList: updatedList,
              successMessage: 'Kanji created successfully',
            ),
          );
        } else {
          emit(
            KanjiOperationSuccess('Kanji created successfully', kanji: kanji),
          );
        }
      },
    );
  }

  Future<void> _onUpdateKanji(
    UpdateKanjiEvent event,
    Emitter<KanjiState> emit,
  ) async {
    // Store previous state to update list optimistically
    final previousState = state;

    // Only show loading if we don't have data yet
    if (previousState is! KanjiListLoaded) {
      emit(const KanjiLoading());
    }

    final result = await updateKanjiUseCase(event.params);

    await result.fold(
      (failure) async {
        emit(KanjiError(failure.message));
      },
      (updatedKanji) async {
        // If we have existing list, update the kanji in place
        if (previousState is KanjiListLoaded) {
          final updatedList = previousState.kanjiList.map((kanji) {
            return kanji.id == updatedKanji.id ? updatedKanji : kanji;
          }).toList();

          final updatedFilteredList = previousState.filteredList.map((kanji) {
            return kanji.id == updatedKanji.id ? updatedKanji : kanji;
          }).toList();

          emit(
            KanjiListLoaded(
              kanjiList: updatedList,
              filteredList: updatedFilteredList,
              filterType: previousState.filterType,
              successMessage: 'Kanji updated successfully',
            ),
          );
        } else {
          emit(
            KanjiOperationSuccess(
              'Kanji updated successfully',
              kanji: updatedKanji,
            ),
          );
        }
      },
    );
  }

  Future<void> _onDeleteKanji(
    DeleteKanjiEvent event,
    Emitter<KanjiState> emit,
  ) async {
    // Store previous state to update list optimistically
    final previousState = state;

    // Only show loading if we don't have data yet
    if (previousState is! KanjiListLoaded) {
      emit(const KanjiLoading());
    }

    final result = await deleteKanjiUseCase(event.id);

    await result.fold(
      (failure) async {
        emit(KanjiError(failure.message));
      },
      (deletedKanji) async {
        // If we have existing list, remove the deleted kanji
        if (previousState is KanjiListLoaded) {
          final updatedList = previousState.kanjiList
              .where((kanji) => kanji.id != event.id)
              .toList();

          final updatedFilteredList = previousState.filteredList
              .where((kanji) => kanji.id != event.id)
              .toList();

          emit(
            KanjiListLoaded(
              kanjiList: updatedList,
              filteredList: updatedFilteredList,
              filterType: previousState.filterType,
              successMessage: 'Kanji deleted successfully',
            ),
          );
        } else {
          emit(
            KanjiOperationSuccess(
              'Kanji deleted successfully',
              kanji: deletedKanji,
            ),
          );
        }
      },
    );
  }
}
