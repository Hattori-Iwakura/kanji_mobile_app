/// Progress models for statistics and achievements
class ProgressOverview {
  final int userId;
  final String username;
  final int currentStreak;
  final int longestStreak;
  final int totalStudyTime; // seconds
  final int totalFlashcardSessions;
  final int totalQuizAttempts;
  final int flashcardAccuracy; // percentage
  final int quizAccuracy; // percentage
  final int kanjiMastered;
  final int achievements;
  final int level;
  final int xp;
  final DateTime lastActive;

  ProgressOverview({
    required this.userId,
    required this.username,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalStudyTime,
    required this.totalFlashcardSessions,
    required this.totalQuizAttempts,
    required this.flashcardAccuracy,
    required this.quizAccuracy,
    required this.kanjiMastered,
    required this.achievements,
    required this.level,
    required this.xp,
    required this.lastActive,
  });

  factory ProgressOverview.fromJson(Map<String, dynamic> json) {
    return ProgressOverview(
      userId: json['userId'] as int,
      username: json['username'] as String? ?? 'User',
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      totalStudyTime: json['totalStudyTime'] as int? ?? 0,
      totalFlashcardSessions: json['totalFlashcardSessions'] as int? ?? 0,
      totalQuizAttempts: json['totalQuizAttempts'] as int? ?? 0,
      flashcardAccuracy: json['flashcardAccuracy'] as int? ?? 0,
      quizAccuracy: json['quizAccuracy'] as int? ?? 0,
      kanjiMastered: json['kanjiMastered'] as int? ?? 0,
      achievements: json['achievements'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      lastActive: DateTime.parse(json['lastActive'] as String),
    );
  }

  // Helper: Format study time to hours and minutes
  String get formattedStudyTime {
    final hours = totalStudyTime ~/ 3600;
    final minutes = (totalStudyTime % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  // Helper: XP needed for next level
  int get xpForNextLevel {
    final nextLevel = level + 1;
    return nextLevel * nextLevel * 100;
  }

  // Helper: XP progress percentage
  double get xpProgress {
    final currentLevelXP = level * level * 100;
    final nextLevelXP = xpForNextLevel;
    final progress = (xp - currentLevelXP) / (nextLevelXP - currentLevelXP);
    return progress.clamp(0.0, 1.0);
  }
}

class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final bool isActive;
  final DateTime lastStudyDate;
  final List<DateTime> streakDates;
  final int totalStudyDays;
  final int daysThisWeek;
  final int daysThisMonth;

  StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.isActive,
    required this.lastStudyDate,
    required this.streakDates,
    required this.totalStudyDays,
    required this.daysThisWeek,
    required this.daysThisMonth,
  });

  factory StreakInfo.fromJson(Map<String, dynamic> json) {
    return StreakInfo(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      lastStudyDate: DateTime.parse(json['lastStudyDate'] as String),
      streakDates:
          (json['streakDates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
      totalStudyDays: json['totalStudyDays'] as int? ?? 0,
      daysThisWeek: json['daysThisWeek'] as int? ?? 0,
      daysThisMonth: json['daysThisMonth'] as int? ?? 0,
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final int userId;
  final String username;
  final String? avatar;
  final int score;
  final int xp;
  final int level;
  final int streak;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    this.avatar,
    required this.score,
    required this.xp,
    required this.level,
    required this.streak,
    required this.isCurrentUser,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['userId'] as int,
      username: json['username'] as String? ?? 'User',
      avatar: json['avatar'] as String?,
      score: json['score'] as int? ?? 0,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      streak: json['streak'] as int? ?? 0,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }
}

class Leaderboard {
  final String type;
  final String period;
  final List<LeaderboardEntry> entries;
  final int currentUserRank;
  final LeaderboardEntry? currentUser;
  final int totalUsers;

  Leaderboard({
    required this.type,
    required this.period,
    required this.entries,
    required this.currentUserRank,
    this.currentUser,
    required this.totalUsers,
  });

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      type: json['type'] as String? ?? 'xp',
      period: json['period'] as String? ?? 'week',
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentUserRank: json['currentUserRank'] as int? ?? 0,
      currentUser: json['currentUser'] != null
          ? LeaderboardEntry.fromJson(
              json['currentUser'] as Map<String, dynamic>,
            )
          : null,
      totalUsers: json['totalUsers'] as int? ?? 0,
    );
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;
  final bool unlocked;
  final DateTime? unlockedAt;
  final int progress; // 0-100
  final int currentValue;
  final int targetValue;
  final int xpReward;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.unlocked,
    this.unlockedAt,
    required this.progress,
    required this.currentValue,
    required this.targetValue,
    required this.xpReward,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      category: json['category'] as String,
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      progress: json['progress'] as int? ?? 0,
      currentValue: json['currentValue'] as int? ?? 0,
      targetValue: json['targetValue'] as int? ?? 1,
      xpReward: json['xpReward'] as int? ?? 0,
    );
  }
}

class Achievements {
  final List<Achievement> achievements;
  final int totalUnlocked;
  final int totalAvailable;
  final int completionPercentage;
  final List<Achievement> recentlyUnlocked;

  Achievements({
    required this.achievements,
    required this.totalUnlocked,
    required this.totalAvailable,
    required this.completionPercentage,
    required this.recentlyUnlocked,
  });

  factory Achievements.fromJson(Map<String, dynamic> json) {
    return Achievements(
      achievements:
          (json['achievements'] as List<dynamic>?)
              ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalUnlocked: json['totalUnlocked'] as int? ?? 0,
      totalAvailable: json['totalAvailable'] as int? ?? 0,
      completionPercentage: json['completionPercentage'] as int? ?? 0,
      recentlyUnlocked:
          (json['recentlyUnlocked'] as List<dynamic>?)
              ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ChartData {
  final List<String> labels;
  final List<int> studyTime;
  final List<int> cardsReviewed;
  final List<int> quizAttempts;
  final List<int> accuracy;
  final List<int> xpEarned;

  ChartData({
    required this.labels,
    required this.studyTime,
    required this.cardsReviewed,
    required this.quizAttempts,
    required this.accuracy,
    required this.xpEarned,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      labels:
          (json['labels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      studyTime:
          (json['studyTime'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      cardsReviewed:
          (json['cardsReviewed'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      quizAttempts:
          (json['quizAttempts'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      accuracy:
          (json['accuracy'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          [],
      xpEarned:
          (json['xpEarned'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          [],
    );
  }
}
