import 'package:equatable/equatable.dart';
import '../../domain/entities/flashcard_deck.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/entities/next_card.dart';
import '../../domain/entities/deck_statistics.dart';

abstract class FlashcardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FlashcardInitial extends FlashcardState {}

class FlashcardLoading extends FlashcardState {}

// ==================== DECK STATES ====================

class DecksLoaded extends FlashcardState {
  final List<FlashcardDeck> decks;

  DecksLoaded(this.decks);

  @override
  List<Object?> get props => [decks];
}

class DeckDetailLoaded extends FlashcardState {
  final FlashcardDeck deck;

  DeckDetailLoaded(this.deck);

  @override
  List<Object?> get props => [deck];
}

class DeckCreated extends FlashcardState {
  final FlashcardDeck deck;

  DeckCreated(this.deck);

  @override
  List<Object?> get props => [deck];
}

class DeckUpdated extends FlashcardState {
  final FlashcardDeck deck;

  DeckUpdated(this.deck);

  @override
  List<Object?> get props => [deck];
}

class DeckDeleted extends FlashcardState {}

class CardAddedToDeck extends FlashcardState {
  final FlashcardDeck deck;

  CardAddedToDeck(this.deck);

  @override
  List<Object?> get props => [deck];
}

class CardRemovedFromDeck extends FlashcardState {
  final FlashcardDeck deck;

  CardRemovedFromDeck(this.deck);

  @override
  List<Object?> get props => [deck];
}

// ==================== STUDY SESSION STATES ====================

class SessionStarted extends FlashcardState {
  final StudySession session;

  SessionStarted(this.session);

  @override
  List<Object?> get props => [session];
}

class SessionProgressLoaded extends FlashcardState {
  final StudySession session;

  SessionProgressLoaded(this.session);

  @override
  List<Object?> get props => [session];
}

class NextCardLoaded extends FlashcardState {
  final NextCard card;
  final int sessionId;

  NextCardLoaded({required this.card, required this.sessionId});

  @override
  List<Object?> get props => [card, sessionId];
}

class CardReviewed extends FlashcardState {
  final int sessionId;

  CardReviewed(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class SessionCompleted extends FlashcardState {
  final StudySession session;

  SessionCompleted(this.session);

  @override
  List<Object?> get props => [session];
}

// ==================== STATISTICS STATES ====================

class DueCardsLoaded extends FlashcardState {
  final Map<String, dynamic> dueCards;

  DueCardsLoaded(this.dueCards);

  @override
  List<Object?> get props => [dueCards];
}

class DeckStatisticsLoaded extends FlashcardState {
  final DeckStatistics statistics;

  DeckStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

// ==================== ERROR STATE ====================

class FlashcardError extends FlashcardState {
  final String message;

  FlashcardError(this.message);

  @override
  List<Object?> get props => [message];
}
