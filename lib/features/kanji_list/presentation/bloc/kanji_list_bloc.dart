import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_kanji_lists.dart';
import '../../domain/usecases/get_kanji_list_by_id.dart';
import '../../domain/usecases/create_kanji_list.dart';
import '../../domain/usecases/update_kanji_list.dart';
import '../../domain/usecases/delete_kanji_list.dart';
import '../../domain/usecases/add_kanji_to_list.dart';
import '../../domain/usecases/remove_kanji_from_list.dart';
import '../../domain/usecases/get_kanji_lists_by_jlpt.dart';
import 'kanji_list_event.dart';
import 'kanji_list_state.dart';

/// BLoC for managing kanji list operations
class KanjiListBloc extends Bloc<KanjiListEvent, KanjiListState> {
  final GetAllKanjiLists getAllKanjiLists;
  final GetKanjiListById getKanjiListById;
  final CreateKanjiList createKanjiList;
  final UpdateKanjiList updateKanjiList;
  final DeleteKanjiList deleteKanjiList;
  final AddKanjiToList addKanjiToList;
  final RemoveKanjiFromList removeKanjiFromList;
  final GetKanjiListsByJlpt getKanjiListsByJlpt;

  KanjiListBloc({
    required this.getAllKanjiLists,
    required this.getKanjiListById,
    required this.createKanjiList,
    required this.updateKanjiList,
    required this.deleteKanjiList,
    required this.addKanjiToList,
    required this.removeKanjiFromList,
    required this.getKanjiListsByJlpt,
  }) : super(KanjiListInitial()) {
    on<LoadKanjiListsEvent>(_onLoadKanjiLists);
    on<LoadKanjiListByIdEvent>(_onLoadKanjiListById);
    on<CreateKanjiListEvent>(_onCreateKanjiList);
    on<UpdateKanjiListEvent>(_onUpdateKanjiList);
    on<DeleteKanjiListEvent>(_onDeleteKanjiList);
    on<AddKanjiToListEvent>(_onAddKanjiToList);
    on<RemoveKanjiFromListEvent>(_onRemoveKanjiFromList);
    on<FilterByJlptEvent>(_onFilterByJlpt);
  }

  Future<void> _onLoadKanjiLists(
    LoadKanjiListsEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    final result = await getAllKanjiLists(
      search: event.search,
      limit: event.limit,
      offset: event.offset,
    );
    result.fold(
      (failure) => emit(KanjiListError(failure.message)),
      (lists) => emit(KanjiListsLoaded(lists)),
    );
  }

  Future<void> _onLoadKanjiListById(
    LoadKanjiListByIdEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    final result = await getKanjiListById(event.id);
    result.fold(
      (failure) => emit(KanjiListError(failure.message)),
      (list) => emit(KanjiListLoaded(list)),
    );
  }

  Future<void> _onCreateKanjiList(
    CreateKanjiListEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    final result = await createKanjiList(
      name: event.name,
      description: event.description,
      kanjiIds: event.kanjiIds,
    );
    result.fold(
      (failure) => emit(KanjiListError(failure.message)),
      (list) => emit(KanjiListCreated(list)),
    );
  }

  Future<void> _onUpdateKanjiList(
    UpdateKanjiListEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    final result = await updateKanjiList(
      id: event.id,
      name: event.name,
      description: event.description,
      isPublic: event.isPublic,
    );
    result.fold(
      (failure) => emit(KanjiListError(failure.message)),
      (list) => emit(KanjiListUpdated(list)),
    );
  }

  Future<void> _onDeleteKanjiList(
    DeleteKanjiListEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    final result = await deleteKanjiList(event.id);
    result.fold(
      (failure) => emit(KanjiListError(failure.message)),
      (_) => emit(KanjiListDeleted(event.id)),
    );
  }

  Future<void> _onAddKanjiToList(
    AddKanjiToListEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    final result = await addKanjiToList(
      listId: event.listId,
      kanjiId: event.kanjiId,
    );
    result.fold(
      (failure) => emit(KanjiListError(failure.message)),
      (list) => emit(KanjiAddedToList(list)),
    );
  }

  Future<void> _onRemoveKanjiFromList(
    RemoveKanjiFromListEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    final result = await removeKanjiFromList(
      listId: event.listId,
      kanjiId: event.kanjiId,
    );
    result.fold(
      (failure) => emit(KanjiListError(failure.message)),
      (list) => emit(KanjiRemovedFromList(list)),
    );
  }

  Future<void> _onFilterByJlpt(
    FilterByJlptEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    final result = await getKanjiListsByJlpt(jlptLevel: event.jlptLevel);
    result.fold(
      (failure) => emit(KanjiListError(failure.message)),
      (lists) => emit(KanjiListsLoaded(lists)),
    );
  }
}
