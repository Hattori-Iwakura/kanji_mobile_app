import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/flashcard_usecases.dart';
import 'flashcard_event.dart';
import 'flashcard_state.dart';

class FlashcardBloc extends Bloc<FlashcardEvent, FlashcardState> {
  final GetDecksUseCase getDecks;
  final GetDeckByIdUseCase getDeckById;
  final CreateDeckUseCase createDeck;
  final UpdateDeckUseCase updateDeck;
  final DeleteDeckUseCase deleteDeck;
  final AddCardToDeckUseCase addCardToDeck;
  final RemoveCardFromDeckUseCase removeCardFromDeck;
  final StartSessionUseCase startSession;
  final GetSessionProgressUseCase getSessionProgress;
  final GetNextCardUseCase getNextCard;
  final ReviewCardUseCase reviewCard;
  final CompleteSessionUseCase completeSession;
  final GetDueCardsUseCase getDueCards;
  final GetDeckStatisticsUseCase getDeckStatistics;

  FlashcardBloc({
    required this.getDecks,
    required this.getDeckById,
    required this.createDeck,
    required this.updateDeck,
    required this.deleteDeck,
    required this.addCardToDeck,
    required this.removeCardFromDeck,
    required this.startSession,
    required this.getSessionProgress,
    required this.getNextCard,
    required this.reviewCard,
    required this.completeSession,
    required this.getDueCards,
    required this.getDeckStatistics,
  }) : super(FlashcardInitial()) {
    on<LoadDecksEvent>(_onLoadDecks);
    on<LoadDeckDetailEvent>(_onLoadDeckDetail);
    on<CreateDeckEvent>(_onCreateDeck);
    on<UpdateDeckEvent>(_onUpdateDeck);
    on<DeleteDeckEvent>(_onDeleteDeck);
    on<AddCardToDeckEvent>(_onAddCardToDeck);
    on<RemoveCardFromDeckEvent>(_onRemoveCardFromDeck);
    on<StartSessionEvent>(_onStartSession);
    on<LoadSessionProgressEvent>(_onLoadSessionProgress);
    on<LoadNextCardEvent>(_onLoadNextCard);
    on<ReviewCardEvent>(_onReviewCard);
    on<CompleteSessionEvent>(_onCompleteSession);
    on<LoadDueCardsEvent>(_onLoadDueCards);
    on<LoadDeckStatisticsEvent>(_onLoadDeckStatistics);
  }

  Future<void> _onLoadDecks(
    LoadDecksEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    final result = await getDecks(search: event.search);
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (decks) => emit(DecksLoaded(decks)),
    );
  }

  Future<void> _onLoadDeckDetail(
    LoadDeckDetailEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    final result = await getDeckById(event.deckId);
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (deck) => emit(DeckDetailLoaded(deck)),
    );
  }

  Future<void> _onCreateDeck(
    CreateDeckEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    final result = await createDeck(
      name: event.name,
      description: event.description,
      kanjiIds: event.kanjiIds,
    );
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (deck) => emit(DeckCreated(deck)),
    );
  }

  Future<void> _onUpdateDeck(
    UpdateDeckEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    final result = await updateDeck(
      deckId: event.deckId,
      name: event.name,
      description: event.description,
      isPublic: event.isPublic,
    );
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (deck) => emit(DeckUpdated(deck)),
    );
  }

  Future<void> _onDeleteDeck(
    DeleteDeckEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    final result = await deleteDeck(event.deckId);
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (_) => emit(DeckDeleted()),
    );
  }

  Future<void> _onAddCardToDeck(
    AddCardToDeckEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    final result = await addCardToDeck(
      deckId: event.deckId,
      kanjiId: event.kanjiId,
    );
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (deck) => emit(CardAddedToDeck(deck)),
    );
  }

  Future<void> _onRemoveCardFromDeck(
    RemoveCardFromDeckEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    final result = await removeCardFromDeck(
      deckId: event.deckId,
      kanjiId: event.kanjiId,
    );
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (deck) => emit(CardRemovedFromDeck(deck)),
    );
  }

  Future<void> _onStartSession(
    StartSessionEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    final result = await startSession(
      deckId: event.deckId,
      maxNewCards: event.maxNewCards,
      maxReviewCards: event.maxReviewCards,
    );
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (session) => emit(SessionStarted(session)),
    );
  }

  Future<void> _onLoadSessionProgress(
    LoadSessionProgressEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    final result = await getSessionProgress(event.sessionId);
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (session) => emit(SessionProgressLoaded(session)),
    );
  }

  Future<void> _onLoadNextCard(
    LoadNextCardEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    final result = await getNextCard(event.sessionId);
    result.fold((failure) => emit(FlashcardError(failure.message)), (card) {
      if (card == null) {
        // No more cards, automatically complete session
        add(CompleteSessionEvent(event.sessionId));
      } else {
        emit(NextCardLoaded(card: card, sessionId: event.sessionId));
      }
    });
  }

  Future<void> _onReviewCard(
    ReviewCardEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    final result = await reviewCard(
      sessionId: event.sessionId,
      cardId: event.cardId,
      quality: event.quality,
      timeSpent: event.timeSpent,
    );
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (_) => emit(CardReviewed(event.sessionId)),
    );
  }

  Future<void> _onCompleteSession(
    CompleteSessionEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    final result = await completeSession(event.sessionId);
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (session) => emit(SessionCompleted(session)),
    );
  }

  Future<void> _onLoadDueCards(
    LoadDueCardsEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    final result = await getDueCards(event.deckId);
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (dueCards) => emit(DueCardsLoaded(dueCards)),
    );
  }

  Future<void> _onLoadDeckStatistics(
    LoadDeckStatisticsEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    final result = await getDeckStatistics(event.deckId);
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (statistics) => emit(DeckStatisticsLoaded(statistics)),
    );
  }
}
