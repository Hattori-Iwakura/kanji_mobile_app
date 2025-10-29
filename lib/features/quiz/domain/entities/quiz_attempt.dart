import 'quiz.dart';
import 'quiz_answer.dart';

class QuizAttempt {
  final int id;
  final int userId;
  final int quizId;
  final int score;
  final int maxScore;
  final int correctAnswers;
  final int totalQuestions;
  final int timeSpent;
  final bool completed;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Quiz? quiz;
  final List<QuizAnswer>? answers;

  QuizAttempt({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.maxScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
    required this.completed,
    required this.createdAt,
    this.completedAt,
    this.quiz,
    this.answers,
  });

  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0;

  String get percentageText => '${percentage.toStringAsFixed(1)}%';

  QuizAttempt copyWith({
    int? id,
    int? userId,
    int? quizId,
    int? score,
    int? maxScore,
    int? correctAnswers,
    int? totalQuestions,
    int? timeSpent,
    bool? completed,
    DateTime? createdAt,
    DateTime? completedAt,
    Quiz? quiz,
    List<QuizAnswer>? answers,
  }) {
    return QuizAttempt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      quizId: quizId ?? this.quizId,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      timeSpent: timeSpent ?? this.timeSpent,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      quiz: quiz ?? this.quiz,
      answers: answers ?? this.answers,
    );
  }
}
