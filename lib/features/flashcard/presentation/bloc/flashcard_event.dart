import 'package:equatable/equatable.dart';

/// Base event for Flashcard BLoC
abstract class FlashcardEvent extends Equatable {
  const FlashcardEvent();

  @override
  List<Object?> get props => [];
}

// ========== DECK EVENTS ==========
/// Event to load all decks
class LoadDecksEvent extends FlashcardEvent {}

/// Event to create new deck
class CreateDeckEvent extends FlashcardEvent {
  final String name;
  final String? description;

  const CreateDeckEvent({required this.name, this.description});

  @override
  List<Object?> get props => [name, description];
}

/// Event to delete deck
class DeleteDeckEvent extends FlashcardEvent {
  final String deckId;

  const DeleteDeckEvent(this.deckId);

  @override
  List<Object> get props => [deckId];
}

// ========== STUDY SESSION EVENTS ==========
/// Event to start study session
class StartStudySessionEvent extends FlashcardEvent {
  final String deckId;

  const StartStudySessionEvent(this.deckId);

  @override
  List<Object> get props => [deckId];
}

/// Event to flip card (toggle answer visibility)
class FlipCardEvent extends FlashcardEvent {}

/// Event to answer a flashcard (quality 0-5)
class AnswerCardEvent extends FlashcardEvent {
  final String cardId;
  final int quality;

  const AnswerCardEvent({required this.cardId, required this.quality});

  @override
  List<Object> get props => [cardId, quality];
}

/// Event to end study session
class EndStudySessionEvent extends FlashcardEvent {
  final String deckId;
  final int cardsStudied;
  final int cardsCorrect;
  final int cardsIncorrect;
  final int studyDuration;

  const EndStudySessionEvent({
    required this.deckId,
    required this.cardsStudied,
    required this.cardsCorrect,
    required this.cardsIncorrect,
    required this.studyDuration,
  });

  @override
  List<Object> get props => [
    deckId,
    cardsStudied,
    cardsCorrect,
    cardsIncorrect,
    studyDuration,
  ];
}
