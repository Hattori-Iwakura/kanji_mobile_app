import '../../domain/entities/quiz.dart';
import 'question_model.dart';

class QuizModel extends Quiz {
  QuizModel({
    required super.id,
    required super.title,
    super.description,
    required super.isPublic,
    required super.userId,
    required super.createdAt,
    required super.updatedAt,
    super.questions,
    super.totalQuestions,
    super.totalPoints,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: (json['id'] as int?) ?? 0,
      title: (json['title'] as String?) ?? '',
      description: json['description'] as String?,
      isPublic: (json['isPublic'] as bool?) ?? false,
      userId: (json['userId'] as int?) ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      questions: json['questions'] != null
          ? (json['questions'] as List)
                .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
                .toList()
          : null,
      totalQuestions: json['totalQuestions'] as int?,
      totalPoints: json['totalPoints'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'isPublic': isPublic,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (questions != null)
        'questions': questions!
            .map((q) => (q as QuestionModel).toJson())
            .toList(),
      if (totalQuestions != null) 'totalQuestions': totalQuestions,
      if (totalPoints != null) 'totalPoints': totalPoints,
    };
  }
}
