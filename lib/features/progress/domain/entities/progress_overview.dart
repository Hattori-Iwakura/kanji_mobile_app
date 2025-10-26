import 'package:equatable/equatable.dart';

/// Entity representing comprehensive user progress overview
class ProgressOverview extends Equatable {
  final int userId;
  final String username;
  final int currentStreak;
  final int longestStreak;
  final int totalStudyTime; // in minutes
  final int xp;
  final int level;
  final int flashcardsStudied;
  final int quizzesCompleted;
  final double averageQuizScore;
  final int achievementsUnlocked;
  final DateTime? lastActivityDate;

  const ProgressOverview({
    required this.userId,
    required this.username,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalStudyTime,
    required this.xp,
    required this.level,
    required this.flashcardsStudied,
    required this.quizzesCompleted,
    required this.averageQuizScore,
    required this.achievementsUnlocked,
    this.lastActivityDate,
  });

  @override
  List<Object?> get props => [
    userId,
    username,
    currentStreak,
    longestStreak,
    totalStudyTime,
    xp,
    level,
    flashcardsStudied,
    quizzesCompleted,
    averageQuizScore,
    achievementsUnlocked,
    lastActivityDate,
  ];
}
