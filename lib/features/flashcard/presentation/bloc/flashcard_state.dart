import 'package:equatable/equatable.dart';
import '../../domain/entities/flashcard_card_entity.dart';
import '../../domain/entities/flashcard_deck_entity.dart';

abstract class FlashcardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FlashcardInitial extends FlashcardState {}

class FlashcardLoading extends FlashcardState {}

// Deck states
class DecksLoaded extends FlashcardState {
  final List<FlashcardDeckEntity> decks;
  final String? appliedSearch;
  final int? appliedLimit;
  final int? appliedOffset;

  DecksLoaded({
    required this.decks,
    this.appliedSearch,
    this.appliedLimit,
    this.appliedOffset,
  });

  @override
  List<Object?> get props => [
    decks,
    appliedSearch,
    appliedLimit,
    appliedOffset,
  ];
}

class DeckDetailLoaded extends FlashcardState {
  final FlashcardDeckEntity deck;

  DeckDetailLoaded(this.deck);

  @override
  List<Object?> get props => [deck];
}

class DeckCreated extends FlashcardState {
  final FlashcardDeckEntity deck;

  DeckCreated(this.deck);

  @override
  List<Object?> get props => [deck];
}

class DeckUpdated extends FlashcardState {
  final FlashcardDeckEntity deck;

  DeckUpdated(this.deck);

  @override
  List<Object?> get props => [deck];
}

class DeckDeleted extends FlashcardState {}

// Card states
class CardAdded extends FlashcardState {
  final FlashcardCardEntity card;

  CardAdded(this.card);

  @override
  List<Object?> get props => [card];
}

class CardRemoved extends FlashcardState {}

// Publish states
class PublishRequested extends FlashcardState {}

class PublishRequestsLoaded extends FlashcardState {
  final List<dynamic> requests;

  PublishRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class PublishRequestApproved extends FlashcardState {}

class PublishRequestRejected extends FlashcardState {}

// Error state
class FlashcardError extends FlashcardState {
  final String message;

  FlashcardError(this.message);

  @override
  List<Object?> get props => [message];
}
