import 'package:equatable/equatable.dart';

class QuizQuestionEntity extends Equatable {
  final int id;
  final int quizId;
  final int kanjiId;
  final String questionText;
  final String questionType; // 'multiple_choice', 'reading', etc.
  final List<String> options;
  final String correctAnswer;
  final int orderIndex;
  final DateTime createAt;
  final DateTime updateAt;

  const QuizQuestionEntity({
    required this.id,
    required this.quizId,
    required this.kanjiId,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.correctAnswer,
    required this.orderIndex,
    required this.createAt,
    required this.updateAt,
  });

  @override
  List<Object?> get props => [
    id,
    quizId,
    kanjiId,
    questionText,
    questionType,
    options,
    correctAnswer,
    orderIndex,
    createAt,
    updateAt,
  ];
}
