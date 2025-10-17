import '../../domain/entities/quiz_attempt.dart';
import 'quiz_model.dart';
import 'quiz_answer_model.dart';

class QuizAttemptModel extends QuizAttempt {
  const QuizAttemptModel({
    required super.id,
    required super.userId,
    required super.quizId,
    required super.score,
    required super.maxScore,
    required super.startedAt,
    super.completedAt,
    required super.timeSpent,
    required super.isCompleted,
    super.quiz,
    required super.answers,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      quizId: json['quiz_id'] as int,
      score: json['score'] as int,
      maxScore: json['max_score'] as int,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      timeSpent: json['time_spent'] as int,
      isCompleted: json['is_completed'] as bool,
      quiz: json['Quiz'] != null
          ? QuizModel.fromJson(json['Quiz'] as Map<String, dynamic>)
          : null,
      answers:
          (json['Answers'] as List<dynamic>?)
              ?.map((a) => QuizAnswerModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quiz_id': quizId,
      'score': score,
      'max_score': maxScore,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'time_spent': timeSpent,
      'is_completed': isCompleted,
      'Quiz': quiz != null ? (quiz as QuizModel).toJson() : null,
      'Answers': answers.map((a) => (a as QuizAnswerModel).toJson()).toList(),
    };
  }

  QuizAttempt toEntity() => this;
}
