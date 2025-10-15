import 'package:equatable/equatable.dart';

abstract class StudySessionEvent extends Equatable {
  const StudySessionEvent();

  @override
  List<Object?> get props => [];
}

class StartStudySessionEvent extends StudySessionEvent {
  final int deckId;
  final int? maxCards;

  const StartStudySessionEvent({required this.deckId, this.maxCards});

  @override
  List<Object?> get props => [deckId, maxCards];
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

class NextCardEvent extends StudySessionEvent {
  const NextCardEvent();
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
