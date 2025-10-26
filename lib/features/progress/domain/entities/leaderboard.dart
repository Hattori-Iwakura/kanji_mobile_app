import 'package:equatable/equatable.dart';

/// Entity representing leaderboard entry
class LeaderboardEntry extends Equatable {
  final int rank;
  final int userId;
  final String username;
  final int xp;
  final int level;
  final int score;
  final int streak;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.xp,
    required this.level,
    required this.score,
    required this.streak,
    required this.isCurrentUser,
  });

  @override
  List<Object?> get props => [
    rank,
    userId,
    username,
    xp,
    level,
    score,
    streak,
    isCurrentUser,
  ];
}

/// Entity representing full leaderboard response
class Leaderboard extends Equatable {
  final List<LeaderboardEntry> entries;
  final int totalUsers;
  final LeaderboardEntry? currentUser;
  final int? currentUserRank;
  final String period; // 'week', 'month', 'all'
  final String type; // 'xp', 'streak'

  const Leaderboard({
    required this.entries,
    required this.totalUsers,
    this.currentUser,
    this.currentUserRank,
    required this.period,
    required this.type,
  });

  @override
  List<Object?> get props => [
    entries,
    totalUsers,
    currentUser,
    currentUserRank,
    period,
    type,
  ];
}
