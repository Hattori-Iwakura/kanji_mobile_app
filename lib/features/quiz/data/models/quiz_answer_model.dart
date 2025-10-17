import '../../domain/entities/quiz_answer.dart';

class QuizAnswerModel extends QuizAnswer {
  const QuizAnswerModel({
    required super.id,
    required super.attemptId,
    required super.questionId,
    required super.userAnswer,
    required super.isCorrect,
    required super.points,
    required super.timeSpent,
    super.metadata,
    required super.answeredAt,
  });

  factory QuizAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuizAnswerModel(
      id: json['id'] as int,
      attemptId: json['attempt_id'] as int,
      questionId: json['question_id'] as int,
      userAnswer: json['user_answer'] as String,
      isCorrect: json['is_correct'] as bool,
      points: json['points'] as int,
      timeSpent: json['time_spent'] as int,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      answeredAt: DateTime.parse(json['answered_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attempt_id': attemptId,
      'question_id': questionId,
      'user_answer': userAnswer,
      'is_correct': isCorrect,
      'points': points,
      'time_spent': timeSpent,
      'metadata': metadata,
      'answered_at': answeredAt.toIso8601String(),
    };
  }

  QuizAnswer toEntity() => this;
}
