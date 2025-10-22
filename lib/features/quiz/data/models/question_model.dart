import '../../domain/entities/question.dart';

/// Model for Question with JSON serialization
class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.quizId,
    required super.type,
    required super.questionText,
    required super.options,
    required super.correctAnswer,
    super.explanation,
    required super.points,
    required super.orderIndex,
    required super.createdAt,
  });

  /// Create QuestionModel from JSON
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      quizId: json['quizId'] as String,
      type: json['type'] as String,
      questionText: json['questionText'] as String,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String?,
      points: json['points'] as int,
      orderIndex: json['orderIndex'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert QuestionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'type': type,
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'points': points,
      'orderIndex': orderIndex,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert Question entity to QuestionModel
  factory QuestionModel.fromEntity(Question question) {
    return QuestionModel(
      id: question.id,
      quizId: question.quizId,
      type: question.type,
      questionText: question.questionText,
      options: question.options,
      correctAnswer: question.correctAnswer,
      explanation: question.explanation,
      points: question.points,
      orderIndex: question.orderIndex,
      createdAt: question.createdAt,
    );
  }
}
