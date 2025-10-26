import 'package:equatable/equatable.dart';
import '../../domain/entities/flashcard_deck_new.dart';

/// Base state for FlashcardDeck BLoC
abstract class FlashcardDeckState extends Equatable {
  const FlashcardDeckState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FlashcardDeckInitial extends FlashcardDeckState {}

/// Loading state
class FlashcardDeckLoading extends FlashcardDeckState {}

/// State when deck list is loaded
class FlashcardDecksLoaded extends FlashcardDeckState {
  final List<FlashcardDeckNew> decks;

  const FlashcardDecksLoaded(this.decks);

  @override
  List<Object> get props => [decks];
}

/// State when single deck is loaded
class FlashcardDeckLoaded extends FlashcardDeckState {
  final FlashcardDeckNew deck;

  const FlashcardDeckLoaded(this.deck);

  @override
  List<Object> get props => [deck];
}

/// State when deck is created successfully
class FlashcardDeckCreated extends FlashcardDeckState {
  final FlashcardDeckNew deck;

  const FlashcardDeckCreated(this.deck);

  @override
  List<Object> get props => [deck];
}

/// State when deck is updated successfully
class FlashcardDeckUpdated extends FlashcardDeckState {
  final FlashcardDeckNew deck;

  const FlashcardDeckUpdated(this.deck);

  @override
  List<Object> get props => [deck];
}

/// State when deck is deleted successfully
class FlashcardDeckDeleted extends FlashcardDeckState {
  final int deckId;

  const FlashcardDeckDeleted(this.deckId);

  @override
  List<Object> get props => [deckId];
}

/// State when card is added successfully
class CardAddedToDeck extends FlashcardDeckState {
  final FlashcardDeckNew deck;

  const CardAddedToDeck(this.deck);

  @override
  List<Object> get props => [deck];
}

/// State when card is removed successfully
class CardRemovedFromDeck extends FlashcardDeckState {
  final FlashcardDeckNew deck;

  const CardRemovedFromDeck(this.deck);

  @override
  List<Object> get props => [deck];
}

/// Error state
class FlashcardDeckError extends FlashcardDeckState {
  final String message;

  const FlashcardDeckError(this.message);

  @override
  List<Object> get props => [message];
}
