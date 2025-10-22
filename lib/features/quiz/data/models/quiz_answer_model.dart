import '../../domain/entities/quiz_answer.dart';

/// Model for QuizAnswer with JSON serialization
class QuizAnswerModel extends QuizAnswer {
  const QuizAnswerModel({
    required super.questionId,
    required super.userAnswer,
    required super.isCorrect,
    required super.pointsEarned,
    required super.answeredAt,
  });

  /// Create QuizAnswerModel from JSON
  factory QuizAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuizAnswerModel(
      questionId: json['questionId'] as String,
      userAnswer: json['userAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      pointsEarned: json['pointsEarned'] as int,
      answeredAt: DateTime.parse(json['answeredAt'] as String),
    );
  }

  /// Convert QuizAnswerModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
      'pointsEarned': pointsEarned,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  /// Convert QuizAnswer entity to QuizAnswerModel
  factory QuizAnswerModel.fromEntity(QuizAnswer answer) {
    return QuizAnswerModel(
      questionId: answer.questionId,
      userAnswer: answer.userAnswer,
      isCorrect: answer.isCorrect,
      pointsEarned: answer.pointsEarned,
      answeredAt: answer.answeredAt,
    );
  }
}
