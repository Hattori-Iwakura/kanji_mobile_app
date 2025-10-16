import 'package:equatable/equatable.dart';

abstract class StudySessionEvent extends Equatable {
  const StudySessionEvent();

  @override
  List<Object?> get props => [];
}

class InitializeStudySessionEvent extends StudySessionEvent {
  final int deckId;

  const InitializeStudySessionEvent(this.deckId);

  @override
  List<Object> get props => [deckId];
}

class StartStudySessionEvent extends StudySessionEvent {
  final int deckId;
  final int? maxCards;
  final String? mode;
  final bool? randomize;
  final bool? includeNew;
  final bool? includeDue;
  final bool? includeHard;
  final int? difficultyThreshold;
  final bool? resumeExisting;

  const StartStudySessionEvent({
    required this.deckId,
    this.maxCards,
    this.mode,
    this.randomize,
    this.includeNew,
    this.includeDue,
    this.includeHard,
    this.difficultyThreshold,
    this.resumeExisting,
  });

  @override
  List<Object?> get props => [
    deckId,
    maxCards,
    mode,
    randomize,
    includeNew,
    includeDue,
    includeHard,
    difficultyThreshold,
    resumeExisting,
  ];
}

class ReviewCardEvent extends StudySessionEvent {
  final int sessionId;
  final int cardId;
  final int rating;
  final int timeSpent;

  const ReviewCardEvent({
    required this.sessionId,
    required this.cardId,
    required this.rating,
    required this.timeSpent,
  });

  @override
  List<Object> get props => [sessionId, cardId, rating, timeSpent];
}

class CompleteSessionEvent extends StudySessionEvent {
  final int sessionId;

  const CompleteSessionEvent(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

class ResetSessionEvent extends StudySessionEvent {
  const ResetSessionEvent();
}

class ResumeExistingSessionEvent extends StudySessionEvent {
  final int sessionId;
  final int? deckId;

  const ResumeExistingSessionEvent(this.sessionId, {this.deckId});

  @override
  List<Object?> get props => [sessionId, deckId];
}

class PauseCurrentSessionEvent extends StudySessionEvent {
  final int sessionId;

  const PauseCurrentSessionEvent(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}
