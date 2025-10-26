import '../../domain/entities/progress_overview.dart';

class ProgressOverviewModel extends ProgressOverview {
  const ProgressOverviewModel({
    required super.userId,
    required super.username,
    required super.currentStreak,
    required super.longestStreak,
    required super.totalStudyTime,
    required super.xp,
    required super.level,
    required super.flashcardsStudied,
    required super.quizzesCompleted,
    required super.averageQuizScore,
    required super.achievementsUnlocked,
    super.lastActivityDate,
  });

  factory ProgressOverviewModel.fromJson(Map<String, dynamic> json) {
    return ProgressOverviewModel(
      userId: json['userId'] as int,
      username: json['username'] as String,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      totalStudyTime: json['totalStudyTime'] as int? ?? 0,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      flashcardsStudied: json['flashcardsStudied'] as int? ?? 0,
      quizzesCompleted: json['quizzesCompleted'] as int? ?? 0,
      averageQuizScore: (json['averageQuizScore'] as num?)?.toDouble() ?? 0.0,
      achievementsUnlocked: json['achievementsUnlocked'] as int? ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalStudyTime': totalStudyTime,
      'xp': xp,
      'level': level,
      'flashcardsStudied': flashcardsStudied,
      'quizzesCompleted': quizzesCompleted,
      'averageQuizScore': averageQuizScore,
      'achievementsUnlocked': achievementsUnlocked,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
    };
  }
}
