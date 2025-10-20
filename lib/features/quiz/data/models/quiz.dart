import '../../domain/entities/quiz_entity.dart';
import 'quiz_question.dart';

class Quiz extends QuizEntity {
  final List<QuizQuestion>? questions;

  const Quiz({
    required super.id,
    required super.title,
    super.description,
    required super.userId,
    required super.isPublic,
    required super.totalQuestions,
    required super.createAt,
    required super.updateAt,
    this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      userId: json['userId'] as int,
      isPublic: json['isPublic'] as bool? ?? false,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      createAt: DateTime.parse(json['createdAt'] as String),
      updateAt: DateTime.parse(json['updatedAt'] as String),
      questions: json['questions'] != null
          ? (json['questions'] as List)
                .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'isPublic': isPublic,
      'totalQuestions': totalQuestions,
      'createdAt': createAt.toIso8601String(),
      'updatedAt': updateAt.toIso8601String(),
      if (questions != null)
        'questions': questions!.map((q) => q.toJson()).toList(),
    };
  }

  QuizEntity toEntity() {
    return QuizEntity(
      id: id,
      title: title,
      description: description,
      userId: userId,
      isPublic: isPublic,
      totalQuestions: totalQuestions,
      createAt: createAt,
      updateAt: updateAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, questions];
}
