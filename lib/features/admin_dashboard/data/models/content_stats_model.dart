import '../domain/entities/content_stats.dart';

/// Model for ContentStats with JSON serialization
class ContentStatsModel extends ContentStats {
  const ContentStatsModel({
    required super.totalKanji,
    required super.totalKanjiLists,
    required super.totalFlashcardDecks,
    required super.totalQuizzes,
    required super.totalUsers,
    required super.activeUsers,
  });

  factory ContentStatsModel.fromJson(Map<String, dynamic> json) {
    return ContentStatsModel(
      totalKanji: json['totalKanji'] as int? ?? 0,
      totalKanjiLists: json['totalKanjiLists'] as int? ?? 0,
      totalFlashcardDecks: json['totalFlashcardDecks'] as int? ?? 0,
      totalQuizzes: json['totalQuizzes'] as int? ?? 0,
      totalUsers: json['totalUsers'] as int? ?? 0,
      activeUsers: json['activeUsers'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalKanji': totalKanji,
      'totalKanjiLists': totalKanjiLists,
      'totalFlashcardDecks': totalFlashcardDecks,
      'totalQuizzes': totalQuizzes,
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
    };
  }
}
