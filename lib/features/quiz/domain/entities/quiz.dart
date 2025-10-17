import 'package:equatable/equatable.dart';
import 'quiz_enums.dart';
import 'question.dart';

class Quiz extends Equatable {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final QuizDifficulty difficulty;
  final String? category;
  final List<String> tags;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Question> questions;
  final int attemptsCount; // From _count.Attempts

  const Quiz({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.difficulty,
    this.category,
    required this.tags,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    required this.questions,
    required this.attemptsCount,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    difficulty,
    category,
    tags,
    isPublic,
    createdAt,
    updatedAt,
    questions,
    attemptsCount,
  ];

  Quiz copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    QuizDifficulty? difficulty,
    String? category,
    List<String>? tags,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Question>? questions,
    int? attemptsCount,
  }) {
    return Quiz(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      questions: questions ?? this.questions,
      attemptsCount: attemptsCount ?? this.attemptsCount,
    );
  }

  int get totalPoints => questions.fold(0, (sum, q) => sum + q.points);
  int get questionCount => questions.length;
}
