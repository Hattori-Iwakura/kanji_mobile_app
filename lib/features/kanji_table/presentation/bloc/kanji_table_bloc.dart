import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/kanji_table_usecases.dart';
import 'kanji_table_event.dart';
import 'kanji_table_state.dart';

class KanjiTableBloc extends Bloc<KanjiTableEvent, KanjiTableState> {
  final GetTablesByJlptUseCase getTablesByJlpt;
  final GetAllTablesUseCase getAllTables;
  final GetTableByIdUseCase getTableById;
  final CreateTableUseCase createTable;
  final UpdateTableUseCase updateTable;
  final DeleteTableUseCase deleteTable;
  final AddKanjiToTableUseCase addKanjiToTable;
  final RemoveKanjiFromTableUseCase removeKanjiFromTable;
  final RequestPublishUseCase requestPublish;

  KanjiTableBloc({
    required this.getTablesByJlpt,
    required this.getAllTables,
    required this.getTableById,
    required this.createTable,
    required this.updateTable,
    required this.deleteTable,
    required this.addKanjiToTable,
    required this.removeKanjiFromTable,
    required this.requestPublish,
  }) : super(KanjiTableInitial()) {
    on<LoadTablesByJlptEvent>(_onLoadTablesByJlpt);
    on<LoadAllTablesEvent>(_onLoadAllTables);
    on<LoadTableDetailEvent>(_onLoadTableDetail);
    on<CreateTableEvent>(_onCreateTable);
    on<UpdateTableEvent>(_onUpdateTable);
    on<DeleteTableEvent>(_onDeleteTable);
    on<AddKanjiToTableEvent>(_onAddKanjiToTable);
    on<RemoveKanjiFromTableEvent>(_onRemoveKanjiFromTable);
    on<RequestPublishEvent>(_onRequestPublish);
  }

  Future<void> _onLoadTablesByJlpt(
    LoadTablesByJlptEvent event,
    Emitter<KanjiTableState> emit,
  ) async {
    emit(KanjiTableLoading());
    final result = await getTablesByJlpt(event.jlptLevel);
    result.fold(
      (failure) => emit(KanjiTableError(failure.message)),
      (tables) => emit(KanjiTableListLoaded(tables)),
    );
  }

  Future<void> _onLoadAllTables(
    LoadAllTablesEvent event,
    Emitter<KanjiTableState> emit,
  ) async {
    emit(KanjiTableLoading());
    final result = await getAllTables(
      search: event.search,
      type: event.type,
      limit: event.limit,
      offset: event.offset,
    );
    result.fold(
      (failure) => emit(KanjiTableError(failure.message)),
      (tables) => emit(KanjiTableListLoaded(tables)),
    );
  }

  Future<void> _onLoadTableDetail(
    LoadTableDetailEvent event,
    Emitter<KanjiTableState> emit,
  ) async {
    emit(KanjiTableLoading());
    final result = await getTableById(event.tableId);
    result.fold(
      (failure) => emit(KanjiTableError(failure.message)),
      (table) => emit(KanjiTableDetailLoaded(table)),
    );
  }

  Future<void> _onCreateTable(
    CreateTableEvent event,
    Emitter<KanjiTableState> emit,
  ) async {
    emit(KanjiTableLoading());
    final result = await createTable(
      name: event.name,
      description: event.description,
      categoryId: event.categoryId,
      kanjiIds: event.kanjiIds,
    );
    result.fold(
      (failure) => emit(KanjiTableError(failure.message)),
      (table) =>
          emit(const KanjiTableOperationSuccess('Table created successfully')),
    );
  }

  Future<void> _onUpdateTable(
    UpdateTableEvent event,
    Emitter<KanjiTableState> emit,
  ) async {
    emit(KanjiTableLoading());
    final result = await updateTable(
      id: event.id,
      name: event.name,
      description: event.description,
      isPublic: event.isPublic,
      categoryId: event.categoryId,
    );
    result.fold(
      (failure) => emit(KanjiTableError(failure.message)),
      (table) =>
          emit(const KanjiTableOperationSuccess('Table updated successfully')),
    );
  }

  Future<void> _onDeleteTable(
    DeleteTableEvent event,
    Emitter<KanjiTableState> emit,
  ) async {
    emit(KanjiTableLoading());
    final result = await deleteTable(event.id);
    result.fold(
      (failure) => emit(KanjiTableError(failure.message)),
      (_) =>
          emit(const KanjiTableOperationSuccess('Table deleted successfully')),
    );
  }

  Future<void> _onAddKanjiToTable(
    AddKanjiToTableEvent event,
    Emitter<KanjiTableState> emit,
  ) async {
    emit(KanjiTableLoading());
    final result = await addKanjiToTable(
      tableId: event.tableId,
      kanjiId: event.kanjiId,
    );
    result.fold(
      (failure) => emit(KanjiTableError(failure.message)),
      (_) => emit(const KanjiTableOperationSuccess('Kanji added to table')),
    );
  }

  Future<void> _onRemoveKanjiFromTable(
    RemoveKanjiFromTableEvent event,
    Emitter<KanjiTableState> emit,
  ) async {
    emit(KanjiTableLoading());
    final result = await removeKanjiFromTable(
      tableId: event.tableId,
      kanjiId: event.kanjiId,
    );
    result.fold(
      (failure) => emit(KanjiTableError(failure.message)),
      (table) => emit(KanjiTableDetailLoaded(table)),
    );
  }

  Future<void> _onRequestPublish(
    RequestPublishEvent event,
    Emitter<KanjiTableState> emit,
  ) async {
    emit(KanjiTableLoading());
    final result = await requestPublish(event.tableId);
    result.fold(
      (failure) => emit(KanjiTableError(failure.message)),
      (_) =>
          emit(const KanjiTableOperationSuccess('Publish request submitted')),
    );
  }
}
