import 'question.dart';

enum QuizQuestionType { multipleChoice, fillBlank, drawing }

class Quiz {
  final int id;
  final String title;
  final String? description;
  final bool isPublic;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Question>? questions;
  final int? totalQuestions;
  final int? totalPoints;

  Quiz({
    required this.id,
    required this.title,
    this.description,
    required this.isPublic,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.questions,
    this.totalQuestions,
    this.totalPoints,
  });

  Quiz copyWith({
    int? id,
    String? title,
    String? description,
    bool? isPublic,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Question>? questions,
    int? totalQuestions,
    int? totalPoints,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      questions: questions ?? this.questions,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}
