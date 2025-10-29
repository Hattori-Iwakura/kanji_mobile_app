import 'package:equatable/equatable.dart';

class DeckStatistics extends Equatable {
  final int deckId;
  final String deckName;
  final int totalCards;
  final int newCards;
  final int learningCards;
  final int reviewCards;
  final int masteredCards;
  final int dueCards;
  final double avgEasinessFactor;
  final int totalStudyTime;
  final DateTime? lastStudiedAt;

  const DeckStatistics({
    required this.deckId,
    required this.deckName,
    required this.totalCards,
    required this.newCards,
    required this.learningCards,
    required this.reviewCards,
    required this.masteredCards,
    required this.dueCards,
    required this.avgEasinessFactor,
    required this.totalStudyTime,
    this.lastStudiedAt,
  });

  @override
  List<Object?> get props => [
    deckId,
    deckName,
    totalCards,
    newCards,
    learningCards,
    reviewCards,
    masteredCards,
    dueCards,
    avgEasinessFactor,
    totalStudyTime,
    lastStudiedAt,
  ];
}
