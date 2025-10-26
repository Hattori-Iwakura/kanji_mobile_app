import '../../domain/entities/achievement.dart';

class AchievementModel extends Achievement {
  const AchievementModel({
    required super.id,
    required super.name,
    required super.description,
    required super.icon,
    required super.category,
    required super.targetValue,
    required super.currentValue,
    required super.progress,
    required super.unlocked,
    required super.xpReward,
    super.unlockedAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String? ?? '🏆',
      category: json['category'] as String,
      targetValue: json['targetValue'] as int,
      currentValue: json['currentValue'] as int? ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      unlocked: json['unlocked'] as bool? ?? false,
      xpReward: json['xpReward'] as int? ?? 0,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'category': category,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'progress': progress,
      'unlocked': unlocked,
      'xpReward': xpReward,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }
}

class AchievementsOverviewModel extends AchievementsOverview {
  const AchievementsOverviewModel({
    required super.achievements,
    required super.totalAvailable,
    required super.totalUnlocked,
    required super.completionPercentage,
    required super.recentlyUnlocked,
  });

  factory AchievementsOverviewModel.fromJson(Map<String, dynamic> json) {
    return AchievementsOverviewModel(
      achievements:
          (json['achievements'] as List?)
              ?.map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalAvailable: json['totalAvailable'] as int? ?? 0,
      totalUnlocked: json['totalUnlocked'] as int? ?? 0,
      completionPercentage:
          (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
      recentlyUnlocked:
          (json['recentlyUnlocked'] as List?)
              ?.map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievements': achievements
          .map((e) => (e as AchievementModel).toJson())
          .toList(),
      'totalAvailable': totalAvailable,
      'totalUnlocked': totalUnlocked,
      'completionPercentage': completionPercentage,
      'recentlyUnlocked': recentlyUnlocked
          .map((e) => (e as AchievementModel).toJson())
          .toList(),
    };
  }
}
