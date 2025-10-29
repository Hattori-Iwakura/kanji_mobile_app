import '../../domain/entities/quiz_attempt.dart';
import 'quiz_model.dart';
import 'quiz_answer_model.dart';

class QuizAttemptModel extends QuizAttempt {
  QuizAttemptModel({
    required super.id,
    required super.userId,
    required super.quizId,
    required super.score,
    required super.maxScore,
    required super.correctAnswers,
    required super.totalQuestions,
    required super.timeSpent,
    required super.completed,
    required super.createdAt,
    super.completedAt,
    super.quiz,
    super.answers,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      id: (json['id'] as int?) ?? 0,
      userId: (json['userId'] as int?) ?? 0,
      quizId: (json['quizId'] as int?) ?? 0,
      score: (json['score'] as int?) ?? 0,
      maxScore: (json['maxScore'] as int?) ?? 0,
      correctAnswers: (json['correctAnswers'] as int?) ?? 0,
      totalQuestions: (json['totalQuestions'] as int?) ?? 0,
      timeSpent: (json['timeSpent'] as int?) ?? 0,
      completed: (json['completed'] as bool?) ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      quiz: json['quiz'] != null
          ? QuizModel.fromJson(json['quiz'] as Map<String, dynamic>)
          : null,
      answers: json['answers'] != null
          ? (json['answers'] as List)
                .map((a) => QuizAnswerModel.fromJson(a as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'quizId': quizId,
      'score': score,
      'maxScore': maxScore,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timeSpent': timeSpent,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      if (quiz != null) 'quiz': (quiz as QuizModel).toJson(),
      if (answers != null)
        'answers': answers!
            .map((a) => (a as QuizAnswerModel).toJson())
            .toList(),
    };
  }
}
