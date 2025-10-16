import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/kanji_list_usecases.dart';
import 'kanji_lists_event.dart';
import 'kanji_lists_state.dart';

class KanjiListsBloc extends Bloc<KanjiListsEvent, KanjiListsState> {
  final CreateKanjiListUseCase createKanjiList;
  final GetUserListsUseCase getUserLists;
  final GetListDetailUseCase getListDetail;
  final AddKanjiToListUseCase addKanjiToList;
  final RemoveKanjiFromListUseCase removeKanjiFromList;
  final DeleteKanjiListUseCase deleteKanjiList;
  final ReorderKanjiListUseCase reorderKanjiList;

  KanjiListsBloc({
    required this.createKanjiList,
    required this.getUserLists,
    required this.getListDetail,
    required this.addKanjiToList,
    required this.removeKanjiFromList,
    required this.deleteKanjiList,
    required this.reorderKanjiList,
  }) : super(const ListsInitial()) {
    on<LoadUserLists>(_onLoadUserLists);
    on<CreateList>(_onCreateList);
    on<LoadListDetail>(_onLoadListDetail);
    on<AddKanjiToListEvent>(_onAddKanjiToList);
    on<RemoveKanjiFromListEvent>(_onRemoveKanjiFromList);
    on<DeleteListEvent>(_onDeleteList);
    on<ReorderListEvent>(_onReorderList);
  }

  Future<void> _onLoadUserLists(
    LoadUserLists event,
    Emitter<KanjiListsState> emit,
  ) async {
    emit(const ListsLoading());

    final result = await getUserLists();

    result.fold(
      (failure) => emit(ListsError(failure.message)),
      (lists) => emit(ListsLoaded(lists)),
    );
  }

  Future<void> _onCreateList(
    CreateList event,
    Emitter<KanjiListsState> emit,
  ) async {
    final result = await createKanjiList(
      CreateKanjiListParams(name: event.name, description: event.description),
    );

    result.fold((failure) => emit(ListsError(failure.message)), (list) {
      emit(ListOperationSuccess('List created successfully'));
      // Reload lists
      add(const LoadUserLists());
    });
  }

  Future<void> _onLoadListDetail(
    LoadListDetail event,
    Emitter<KanjiListsState> emit,
  ) async {
    emit(const ListsLoading());

    // Parse listId as int
    final listId = int.tryParse(event.listId);
    if (listId == null) {
      emit(const ListsError('Invalid list ID'));
      return;
    }

    final result = await getListDetail(listId);

    result.fold(
      (failure) => emit(ListsError(failure.message)),
      (list) => emit(ListDetailLoaded(list)),
    );
  }

  Future<void> _onAddKanjiToList(
    AddKanjiToListEvent event,
    Emitter<KanjiListsState> emit,
  ) async {
    // Parse listId as int
    final listId = int.tryParse(event.listId);
    if (listId == null) {
      emit(const ListsError('Invalid list ID'));
      return;
    }

    final result = await addKanjiToList(
      AddKanjiToListParams(listId: listId, kanjiCharacters: event.characters),
    );

    result.fold((failure) => emit(ListsError(failure.message)), (_) {
      emit(const ListOperationSuccess('Kanji added to list'));
      // Reload list detail
      add(LoadListDetail(event.listId));
    });
  }

  Future<void> _onRemoveKanjiFromList(
    RemoveKanjiFromListEvent event,
    Emitter<KanjiListsState> emit,
  ) async {
    // Parse IDs as int
    final listId = int.tryParse(event.listId);
    final kanjiId = int.tryParse(event.kanjiId);

    if (listId == null || kanjiId == null) {
      emit(const ListsError('Invalid ID'));
      return;
    }

    final result = await removeKanjiFromList(
      RemoveKanjiFromListParams(listId: listId, kanjiId: kanjiId),
    );

    result.fold((failure) => emit(ListsError(failure.message)), (_) {
      emit(const ListOperationSuccess('Kanji removed from list'));
      // Reload list detail
      add(LoadListDetail(event.listId));
    });
  }

  Future<void> _onDeleteList(
    DeleteListEvent event,
    Emitter<KanjiListsState> emit,
  ) async {
    // Parse listId as int
    final listId = int.tryParse(event.listId);
    if (listId == null) {
      emit(const ListsError('Invalid list ID'));
      return;
    }

    final result = await deleteKanjiList(listId);

    result.fold((failure) => emit(ListsError(failure.message)), (_) {
      emit(const ListOperationSuccess('List deleted successfully'));
      // Reload lists
      add(const LoadUserLists());
    });
  }

  Future<void> _onReorderList(
    ReorderListEvent event,
    Emitter<KanjiListsState> emit,
  ) async {
    // Parse listId and kanjiIds as int
    final listId = int.tryParse(event.listId);
    final kanjiIds = event.kanjiIds
        .map((id) => int.tryParse(id))
        .where((id) => id != null)
        .cast<int>()
        .toList();

    if (listId == null || kanjiIds.length != event.kanjiIds.length) {
      emit(const ListsError('Invalid ID'));
      return;
    }

    final result = await reorderKanjiList(
      ReorderKanjiListParams(listId: listId, kanjiIds: kanjiIds),
    );

    result.fold((failure) => emit(ListsError(failure.message)), (_) {
      emit(const ListOperationSuccess('List reordered successfully'));
      // Reload list detail
      add(LoadListDetail(event.listId));
    });
  }
}
