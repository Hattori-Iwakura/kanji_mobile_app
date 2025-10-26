import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final int totalStudyTime;
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.avatarUrl,
    required this.role,
    required this.status,
    required this.createdAt,
    this.lastLoginAt,
    required this.totalStudyTime,
    required this.xp,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    username,
    fullName,
    avatarUrl,
    role,
    status,
    createdAt,
    lastLoginAt,
    totalStudyTime,
    xp,
    level,
    currentStreak,
    longestStreak,
  ];
}
