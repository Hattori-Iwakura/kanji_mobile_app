import '../../domain/entities/quiz_answer.dart';
import 'question_model.dart';

class QuizAnswerModel extends QuizAnswer {
  QuizAnswerModel({
    required super.id,
    required super.attemptId,
    required super.questionId,
    required super.userAnswer,
    required super.isCorrect,
    required super.points,
    required super.createdAt,
    super.question,
  });

  factory QuizAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuizAnswerModel(
      id: (json['id'] as int?) ?? 0,
      attemptId: (json['attemptId'] as int?) ?? 0,
      questionId: (json['questionId'] as int?) ?? 0,
      userAnswer: (json['userAnswer'] as String?) ?? '',
      isCorrect: (json['isCorrect'] as bool?) ?? false,
      points: (json['points'] as int?) ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      question: json['question'] != null
          ? QuestionModel.fromJson(json['question'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attemptId': attemptId,
      'questionId': questionId,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
      'points': points,
      'createdAt': createdAt.toIso8601String(),
      if (question != null) 'question': (question as QuestionModel).toJson(),
    };
  }
}
