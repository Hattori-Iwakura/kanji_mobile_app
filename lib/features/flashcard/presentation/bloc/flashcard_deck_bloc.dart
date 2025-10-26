import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_flashcard_decks.dart';
import '../../domain/usecases/get_flashcard_deck_by_id.dart';
import '../../domain/usecases/create_flashcard_deck.dart';
import '../../domain/usecases/update_flashcard_deck.dart';
import '../../domain/usecases/delete_flashcard_deck.dart';
import '../../domain/usecases/add_card_to_flashcard_deck.dart';
import '../../domain/usecases/remove_card_from_flashcard_deck.dart';
import 'flashcard_deck_event.dart';
import 'flashcard_deck_state.dart';

/// BLoC for managing Flashcard Deck state
class FlashcardDeckBloc extends Bloc<FlashcardDeckEvent, FlashcardDeckState> {
  final GetAllFlashcardDecks getAllDecks;
  final GetFlashcardDeckById getDeckById;
  final CreateFlashcardDeck createDeck;
  final UpdateFlashcardDeck updateDeck;
  final DeleteFlashcardDeck deleteDeck;
  final AddCardToFlashcardDeck addCardToDeck;
  final RemoveCardFromFlashcardDeck removeCardFromDeck;

  FlashcardDeckBloc({
    required this.getAllDecks,
    required this.getDeckById,
    required this.createDeck,
    required this.updateDeck,
    required this.deleteDeck,
    required this.addCardToDeck,
    required this.removeCardFromDeck,
  }) : super(FlashcardDeckInitial()) {
    on<LoadFlashcardDecksEvent>(_onLoadDecks);
    on<LoadFlashcardDeckByIdEvent>(_onLoadDeckById);
    on<CreateFlashcardDeckEvent>(_onCreateDeck);
    on<UpdateFlashcardDeckEvent>(_onUpdateDeck);
    on<DeleteFlashcardDeckEvent>(_onDeleteDeck);
    on<AddCardToDeckEvent>(_onAddCard);
    on<RemoveCardFromDeckEvent>(_onRemoveCard);
  }

  Future<void> _onLoadDecks(
    LoadFlashcardDecksEvent event,
    Emitter<FlashcardDeckState> emit,
  ) async {
    emit(FlashcardDeckLoading());

    final result = await getAllDecks(
      search: event.search,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(FlashcardDeckError(failure.message)),
      (decks) => emit(FlashcardDecksLoaded(decks)),
    );
  }

  Future<void> _onLoadDeckById(
    LoadFlashcardDeckByIdEvent event,
    Emitter<FlashcardDeckState> emit,
  ) async {
    emit(FlashcardDeckLoading());

    final result = await getDeckById(event.id);

    result.fold(
      (failure) => emit(FlashcardDeckError(failure.message)),
      (deck) => emit(FlashcardDeckLoaded(deck)),
    );
  }

  Future<void> _onCreateDeck(
    CreateFlashcardDeckEvent event,
    Emitter<FlashcardDeckState> emit,
  ) async {
    emit(FlashcardDeckLoading());

    final result = await createDeck(
      name: event.name,
      description: event.description,
      kanjiIds: event.kanjiIds,
    );

    result.fold(
      (failure) => emit(FlashcardDeckError(failure.message)),
      (deck) => emit(FlashcardDeckCreated(deck)),
    );
  }

  Future<void> _onUpdateDeck(
    UpdateFlashcardDeckEvent event,
    Emitter<FlashcardDeckState> emit,
  ) async {
    emit(FlashcardDeckLoading());

    final result = await updateDeck(
      id: event.id,
      name: event.name,
      description: event.description,
      isPublic: event.isPublic,
    );

    result.fold(
      (failure) => emit(FlashcardDeckError(failure.message)),
      (deck) => emit(FlashcardDeckUpdated(deck)),
    );
  }

  Future<void> _onDeleteDeck(
    DeleteFlashcardDeckEvent event,
    Emitter<FlashcardDeckState> emit,
  ) async {
    emit(FlashcardDeckLoading());

    final result = await deleteDeck(event.id);

    result.fold(
      (failure) => emit(FlashcardDeckError(failure.message)),
      (_) => emit(FlashcardDeckDeleted(event.id)),
    );
  }

  Future<void> _onAddCard(
    AddCardToDeckEvent event,
    Emitter<FlashcardDeckState> emit,
  ) async {
    emit(FlashcardDeckLoading());

    final result = await addCardToDeck(event.deckId, event.kanjiId);

    result.fold(
      (failure) => emit(FlashcardDeckError(failure.message)),
      (deck) => emit(CardAddedToDeck(deck)),
    );
  }

  Future<void> _onRemoveCard(
    RemoveCardFromDeckEvent event,
    Emitter<FlashcardDeckState> emit,
  ) async {
    emit(FlashcardDeckLoading());

    final result = await removeCardFromDeck(event.deckId, event.kanjiId);

    result.fold(
      (failure) => emit(FlashcardDeckError(failure.message)),
      (deck) => emit(CardRemovedFromDeck(deck)),
    );
  }
}
