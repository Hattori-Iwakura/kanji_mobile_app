import 'package:equatable/equatable.dart';
import '../../domain/entities/flashcard_deck.dart';

abstract class FlashcardDeckState extends Equatable {
  const FlashcardDeckState();

  @override
  List<Object?> get props => [];
}

class FlashcardDeckInitial extends FlashcardDeckState {
  const FlashcardDeckInitial();
}

class FlashcardDeckLoading extends FlashcardDeckState {
  const FlashcardDeckLoading();
}

class FlashcardDeckLoaded extends FlashcardDeckState {
  final List<FlashcardDeck> decks;

  const FlashcardDeckLoaded(this.decks);

  @override
  List<Object> get props => [decks];
}

class FlashcardDeckCreated extends FlashcardDeckState {
  final FlashcardDeck deck;

  const FlashcardDeckCreated(this.deck);

  @override
  List<Object> get props => [deck];
}

class FlashcardDeckDeleted extends FlashcardDeckState {
  const FlashcardDeckDeleted();
}

class FlashcardDeckError extends FlashcardDeckState {
  final String message;

  const FlashcardDeckError(this.message);

  @override
  List<Object> get props => [message];
}
