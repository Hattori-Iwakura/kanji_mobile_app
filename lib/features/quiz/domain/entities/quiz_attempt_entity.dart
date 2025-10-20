import 'package:equatable/equatable.dart';

class QuizAttemptEntity extends Equatable {
  final int id;
  final int quizId;
  final int userId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String status; // 'in_progress', 'completed'

  const QuizAttemptEntity({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.startedAt,
    this.completedAt,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    quizId,
    userId,
    score,
    totalQuestions,
    correctAnswers,
    startedAt,
    completedAt,
    status,
  ];
}
