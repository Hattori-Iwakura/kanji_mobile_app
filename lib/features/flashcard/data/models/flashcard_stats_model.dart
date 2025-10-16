import '../../domain/entities/flashcard_stats.dart';

class FlashcardStatsModel extends FlashcardStats {
  FlashcardStatsModel({
    required super.totalCards,
    required super.cardsReviewed,
    required super.totalCorrect,
    required super.totalWrong,
    required super.accuracy,
    required super.currentStreak,
    required super.longestStreak,
    required List<FlashcardActivityEntry> activityHeatmap,
  }) : super(activityHeatmap: activityHeatmap);

  factory FlashcardStatsModel.fromJson(Map<String, dynamic> json) {
    final heatmap = (json['activityHeatmap'] as List? ?? [])
        .map(
          (entry) => FlashcardActivityEntry(
            date: DateTime.parse(entry['date'] as String),
            value: entry['value'] as int,
          ),
        )
        .toList();

    return FlashcardStatsModel(
      totalCards: json['totalCards'] as int,
      cardsReviewed: json['cardsReviewed'] as int,
      totalCorrect: json['totalCorrect'] as int? ?? 0,
      totalWrong: json['totalWrong'] as int? ?? 0,
      accuracy: json['accuracy'] as int,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      activityHeatmap: heatmap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCards': totalCards,
      'cardsReviewed': cardsReviewed,
      'totalCorrect': totalCorrect,
      'totalWrong': totalWrong,
      'accuracy': accuracy,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'activityHeatmap': activityHeatmap
          .map(
            (entry) => {
              'date': entry.date.toIso8601String(),
              'value': entry.value,
            },
          )
          .toList(),
    };
  }
}
