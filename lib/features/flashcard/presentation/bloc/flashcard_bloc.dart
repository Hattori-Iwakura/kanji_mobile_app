import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_decks.dart';
import '../../domain/usecases/get_due_cards.dart';
import '../../domain/usecases/update_card_review.dart';
import '../../domain/usecases/save_study_progress.dart';
import '../../domain/repositories/flashcard_repository.dart';
import 'flashcard_event.dart';
import 'flashcard_state.dart';

/// BLoC for managing flashcard state
class FlashcardBloc extends Bloc<FlashcardEvent, FlashcardState> {
  final GetAllDecks getAllDecks;
  final GetDueCards getDueCards;
  final UpdateCardReview updateCardReview;
  final SaveStudyProgress saveStudyProgress;
  final FlashcardRepository repository;

  FlashcardBloc({
    required this.getAllDecks,
    required this.getDueCards,
    required this.updateCardReview,
    required this.saveStudyProgress,
    required this.repository,
  }) : super(FlashcardInitial()) {
    on<LoadDecksEvent>(_onLoadDecks);
    on<CreateDeckEvent>(_onCreateDeck);
    on<DeleteDeckEvent>(_onDeleteDeck);
    on<StartStudySessionEvent>(_onStartStudySession);
    on<FlipCardEvent>(_onFlipCard);
    on<AnswerCardEvent>(_onAnswerCard);
    on<EndStudySessionEvent>(_onEndStudySession);
  }

  Future<void> _onLoadDecks(
    LoadDecksEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());

    final result = await getAllDecks();

    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (decks) => emit(DecksLoaded(decks)),
    );
  }

  Future<void> _onCreateDeck(
    CreateDeckEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());

    final result = await repository.createDeck(
      name: event.name,
      description: event.description,
    );

    result.fold((failure) => emit(FlashcardError(failure.message)), (deck) {
      emit(DeckCreated(deck));
      // Reload decks after creation
      add(LoadDecksEvent());
    });
  }

  Future<void> _onDeleteDeck(
    DeleteDeckEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());

    final result = await repository.deleteDeck(event.deckId);

    result.fold((failure) => emit(FlashcardError(failure.message)), (_) {
      emit(DeckDeleted());
      // Reload decks after deletion
      add(LoadDecksEvent());
    });
  }

  Future<void> _onStartStudySession(
    StartStudySessionEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());

    // Get due cards and new cards
    final dueResult = await getDueCards(event.deckId);

    // Handle due cards result
    final dueCards = dueResult.fold((failure) {
      emit(FlashcardError(failure.message));
      return null;
    }, (cards) => cards);

    if (dueCards == null) return;

    // Get new cards if needed
    final newCardsResult = await repository.getNewCards(
      event.deckId,
      limit: 10,
    );

    // Handle new cards result
    final newCards = newCardsResult.fold((failure) {
      emit(FlashcardError(failure.message));
      return null;
    }, (cards) => cards);

    if (newCards == null) return;

    final allCards = [...dueCards, ...newCards];

    if (allCards.isEmpty) {
      emit(
        const FlashcardError(
          'No cards to review. Add some cards to this deck first.',
        ),
      );
    } else {
      emit(StudySessionActive(cards: allCards, currentIndex: 0));
    }
  }

  void _onFlipCard(FlipCardEvent event, Emitter<FlashcardState> emit) {
    if (state is! StudySessionActive) return;

    final currentState = state as StudySessionActive;
    emit(currentState.copyWith(showAnswer: !currentState.showAnswer));
  }

  Future<void> _onAnswerCard(
    AnswerCardEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    if (state is! StudySessionActive) return;

    final currentState = state as StudySessionActive;

    // Update card review with SM-2 algorithm
    final result = await updateCardReview(
      cardId: event.cardId,
      quality: event.quality,
    );

    result.fold((failure) => emit(FlashcardError(failure.message)), (
      updatedCard,
    ) {
      // Determine if answer was correct (quality >= 3)
      final isCorrect = event.quality >= 3;

      // Move to next card
      emit(
        currentState.copyWith(
          currentIndex: currentState.currentIndex + 1,
          cardsCorrect: isCorrect
              ? currentState.cardsCorrect + 1
              : currentState.cardsCorrect,
          cardsIncorrect: !isCorrect
              ? currentState.cardsIncorrect + 1
              : currentState.cardsIncorrect,
          showAnswer: false,
        ),
      );
    });
  }

  Future<void> _onEndStudySession(
    EndStudySessionEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());

    final result = await saveStudyProgress(
      deckId: event.deckId,
      cardsStudied: event.cardsStudied,
      cardsCorrect: event.cardsCorrect,
      cardsIncorrect: event.cardsIncorrect,
      studyDuration: event.studyDuration,
    );

    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (progress) => emit(StudySessionCompleted(progress)),
    );
  }
}
