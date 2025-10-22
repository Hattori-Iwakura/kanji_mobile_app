import '../../domain/entities/quiz.dart';

/// Model for Quiz with JSON serialization
class QuizModel extends Quiz {
  const QuizModel({
    required super.id,
    required super.title,
    required super.description,
    required super.difficulty,
    required super.totalQuestions,
    required super.timeLimit,
    required super.passingScore,
    required super.isPublished,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create QuizModel from JSON
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as String,
      totalQuestions: json['totalQuestions'] as int,
      timeLimit: json['timeLimit'] as int,
      passingScore: json['passingScore'] as int,
      isPublished: json['isPublished'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert QuizModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'totalQuestions': totalQuestions,
      'timeLimit': timeLimit,
      'passingScore': passingScore,
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert Quiz entity to QuizModel
  factory QuizModel.fromEntity(Quiz quiz) {
    return QuizModel(
      id: quiz.id,
      title: quiz.title,
      description: quiz.description,
      difficulty: quiz.difficulty,
      totalQuestions: quiz.totalQuestions,
      timeLimit: quiz.timeLimit,
      passingScore: quiz.passingScore,
      isPublished: quiz.isPublished,
      createdAt: quiz.createdAt,
      updatedAt: quiz.updatedAt,
    );
  }
}
