import 'package:equatable/equatable.dart';

class FlashcardActivityEntry extends Equatable {
  final DateTime date;
  final int value;

  const FlashcardActivityEntry({required this.date, required this.value});

  @override
  List<Object?> get props => [date, value];
}

class FlashcardStats extends Equatable {
  final int totalCards;
  final int cardsReviewed;
  final int totalCorrect;
  final int totalWrong;
  final int accuracy;
  final int currentStreak;
  final int longestStreak;
  final List<FlashcardActivityEntry> activityHeatmap;

  const FlashcardStats({
    required this.totalCards,
    required this.cardsReviewed,
    required this.totalCorrect,
    required this.totalWrong,
    required this.accuracy,
    required this.currentStreak,
    required this.longestStreak,
    required this.activityHeatmap,
  });

  @override
  List<Object?> get props => [
    totalCards,
    cardsReviewed,
    totalCorrect,
    totalWrong,
    accuracy,
    currentStreak,
    longestStreak,
    activityHeatmap,
  ];
}
