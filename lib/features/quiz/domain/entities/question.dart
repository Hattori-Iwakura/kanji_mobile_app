import 'package:equatable/equatable.dart';
import 'quiz_enums.dart';

class Question extends Equatable {
  final int id;
  final int quizId;
  final QuizQuestionType type;
  final String question;
  final String? correctAnswer; // Null if user is not the quiz owner
  final Map<String, String>? options; // For multiple choice
  final Map<String, dynamic>? metadata;
  final int orderIndex;
  final int points;
  final int? timeLimit; // in seconds
  final String? explanation;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Question({
    required this.id,
    required this.quizId,
    required this.type,
    required this.question,
    this.correctAnswer,
    this.options,
    this.metadata,
    required this.orderIndex,
    required this.points,
    this.timeLimit,
    this.explanation,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    quizId,
    type,
    question,
    correctAnswer,
    options,
    metadata,
    orderIndex,
    points,
    timeLimit,
    explanation,
    createdAt,
    updatedAt,
  ];

  Question copyWith({
    int? id,
    int? quizId,
    QuizQuestionType? type,
    String? question,
    String? correctAnswer,
    Map<String, String>? options,
    Map<String, dynamic>? metadata,
    int? orderIndex,
    int? points,
    int? timeLimit,
    String? explanation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Question(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      type: type ?? this.type,
      question: question ?? this.question,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      metadata: metadata ?? this.metadata,
      orderIndex: orderIndex ?? this.orderIndex,
      points: points ?? this.points,
      timeLimit: timeLimit ?? this.timeLimit,
      explanation: explanation ?? this.explanation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
