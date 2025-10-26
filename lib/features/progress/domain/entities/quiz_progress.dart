import 'package:equatable/equatable.dart';

/// Entity representing quiz attempt progress
class QuizProgress extends Equatable {
  final int totalAttempts;
  final double bestScore;
  final String period; // '7d', '30d', '90d', '1y'

  const QuizProgress({
    required this.totalAttempts,
    required this.bestScore,
    required this.period,
  });

  @override
  List<Object?> get props => [totalAttempts, bestScore, period];
}
