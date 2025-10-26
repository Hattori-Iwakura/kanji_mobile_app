import 'package:equatable/equatable.dart';

/// Entity representing a single achievement
class Achievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;
  final int targetValue;
  final int currentValue;
  final double progress; // 0-100
  final bool unlocked;
  final int xpReward;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.targetValue,
    required this.currentValue,
    required this.progress,
    required this.unlocked,
    required this.xpReward,
    this.unlockedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    icon,
    category,
    targetValue,
    currentValue,
    progress,
    unlocked,
    xpReward,
    unlockedAt,
  ];
}

/// Entity representing achievements overview
class AchievementsOverview extends Equatable {
  final List<Achievement> achievements;
  final int totalAvailable;
  final int totalUnlocked;
  final double completionPercentage;
  final List<Achievement> recentlyUnlocked;

  const AchievementsOverview({
    required this.achievements,
    required this.totalAvailable,
    required this.totalUnlocked,
    required this.completionPercentage,
    required this.recentlyUnlocked,
  });

  @override
  List<Object?> get props => [
    achievements,
    totalAvailable,
    totalUnlocked,
    completionPercentage,
    recentlyUnlocked,
  ];
}
