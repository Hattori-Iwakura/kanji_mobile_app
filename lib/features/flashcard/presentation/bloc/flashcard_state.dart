import 'package:equatable/equatable.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/entities/flashcard_deck.dart';
import '../../domain/entities/study_progress.dart';

/// Base state for Flashcard BLoC
abstract class FlashcardState extends Equatable {
  const FlashcardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FlashcardInitial extends FlashcardState {}

/// Loading state
class FlashcardLoading extends FlashcardState {}

// ========== DECK STATES ==========
/// State when decks are loaded
class DecksLoaded extends FlashcardState {
  final List<FlashcardDeck> decks;

  const DecksLoaded(this.decks);

  @override
  List<Object> get props => [decks];

  /// Check if user has any decks
  bool get hasDecks => decks.isNotEmpty;

  /// Get decks with cards to review
  List<FlashcardDeck> get decksWithReview =>
      decks.where((deck) => deck.hasCardsToReview).toList();
}

/// State when deck is created
class DeckCreated extends FlashcardState {
  final FlashcardDeck deck;

  const DeckCreated(this.deck);

  @override
  List<Object> get props => [deck];
}

/// State when deck is deleted
class DeckDeleted extends FlashcardState {}

// ========== STUDY SESSION STATES ==========
/// State during study session
class StudySessionActive extends FlashcardState {
  final List<Flashcard> cards;
  final int currentIndex;
  final int cardsCorrect;
  final int cardsIncorrect;
  final bool showAnswer;

  const StudySessionActive({
    required this.cards,
    required this.currentIndex,
    this.cardsCorrect = 0,
    this.cardsIncorrect = 0,
    this.showAnswer = false,
  });

  @override
  List<Object> get props => [
    cards,
    currentIndex,
    cardsCorrect,
    cardsIncorrect,
    showAnswer,
  ];

  /// Get current card
  Flashcard? get currentCard =>
      currentIndex < cards.length ? cards[currentIndex] : null;

  /// Check if session is complete
  bool get isComplete => currentIndex >= cards.length;

  /// Get progress percentage
  double get progressPercentage {
    if (cards.isEmpty) return 0.0;
    return (currentIndex / cards.length) * 100;
  }

  /// Get total cards studied
  int get cardsStudied => currentIndex;

  /// Get accuracy percentage
  double get accuracy {
    final total = cardsCorrect + cardsIncorrect;
    if (total == 0) return 0.0;
    return (cardsCorrect / total) * 100;
  }

  /// Copy with new values
  StudySessionActive copyWith({
    List<Flashcard>? cards,
    int? currentIndex,
    int? cardsCorrect,
    int? cardsIncorrect,
    bool? showAnswer,
  }) {
    return StudySessionActive(
      cards: cards ?? this.cards,
      currentIndex: currentIndex ?? this.currentIndex,
      cardsCorrect: cardsCorrect ?? this.cardsCorrect,
      cardsIncorrect: cardsIncorrect ?? this.cardsIncorrect,
      showAnswer: showAnswer ?? this.showAnswer,
    );
  }
}

/// State when study session ends
class StudySessionCompleted extends FlashcardState {
  final StudyProgress progress;

  const StudySessionCompleted(this.progress);

  @override
  List<Object> get props => [progress];
}

/// Error state
class FlashcardError extends FlashcardState {
  final String message;

  const FlashcardError(this.message);

  @override
  List<Object> get props => [message];
}
