import 'package:equatable/equatable.dart';
import 'quiz_answer.dart';

/// Entity representing quiz attempt result
class QuizResult extends Equatable {
  final String id;
  final String userId;
  final String quizId;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int skippedQuestions;
  final int totalPoints;
  final int earnedPoints;
  final double scorePercentage;
  final int timeSpent; // in seconds
  final bool isPassed;
  final List<QuizAnswer> answers;
  final DateTime completedAt;
  final DateTime createdAt;

  const QuizResult({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.skippedQuestions,
    required this.totalPoints,
    required this.earnedPoints,
    required this.scorePercentage,
    required this.timeSpent,
    required this.isPassed,
    required this.answers,
    required this.completedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    quizId,
    totalQuestions,
    correctAnswers,
    incorrectAnswers,
    skippedQuestions,
    totalPoints,
    earnedPoints,
    scorePercentage,
    timeSpent,
    isPassed,
    answers,
    completedAt,
    createdAt,
  ];

  /// Get accuracy percentage
  double get accuracy {
    if (totalQuestions == 0) return 0.0;
    return (correctAnswers / totalQuestions) * 100;
  }

  /// Get formatted time spent
  String get formattedTimeSpent {
    final minutes = timeSpent ~/ 60;
    final seconds = timeSpent % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get grade based on score
  String get grade {
    if (scorePercentage >= 90) return 'A+';
    if (scorePercentage >= 80) return 'A';
    if (scorePercentage >= 70) return 'B';
    if (scorePercentage >= 60) return 'C';
    if (scorePercentage >= 50) return 'D';
    return 'F';
  }

  /// Check if result is excellent (>=90%)
  bool get isExcellent => scorePercentage >= 90;

  /// Check if result is good (>=70%)
  bool get isGood => scorePercentage >= 70;

  /// Get performance message
  String get performanceMessage {
    if (scorePercentage >= 90) return 'Excellent! Outstanding performance!';
    if (scorePercentage >= 80) return 'Great job! Very good work!';
    if (scorePercentage >= 70) return 'Good work! Keep it up!';
    if (scorePercentage >= 60) return 'Fair performance. Keep practicing!';
    if (scorePercentage >= 50) return 'Needs improvement. Study more!';
    return 'Poor performance. Review the material!';
  }
}
