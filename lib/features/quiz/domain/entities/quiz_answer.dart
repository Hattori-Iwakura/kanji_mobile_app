import 'package:equatable/equatable.dart';

/// Entity representing user's answer to a question
class QuizAnswer extends Equatable {
  final String questionId;
  final String userAnswer;
  final bool isCorrect;
  final int pointsEarned;
  final DateTime answeredAt;

  const QuizAnswer({
    required this.questionId,
    required this.userAnswer,
    required this.isCorrect,
    required this.pointsEarned,
    required this.answeredAt,
  });

  @override
  List<Object?> get props => [
    questionId,
    userAnswer,
    isCorrect,
    pointsEarned,
    answeredAt,
  ];
}
