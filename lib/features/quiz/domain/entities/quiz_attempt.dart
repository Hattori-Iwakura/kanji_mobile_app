import 'package:equatable/equatable.dart';
import 'quiz.dart';
import 'quiz_answer.dart';

class QuizAttempt extends Equatable {
  final int id;
  final int userId;
  final int quizId;
  final int score;
  final int maxScore;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int timeSpent; // in seconds
  final bool isCompleted;
  final Quiz? quiz; // Included in some responses
  final List<QuizAnswer> answers;

  const QuizAttempt({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.maxScore,
    required this.startedAt,
    this.completedAt,
    required this.timeSpent,
    required this.isCompleted,
    this.quiz,
    required this.answers,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    quizId,
    score,
    maxScore,
    startedAt,
    completedAt,
    timeSpent,
    isCompleted,
    quiz,
    answers,
  ];

  QuizAttempt copyWith({
    int? id,
    int? userId,
    int? quizId,
    int? score,
    int? maxScore,
    DateTime? startedAt,
    DateTime? completedAt,
    int? timeSpent,
    bool? isCompleted,
    Quiz? quiz,
    List<QuizAnswer>? answers,
  }) {
    return QuizAttempt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      quizId: quizId ?? this.quizId,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      timeSpent: timeSpent ?? this.timeSpent,
      isCompleted: isCompleted ?? this.isCompleted,
      quiz: quiz ?? this.quiz,
      answers: answers ?? this.answers,
    );
  }

  double get scorePercentage => maxScore > 0 ? (score / maxScore) * 100 : 0;
  int get correctAnswersCount => answers.where((a) => a.isCorrect).length;
  int get wrongAnswersCount => answers.where((a) => !a.isCorrect).length;
}
