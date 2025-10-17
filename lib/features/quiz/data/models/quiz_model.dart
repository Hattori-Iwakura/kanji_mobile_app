import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_enums.dart';
import 'question_model.dart';

class QuizModel extends Quiz {
  const QuizModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    required super.difficulty,
    super.category,
    required super.tags,
    required super.isPublic,
    required super.createdAt,
    required super.updatedAt,
    required super.questions,
    required super.attemptsCount,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      difficulty: QuizDifficultyExtension.fromString(
        json['difficulty'] as String,
      ),
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isPublic: json['is_public'] as bool,
      createdAt: DateTime.parse(json['create_at'] as String),
      updatedAt: DateTime.parse(json['update_at'] as String),
      questions:
          (json['Questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      attemptsCount: _parseAttemptsCount(json),
    );
  }

  static int _parseAttemptsCount(Map<String, dynamic> json) {
    try {
      final countData = json['_count'];
      if (countData == null) return 0;
      if (countData is Map<String, dynamic>) {
        final attempts = countData['Attempts'];
        if (attempts == null) return 0;
        if (attempts is int) return attempts;
        if (attempts is String) return int.tryParse(attempts) ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'difficulty': difficulty.value,
      'category': category,
      'tags': tags,
      'is_public': isPublic,
      'create_at': createdAt.toIso8601String(),
      'update_at': updatedAt.toIso8601String(),
      'Questions': questions.map((q) => (q as QuestionModel).toJson()).toList(),
      '_count': {'Attempts': attemptsCount},
    };
  }

  Quiz toEntity() => this;
}
