import 'package:equatable/equatable.dart';

class StudySession extends Equatable {
  final int sessionId;
  final int deckId;
  final String deckName;
  final int totalCards;
  final int newCards;
  final int reviewCards;
  final int cardsReviewed;
  final int correctAnswers;
  final int incorrectAnswers;
  final int accuracy;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? totalTime;
  final int? cardsMastered;

  const StudySession({
    required this.sessionId,
    required this.deckId,
    required this.deckName,
    required this.totalCards,
    required this.newCards,
    required this.reviewCards,
    required this.cardsReviewed,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.accuracy,
    required this.startedAt,
    this.completedAt,
    this.totalTime,
    this.cardsMastered,
  });

  @override
  List<Object?> get props => [
    sessionId,
    deckId,
    deckName,
    totalCards,
    newCards,
    reviewCards,
    cardsReviewed,
    correctAnswers,
    incorrectAnswers,
    accuracy,
    startedAt,
    completedAt,
    totalTime,
    cardsMastered,
  ];
}
