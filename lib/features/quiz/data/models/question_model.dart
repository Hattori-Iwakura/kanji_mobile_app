import '../../domain/entities/quiz_enums.dart';
import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.quizId,
    required super.type,
    required super.question,
    super.correctAnswer,
    super.options,
    super.metadata,
    required super.orderIndex,
    required super.points,
    super.timeLimit,
    super.explanation,
    required super.createdAt,
    required super.updatedAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    // Handle partial data (e.g., from quiz list endpoint which only returns id, type, order_index)
    return QuestionModel(
      id: json['id'] as int,
      quizId: json['quiz_id'] as int? ?? 0, // Default for partial data
      type: QuizQuestionTypeExtension.fromString(json['type'] as String),
      question: json['question'] as String? ?? '', // Default for partial data
      correctAnswer: json['correct_answer'] as String?,
      options: json['options'] != null
          ? Map<String, String>.from(json['options'] as Map)
          : null,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      orderIndex: json['order_index'] as int,
      points: json['points'] as int? ?? 0, // Default for partial data
      timeLimit: json['time_limit'] as int?,
      explanation: json['explanation'] as String?,
      createdAt: json['create_at'] != null
          ? DateTime.parse(json['create_at'] as String)
          : DateTime.now(), // Default for partial data
      updatedAt: json['update_at'] != null
          ? DateTime.parse(json['update_at'] as String)
          : DateTime.now(), // Default for partial data
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'type': type.value,
      'question': question,
      'correct_answer': correctAnswer,
      'options': options,
      'metadata': metadata,
      'order_index': orderIndex,
      'points': points,
      'time_limit': timeLimit,
      'explanation': explanation,
      'create_at': createdAt.toIso8601String(),
      'update_at': updatedAt.toIso8601String(),
    };
  }

  Question toEntity() => this;
}
