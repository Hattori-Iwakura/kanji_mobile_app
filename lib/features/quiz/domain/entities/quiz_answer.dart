import 'question.dart';

class QuizAnswer {
  final int id;
  final int attemptId;
  final int questionId;
  final String userAnswer;
  final bool isCorrect;
  final int points;
  final DateTime createdAt;
  final Question? question;

  QuizAnswer({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.userAnswer,
    required this.isCorrect,
    required this.points,
    required this.createdAt,
    this.question,
  });

  QuizAnswer copyWith({
    int? id,
    int? attemptId,
    int? questionId,
    String? userAnswer,
    bool? isCorrect,
    int? points,
    DateTime? createdAt,
    Question? question,
  }) {
    return QuizAnswer(
      id: id ?? this.id,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      question: question ?? this.question,
    );
  }
}
