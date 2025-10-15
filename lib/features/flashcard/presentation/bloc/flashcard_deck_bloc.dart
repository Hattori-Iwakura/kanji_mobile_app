import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_deck.dart';
import '../../domain/usecases/get_user_decks.dart';
import '../../domain/repositories/flashcard_repository.dart';
import 'flashcard_deck_event.dart';
import 'flashcard_deck_state.dart';

class FlashcardDeckBloc extends Bloc<FlashcardDeckEvent, FlashcardDeckState> {
  final GetUserDecks getUserDecks;
  final CreateDeck createDeck;
  final FlashcardRepository repository;

  FlashcardDeckBloc({
    required this.getUserDecks,
    required this.createDeck,
    required this.repository,
  }) : super(const FlashcardDeckInitial()) {
    on<LoadUserDecksEvent>(_onLoadUserDecks);
    on<CreateDeckEvent>(_onCreateDeck);
    on<DeleteDeckEvent>(_onDeleteDeck);
    on<RefreshDecksEvent>(_onRefreshDecks);
  }

  Future<void> _onLoadUserDecks(
    LoadUserDecksEvent event,
    Emitter<FlashcardDeckState> emit,
  ) async {
    emit(const FlashcardDeckLoading());

    final result = await getUserDecks();

    result.fold(
      (failure) => emit(FlashcardDeckError(failure.message)),
      (decks) => emit(FlashcardDeckLoaded(decks)),
    );
  }

  Future<void> _onCreateDeck(
    CreateDeckEvent event,
    Emitter<FlashcardDeckState> emit,
  ) async {
    emit(const FlashcardDeckLoading());

    final result = await createDeck(
      name: event.name,
      description: event.description,
      sourceType: event.sourceType,
      sourceId: event.sourceId,
      isPublic: event.isPublic,
    );

    result.fold((failure) => emit(FlashcardDeckError(failure.message)), (deck) {
      emit(FlashcardDeckCreated(deck));
      // Auto reload decks after creating
      add(const LoadUserDecksEvent());
    });
  }

  Future<void> _onDeleteDeck(
    DeleteDeckEvent event,
    Emitter<FlashcardDeckState> emit,
  ) async {
    emit(const FlashcardDeckLoading());

    final result = await repository.deleteDeck(event.deckId);

    result.fold((failure) => emit(FlashcardDeckError(failure.message)), (_) {
      emit(const FlashcardDeckDeleted());
      // Auto reload decks after deleting
      add(const LoadUserDecksEvent());
    });
  }

  Future<void> _onRefreshDecks(
    RefreshDecksEvent event,
    Emitter<FlashcardDeckState> emit,
  ) async {
    final result = await getUserDecks();

    result.fold(
      (failure) => emit(FlashcardDeckError(failure.message)),
      (decks) => emit(FlashcardDeckLoaded(decks)),
    );
  }
}
