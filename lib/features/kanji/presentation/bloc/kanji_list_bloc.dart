import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/kanji.dart';
import '../../domain/usecases/create_kanji_list.dart';
import '../../domain/usecases/delete_kanji_list.dart';
import '../../domain/usecases/get_all_kanji_lists.dart';
import '../../domain/usecases/get_kanji_by_frequency.dart';
import '../../domain/usecases/get_kanji_by_grade.dart';
import '../../domain/usecases/get_kanji_by_jlpt_level.dart';
import '../../domain/entities/kanji_list.dart';
import 'kanji_list_event.dart';
import 'kanji_list_state.dart';

const String databaseFailureMessage = 'Database Error';

class KanjiListBloc extends Bloc<KanjiListEvent, KanjiListState> {
  final GetAllKanjiLists getAllLists;
  final CreateKanjiList createList;
  final DeleteKanjiList deleteList;
  final GetKanjiByGrade getKanjiByGrade;
  final GetKanjiByJlptLevel getKanjiByJlptLevel;
  final GetKanjiByFrequency getKanjiByFrequency;

  KanjiListBloc({
    required this.getAllLists,
    required this.createList,
    required this.deleteList,
    required this.getKanjiByGrade,
    required this.getKanjiByJlptLevel,
    required this.getKanjiByFrequency,
  }) : super(KanjiListInitial()) {
    on<LoadAllListsEvent>(_onLoadAllLists);
    on<CreateListEvent>(_onCreateList);
    on<DeleteListEvent>(_onDeleteList);
    on<LoadListDetailEvent>(_onLoadListDetail);
  }

  Future<void> _onLoadAllLists(
    LoadAllListsEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    final result = await getAllLists(NoParams());
    result.fold(
      (failure) => emit(const KanjiListError(message: databaseFailureMessage)),
      (lists) => emit(KanjiListsLoaded(lists: lists)),
    );
  }

  Future<void> _onCreateList(
    CreateListEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    final result = await createList(
      CreateListParams(
        name: event.name,
        description: event.description,
        filterType: event.filterType,
        filterValue: event.filterValue,
        frequencyMin: event.frequencyMin,
        frequencyMax: event.frequencyMax,
      ),
    );

    await result.fold(
      (failure) async {
        emit(const KanjiListError(message: databaseFailureMessage));
      },
      (createdList) async {
        // Now populate the list with kanji based on filter type
        final kanjiResult = await _getKanjiByFilter(createdList);
        await kanjiResult.fold(
          (failure) async {
            emit(const KanjiListError(message: databaseFailureMessage));
          },
          (kanji) async {
            emit(KanjiListCreated(list: createdList));
          },
        );
      },
    );
  }

  Future<void> _onDeleteList(
    DeleteListEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    final result = await deleteList(DeleteListParams(listId: event.listId));
    result.fold(
      (failure) => emit(const KanjiListError(message: databaseFailureMessage)),
      (_) {
        // Reload lists after deletion
        add(LoadAllListsEvent());
      },
    );
  }

  Future<void> _onLoadListDetail(
    LoadListDetailEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    // This would load the list and its kanji items
    // For now, just emit an error as we need to implement this fully
    emit(const KanjiListError(message: 'Not implemented yet'));
  }

  Future<dynamic> _getKanjiByFilter(KanjiList list) async {
    switch (list.filterType) {
      case ListFilterType.grade:
        if (list.filterValue != null) {
          return await getKanjiByGrade(GradeParams(grade: list.filterValue!));
        }
        break;
      case ListFilterType.jlptLevel:
        if (list.filterValue != null) {
          return await getKanjiByJlptLevel(
            JlptLevelParams(level: list.filterValue!),
          );
        }
        break;
      case ListFilterType.frequency:
        if (list.frequencyMin != null && list.frequencyMax != null) {
          return await getKanjiByFrequency(
            FrequencyParams(
              minFreq: list.frequencyMin!,
              maxFreq: list.frequencyMax!,
            ),
          );
        }
        break;
      case ListFilterType.custom:
        // Custom lists don't auto-populate
        break;
    }
    return Future.value(const <Kanji>[]);
  }
}
