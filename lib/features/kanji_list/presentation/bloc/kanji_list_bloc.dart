import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/kanji_list_exception.dart';
import '../../domain/usecases/add_kanji_to_list_usecase.dart';
import '../../domain/usecases/approve_publish_request_usecase.dart';
import '../../domain/usecases/create_list_usecase.dart';
import '../../domain/usecases/delete_list_usecase.dart';
import '../../domain/usecases/get_all_lists_usecase.dart';
import '../../domain/usecases/get_list_by_id_usecase.dart';
import '../../domain/usecases/get_publish_requests_usecase.dart';
import '../../domain/usecases/reject_publish_request_usecase.dart';
import '../../domain/usecases/remove_kanji_from_list_usecase.dart';
import '../../domain/usecases/request_publish_list_usecase.dart';
import '../../domain/usecases/update_list_usecase.dart';
import 'kanji_list_event.dart';
import 'kanji_list_state.dart';

class KanjiListBloc extends Bloc<KanjiListEvent, KanjiListState> {
  final GetAllListsUseCase getAllListsUseCase;
  final GetListByIdUseCase getListByIdUseCase;
  final CreateListUseCase createListUseCase;
  final UpdateListUseCase updateListUseCase;
  final DeleteListUseCase deleteListUseCase;
  final AddKanjiToListUseCase addKanjiToListUseCase;
  final RemoveKanjiFromListUseCase removeKanjiFromListUseCase;
  final RequestPublishListUseCase requestPublishListUseCase;
  final GetPublishRequestsUseCase getPublishRequestsUseCase;
  final ApprovePublishRequestUseCase approvePublishRequestUseCase;
  final RejectPublishRequestUseCase rejectPublishRequestUseCase;

  KanjiListBloc({
    required this.getAllListsUseCase,
    required this.getListByIdUseCase,
    required this.createListUseCase,
    required this.updateListUseCase,
    required this.deleteListUseCase,
    required this.addKanjiToListUseCase,
    required this.removeKanjiFromListUseCase,
    required this.requestPublishListUseCase,
    required this.getPublishRequestsUseCase,
    required this.approvePublishRequestUseCase,
    required this.rejectPublishRequestUseCase,
  }) : super(KanjiListInitial()) {
    on<LoadAllListsEvent>(_onLoadAllLists);
    on<LoadListByIdEvent>(_onLoadListById);
    on<CreateListEvent>(_onCreateList);
    on<UpdateListEvent>(_onUpdateList);
    on<DeleteListEvent>(_onDeleteList);
    on<AddKanjiToListEvent>(_onAddKanjiToList);
    on<RemoveKanjiFromListEvent>(_onRemoveKanjiFromList);
    on<RequestPublishListEvent>(_onRequestPublishList);
    on<LoadPublishRequestsEvent>(_onLoadPublishRequests);
    on<ApprovePublishRequestEvent>(_onApprovePublishRequest);
    on<RejectPublishRequestEvent>(_onRejectPublishRequest);
    on<RefreshListsEvent>(_onRefreshLists);
  }

  Future<void> _onLoadAllLists(
    LoadAllListsEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    try {
      final lists = await getAllListsUseCase(
        search: event.search,
        type: event.type,
        limit: event.limit,
        offset: event.offset,
      );
      emit(
        ListsLoaded(
          lists: lists,
          appliedSearch: event.search,
          appliedType: event.type,
          appliedLimit: event.limit,
          appliedOffset: event.offset,
        ),
      );
    } on KanjiListException catch (e) {
      emit(KanjiListError(e.message));
    } catch (e) {
      emit(KanjiListError('Failed to load lists'));
    }
  }

  Future<void> _onLoadListById(
    LoadListByIdEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    try {
      final list = await getListByIdUseCase(event.id);
      emit(ListDetailLoaded(list));
    } on KanjiListException catch (e) {
      emit(KanjiListError(e.message));
    } catch (e) {
      emit(KanjiListError('Failed to load list'));
    }
  }

  Future<void> _onCreateList(
    CreateListEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    try {
      final list = await createListUseCase(
        name: event.name,
        description: event.description,
        kanjiIds: event.kanjiIds,
      );
      emit(ListCreated(list));
    } on KanjiListException catch (e) {
      emit(KanjiListError(e.message));
    } catch (e) {
      emit(KanjiListError('Failed to create list'));
    }
  }

  Future<void> _onUpdateList(
    UpdateListEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    try {
      final list = await updateListUseCase(
        id: event.id,
        name: event.name,
        description: event.description,
        isPublic: event.isPublic,
      );
      emit(ListUpdated(list));
    } on KanjiListException catch (e) {
      emit(KanjiListError(e.message));
    } catch (e) {
      emit(KanjiListError('Failed to update list'));
    }
  }

  Future<void> _onDeleteList(
    DeleteListEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    try {
      await deleteListUseCase(event.id);
      emit(ListDeleted());
    } on KanjiListException catch (e) {
      emit(KanjiListError(e.message));
    } catch (e) {
      emit(KanjiListError('Failed to delete list'));
    }
  }

  Future<void> _onAddKanjiToList(
    AddKanjiToListEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    try {
      await addKanjiToListUseCase(listId: event.listId, kanjiId: event.kanjiId);
      emit(KanjiAddedToList());
    } on KanjiListException catch (e) {
      emit(KanjiListError(e.message));
    } catch (e) {
      emit(KanjiListError('Failed to add kanji to list'));
    }
  }

  Future<void> _onRemoveKanjiFromList(
    RemoveKanjiFromListEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    try {
      await removeKanjiFromListUseCase(
        listId: event.listId,
        kanjiId: event.kanjiId,
      );
      emit(KanjiRemovedFromList());
    } on KanjiListException catch (e) {
      emit(KanjiListError(e.message));
    } catch (e) {
      emit(KanjiListError('Failed to remove kanji from list'));
    }
  }

  Future<void> _onRequestPublishList(
    RequestPublishListEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    try {
      await requestPublishListUseCase(event.listId);
      emit(PublishRequested());
    } on KanjiListException catch (e) {
      emit(KanjiListError(e.message));
    } catch (e) {
      emit(KanjiListError('Failed to request publish'));
    }
  }

  Future<void> _onLoadPublishRequests(
    LoadPublishRequestsEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    try {
      final requests = await getPublishRequestsUseCase(status: event.status);
      emit(PublishRequestsLoaded(requests));
    } on KanjiListException catch (e) {
      emit(KanjiListError(e.message));
    } catch (e) {
      emit(KanjiListError('Failed to load publish requests'));
    }
  }

  Future<void> _onApprovePublishRequest(
    ApprovePublishRequestEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    try {
      await approvePublishRequestUseCase(event.requestId);
      emit(PublishRequestApproved());
    } on KanjiListException catch (e) {
      emit(KanjiListError(e.message));
    } catch (e) {
      emit(KanjiListError('Failed to approve publish request'));
    }
  }

  Future<void> _onRejectPublishRequest(
    RejectPublishRequestEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    try {
      await rejectPublishRequestUseCase(event.requestId, event.reason);
      emit(PublishRequestRejected());
    } on KanjiListException catch (e) {
      emit(KanjiListError(e.message));
    } catch (e) {
      emit(KanjiListError('Failed to reject publish request'));
    }
  }

  Future<void> _onRefreshLists(
    RefreshListsEvent event,
    Emitter<KanjiListState> emit,
  ) async {
    emit(KanjiListLoading());
    try {
      final lists = await getAllListsUseCase();
      emit(ListsLoaded(lists: lists));
    } on KanjiListException catch (e) {
      emit(KanjiListError(e.message));
    } catch (e) {
      emit(KanjiListError('Failed to refresh lists'));
    }
  }
}
