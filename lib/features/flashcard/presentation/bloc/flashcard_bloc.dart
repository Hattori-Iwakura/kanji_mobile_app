import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/flashcard_exception.dart';
import '../../domain/usecases/add_card_usecase.dart';
import '../../domain/usecases/approve_publish_request_usecase.dart';
import '../../domain/usecases/create_deck_usecase.dart';
import '../../domain/usecases/delete_deck_usecase.dart';
import '../../domain/usecases/get_all_decks_usecase.dart';
import '../../domain/usecases/get_deck_by_id_usecase.dart';
import '../../domain/usecases/get_publish_requests_usecase.dart';
import '../../domain/usecases/reject_publish_request_usecase.dart';
import '../../domain/usecases/remove_card_usecase.dart';
import '../../domain/usecases/request_publish_usecase.dart';
import '../../domain/usecases/update_deck_usecase.dart';
import 'flashcard_event.dart';
import 'flashcard_state.dart';

class FlashcardBloc extends Bloc<FlashcardEvent, FlashcardState> {
  final GetAllDecksUseCase getAllDecksUseCase;
  final GetDeckByIdUseCase getDeckByIdUseCase;
  final CreateDeckUseCase createDeckUseCase;
  final UpdateDeckUseCase updateDeckUseCase;
  final DeleteDeckUseCase deleteDeckUseCase;
  final AddCardUseCase addCardUseCase;
  final RemoveCardUseCase removeCardUseCase;
  final RequestPublishUseCase requestPublishUseCase;
  final GetPublishRequestsUseCase getPublishRequestsUseCase;
  final ApprovePublishRequestUseCase approvePublishRequestUseCase;
  final RejectPublishRequestUseCase rejectPublishRequestUseCase;

  FlashcardBloc({
    required this.getAllDecksUseCase,
    required this.getDeckByIdUseCase,
    required this.createDeckUseCase,
    required this.updateDeckUseCase,
    required this.deleteDeckUseCase,
    required this.addCardUseCase,
    required this.removeCardUseCase,
    required this.requestPublishUseCase,
    required this.getPublishRequestsUseCase,
    required this.approvePublishRequestUseCase,
    required this.rejectPublishRequestUseCase,
  }) : super(FlashcardInitial()) {
    on<LoadAllDecksEvent>(_onLoadAllDecks);
    on<LoadDeckByIdEvent>(_onLoadDeckById);
    on<CreateDeckEvent>(_onCreateDeck);
    on<UpdateDeckEvent>(_onUpdateDeck);
    on<DeleteDeckEvent>(_onDeleteDeck);
    on<AddCardEvent>(_onAddCard);
    on<RemoveCardEvent>(_onRemoveCard);
    on<RequestPublishEvent>(_onRequestPublish);
    on<LoadPublishRequestsEvent>(_onLoadPublishRequests);
    on<ApprovePublishRequestEvent>(_onApprovePublishRequest);
    on<RejectPublishRequestEvent>(_onRejectPublishRequest);
    on<RefreshDecksEvent>(_onRefreshDecks);
  }

  Future<void> _onLoadAllDecks(
    LoadAllDecksEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    try {
      final decks = await getAllDecksUseCase(
        search: event.search,
        limit: event.limit,
        offset: event.offset,
      );
      emit(
        DecksLoaded(
          decks: decks,
          appliedSearch: event.search,
          appliedLimit: event.limit,
          appliedOffset: event.offset,
        ),
      );
    } on FlashcardException catch (e) {
      emit(FlashcardError(e.message));
    } catch (e) {
      emit(FlashcardError('Failed to load decks'));
    }
  }

  Future<void> _onLoadDeckById(
    LoadDeckByIdEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    try {
      final deck = await getDeckByIdUseCase(event.id);
      emit(DeckDetailLoaded(deck));
    } on FlashcardException catch (e) {
      emit(FlashcardError(e.message));
    } catch (e) {
      emit(FlashcardError('Failed to load deck'));
    }
  }

  Future<void> _onCreateDeck(
    CreateDeckEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    try {
      final deck = await createDeckUseCase(
        name: event.name,
        description: event.description,
        kanjiIds: event.kanjiIds,
      );
      emit(DeckCreated(deck));
    } on FlashcardException catch (e) {
      emit(FlashcardError(e.message));
    } catch (e) {
      emit(FlashcardError('Failed to create deck'));
    }
  }

  Future<void> _onUpdateDeck(
    UpdateDeckEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    try {
      final deck = await updateDeckUseCase(
        id: event.id,
        name: event.name,
        description: event.description,
        isPublic: event.isPublic,
      );
      emit(DeckUpdated(deck));
    } on FlashcardException catch (e) {
      emit(FlashcardError(e.message));
    } catch (e) {
      emit(FlashcardError('Failed to update deck'));
    }
  }

  Future<void> _onDeleteDeck(
    DeleteDeckEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    try {
      await deleteDeckUseCase(event.id);
      emit(DeckDeleted());
    } on FlashcardException catch (e) {
      emit(FlashcardError(e.message));
    } catch (e) {
      emit(FlashcardError('Failed to delete deck'));
    }
  }

  Future<void> _onAddCard(
    AddCardEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    try {
      final card = await addCardUseCase(
        deckId: event.deckId,
        kanjiId: event.kanjiId,
      );
      emit(CardAdded(card));
    } on FlashcardException catch (e) {
      emit(FlashcardError(e.message));
    } catch (e) {
      emit(FlashcardError('Failed to add card'));
    }
  }

  Future<void> _onRemoveCard(
    RemoveCardEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    try {
      await removeCardUseCase(deckId: event.deckId, kanjiId: event.kanjiId);
      emit(CardRemoved());
    } on FlashcardException catch (e) {
      emit(FlashcardError(e.message));
    } catch (e) {
      emit(FlashcardError('Failed to remove card'));
    }
  }

  Future<void> _onRequestPublish(
    RequestPublishEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    try {
      await requestPublishUseCase(event.deckId);
      emit(PublishRequested());
    } on FlashcardException catch (e) {
      emit(FlashcardError(e.message));
    } catch (e) {
      emit(FlashcardError('Failed to request publish'));
    }
  }

  Future<void> _onLoadPublishRequests(
    LoadPublishRequestsEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    try {
      final requests = await getPublishRequestsUseCase(status: event.status);
      emit(PublishRequestsLoaded(requests));
    } on FlashcardException catch (e) {
      emit(FlashcardError(e.message));
    } catch (e) {
      emit(FlashcardError('Failed to load publish requests'));
    }
  }

  Future<void> _onApprovePublishRequest(
    ApprovePublishRequestEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    try {
      await approvePublishRequestUseCase(event.requestId);
      emit(PublishRequestApproved());
    } on FlashcardException catch (e) {
      emit(FlashcardError(e.message));
    } catch (e) {
      emit(FlashcardError('Failed to approve publish request'));
    }
  }

  Future<void> _onRejectPublishRequest(
    RejectPublishRequestEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    try {
      await rejectPublishRequestUseCase(event.requestId, event.reason);
      emit(PublishRequestRejected());
    } on FlashcardException catch (e) {
      emit(FlashcardError(e.message));
    } catch (e) {
      emit(FlashcardError('Failed to reject publish request'));
    }
  }

  Future<void> _onRefreshDecks(
    RefreshDecksEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    try {
      final decks = await getAllDecksUseCase();
      emit(DecksLoaded(decks: decks));
    } on FlashcardException catch (e) {
      emit(FlashcardError(e.message));
    } catch (e) {
      emit(FlashcardError('Failed to refresh decks'));
    }
  }
}
