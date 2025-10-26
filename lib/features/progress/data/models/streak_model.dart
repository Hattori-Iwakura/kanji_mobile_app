import '../../domain/entities/streak.dart';

class StreakModel extends Streak {
  const StreakModel({
    required super.currentStreak,
    required super.longestStreak,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'currentStreak': currentStreak, 'longestStreak': longestStreak};
  }
}
