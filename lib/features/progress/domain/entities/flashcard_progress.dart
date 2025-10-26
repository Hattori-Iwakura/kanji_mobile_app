import 'package:equatable/equatable.dart';

/// Entity representing flashcard study progress
class FlashcardProgress extends Equatable {
  final int totalSessions;
  final int totalStudyTime; // in minutes
  final String period; // '7d', '30d', '90d', '1y'

  const FlashcardProgress({
    required this.totalSessions,
    required this.totalStudyTime,
    required this.period,
  });

  @override
  List<Object?> get props => [totalSessions, totalStudyTime, period];
}
