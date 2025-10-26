import '../domain/entities/activity_stats.dart';

/// Model for ActivityStats with JSON serialization
class ActivityStatsModel extends ActivityStats {
  const ActivityStatsModel({
    required super.totalFlashcardSessions,
    required super.totalQuizAttempts,
    required super.totalReviews,
    required super.todayFlashcardSessions,
    required super.todayQuizAttempts,
    required super.todayReviews,
  });

  factory ActivityStatsModel.fromJson(Map<String, dynamic> json) {
    return ActivityStatsModel(
      totalFlashcardSessions: json['totalFlashcardSessions'] as int? ?? 0,
      totalQuizAttempts: json['totalQuizAttempts'] as int? ?? 0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      todayFlashcardSessions: json['todayFlashcardSessions'] as int? ?? 0,
      todayQuizAttempts: json['todayQuizAttempts'] as int? ?? 0,
      todayReviews: json['todayReviews'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalFlashcardSessions': totalFlashcardSessions,
      'totalQuizAttempts': totalQuizAttempts,
      'totalReviews': totalReviews,
      'todayFlashcardSessions': todayFlashcardSessions,
      'todayQuizAttempts': todayQuizAttempts,
      'todayReviews': todayReviews,
    };
  }
}
