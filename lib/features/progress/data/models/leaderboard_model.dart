import '../../domain/entities/leaderboard.dart';

class LeaderboardEntryModel extends LeaderboardEntry {
  const LeaderboardEntryModel({
    required super.rank,
    required super.userId,
    required super.username,
    required super.xp,
    required super.level,
    required super.score,
    required super.streak,
    required super.isCurrentUser,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: json['rank'] as int,
      userId: json['userId'] as int,
      username: json['username'] as String,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      score: json['score'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'userId': userId,
      'username': username,
      'xp': xp,
      'level': level,
      'score': score,
      'streak': streak,
      'isCurrentUser': isCurrentUser,
    };
  }
}

class LeaderboardModel extends Leaderboard {
  const LeaderboardModel({
    required super.entries,
    required super.totalUsers,
    super.currentUser,
    super.currentUserRank,
    required super.period,
    required super.type,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      entries:
          (json['entries'] as List?)
              ?.map(
                (e) =>
                    LeaderboardEntryModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      totalUsers: json['totalUsers'] as int? ?? 0,
      currentUser: json['currentUser'] != null
          ? LeaderboardEntryModel.fromJson(
              json['currentUser'] as Map<String, dynamic>,
            )
          : null,
      currentUserRank: json['currentUserRank'] as int?,
      period: json['period'] as String? ?? 'week',
      type: json['type'] as String? ?? 'xp',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entries': entries
          .map((e) => (e as LeaderboardEntryModel).toJson())
          .toList(),
      'totalUsers': totalUsers,
      'currentUser': currentUser != null
          ? (currentUser as LeaderboardEntryModel).toJson()
          : null,
      'currentUserRank': currentUserRank,
      'period': period,
      'type': type,
    };
  }
}
