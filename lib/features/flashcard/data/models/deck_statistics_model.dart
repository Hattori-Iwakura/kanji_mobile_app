import '../../domain/entities/deck_statistics.dart';

class DeckStatisticsModel extends DeckStatistics {
  const DeckStatisticsModel({
    required super.deckId,
    required super.deckName,
    required super.totalCards,
    required super.newCards,
    required super.learningCards,
    required super.reviewCards,
    required super.masteredCards,
    required super.dueCards,
    required super.avgEasinessFactor,
    required super.totalStudyTime,
    super.lastStudiedAt,
  });

  factory DeckStatisticsModel.fromJson(Map<String, dynamic> json) {
    return DeckStatisticsModel(
      deckId: json['deckId'] as int,
      deckName: json['deckName'] as String,
      totalCards: json['totalCards'] as int,
      newCards: json['newCards'] as int,
      learningCards: json['learningCards'] as int,
      reviewCards: json['reviewCards'] as int,
      masteredCards: json['masteredCards'] as int,
      dueCards: json['dueCards'] as int,
      avgEasinessFactor: (json['avgEasinessFactor'] as num).toDouble(),
      totalStudyTime: json['totalStudyTime'] as int,
      lastStudiedAt: json['lastStudiedAt'] != null
          ? DateTime.parse(json['lastStudiedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deckId': deckId,
      'deckName': deckName,
      'totalCards': totalCards,
      'newCards': newCards,
      'learningCards': learningCards,
      'reviewCards': reviewCards,
      'masteredCards': masteredCards,
      'dueCards': dueCards,
      'avgEasinessFactor': avgEasinessFactor,
      'totalStudyTime': totalStudyTime,
      if (lastStudiedAt != null)
        'lastStudiedAt': lastStudiedAt!.toIso8601String(),
    };
  }
}
