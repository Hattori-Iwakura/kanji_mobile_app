import 'package:equatable/equatable.dart';

abstract class FlashcardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== DECK MANAGEMENT EVENTS ====================

class LoadDecksEvent extends FlashcardEvent {
  final String? search;

  LoadDecksEvent({this.search});

  @override
  List<Object?> get props => [search];
}

class LoadDeckDetailEvent extends FlashcardEvent {
  final int deckId;

  LoadDeckDetailEvent(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

class CreateDeckEvent extends FlashcardEvent {
  final String name;
  final String? description;
  final List<int>? kanjiIds;

  CreateDeckEvent({required this.name, this.description, this.kanjiIds});

  @override
  List<Object?> get props => [name, description, kanjiIds];
}

class UpdateDeckEvent extends FlashcardEvent {
  final int deckId;
  final String? name;
  final String? description;
  final bool? isPublic;

  UpdateDeckEvent({
    required this.deckId,
    this.name,
    this.description,
    this.isPublic,
  });

  @override
  List<Object?> get props => [deckId, name, description, isPublic];
}

class DeleteDeckEvent extends FlashcardEvent {
  final int deckId;

  DeleteDeckEvent(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

class AddCardToDeckEvent extends FlashcardEvent {
  final int deckId;
  final int kanjiId;

  AddCardToDeckEvent({required this.deckId, required this.kanjiId});

  @override
  List<Object?> get props => [deckId, kanjiId];
}

class RemoveCardFromDeckEvent extends FlashcardEvent {
  final int deckId;
  final int kanjiId;

  RemoveCardFromDeckEvent({required this.deckId, required this.kanjiId});

  @override
  List<Object?> get props => [deckId, kanjiId];
}

// ==================== STUDY SESSION EVENTS ====================

class StartSessionEvent extends FlashcardEvent {
  final int deckId;
  final int? maxNewCards;
  final int? maxReviewCards;

  StartSessionEvent({
    required this.deckId,
    this.maxNewCards,
    this.maxReviewCards,
  });

  @override
  List<Object?> get props => [deckId, maxNewCards, maxReviewCards];
}

class LoadSessionProgressEvent extends FlashcardEvent {
  final int sessionId;

  LoadSessionProgressEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class LoadNextCardEvent extends FlashcardEvent {
  final int sessionId;

  LoadNextCardEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class ReviewCardEvent extends FlashcardEvent {
  final int sessionId;
  final int cardId;
  final int quality;
  final double? timeSpent;

  ReviewCardEvent({
    required this.sessionId,
    required this.cardId,
    required this.quality,
    this.timeSpent,
  });

  @override
  List<Object?> get props => [sessionId, cardId, quality, timeSpent];
}

class CompleteSessionEvent extends FlashcardEvent {
  final int sessionId;

  CompleteSessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

// ==================== STATISTICS EVENTS ====================

class LoadDueCardsEvent extends FlashcardEvent {
  final int deckId;

  LoadDueCardsEvent(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

class LoadDeckStatisticsEvent extends FlashcardEvent {
  final int deckId;

  LoadDeckStatisticsEvent(this.deckId);

  @override
  List<Object?> get props => [deckId];
}
