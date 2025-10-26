import 'package:equatable/equatable.dart';

/// Entity representing user's study streak
class Streak extends Equatable {
  final int currentStreak;
  final int longestStreak;

  const Streak({required this.currentStreak, required this.longestStreak});

  @override
  List<Object?> get props => [currentStreak, longestStreak];
}
