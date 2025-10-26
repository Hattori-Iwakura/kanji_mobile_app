import 'package:equatable/equatable.dart';

/// Entity representing activity statistics from admin dashboard
class ActivityStats extends Equatable {
  final int totalFlashcardSessions;
  final int totalQuizAttempts;
  final int totalReviews;
  final int todayFlashcardSessions;
  final int todayQuizAttempts;
  final int todayReviews;

  const ActivityStats({
    required this.totalFlashcardSessions,
    required this.totalQuizAttempts,
    required this.totalReviews,
    required this.todayFlashcardSessions,
    required this.todayQuizAttempts,
    required this.todayReviews,
  });

  @override
  List<Object?> get props => [
    totalFlashcardSessions,
    totalQuizAttempts,
    totalReviews,
    todayFlashcardSessions,
    todayQuizAttempts,
    todayReviews,
  ];
}
