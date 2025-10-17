import 'package:equatable/equatable.dart';

class QuizAnswer extends Equatable {
  final int id;
  final int attemptId;
  final int questionId;
  final String userAnswer;
  final bool isCorrect;
  final int points;
  final int timeSpent; // in seconds
  final Map<String, dynamic>? metadata;
  final DateTime answeredAt;

  const QuizAnswer({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.userAnswer,
    required this.isCorrect,
    required this.points,
    required this.timeSpent,
    this.metadata,
    required this.answeredAt,
  });

  @override
  List<Object?> get props => [
    id,
    attemptId,
    questionId,
    userAnswer,
    isCorrect,
    points,
    timeSpent,
    metadata,
    answeredAt,
  ];

  QuizAnswer copyWith({
    int? id,
    int? attemptId,
    int? questionId,
    String? userAnswer,
    bool? isCorrect,
    int? points,
    int? timeSpent,
    Map<String, dynamic>? metadata,
    DateTime? answeredAt,
  }) {
    return QuizAnswer(
      id: id ?? this.id,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      points: points ?? this.points,
      timeSpent: timeSpent ?? this.timeSpent,
      metadata: metadata ?? this.metadata,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }
}
