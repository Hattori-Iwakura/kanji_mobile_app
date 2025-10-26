import 'package:equatable/equatable.dart';

/// Entity representing a quiz question
class Question extends Equatable {
  final String id;
  final String quizId;
  final String type; // MULTIPLE_CHOICE, TRUE_FALSE, FILL_IN_BLANK, DRAWING
  final String questionText;
  final List<String> options; // For multiple choice, empty for others
  final String correctAnswer;
  final String? explanation;
  final int points;
  final int orderIndex;
  final DateTime createdAt;
  final List<String> meanings; // For DRAWING type - kanji meanings

  const Question({
    required this.id,
    required this.quizId,
    required this.type,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.points,
    required this.orderIndex,
    required this.createdAt,
    this.meanings = const [],
  });

  @override
  List<Object?> get props => [
    id,
    quizId,
    type,
    questionText,
    options,
    correctAnswer,
    explanation,
    points,
    orderIndex,
    createdAt,
    meanings,
  ];

  /// Check if question is multiple choice
  bool get isMultipleChoice => type == 'MULTIPLE_CHOICE';

  /// Check if question is true/false
  bool get isTrueFalse => type == 'TRUE_FALSE';

  /// Check if question is fill in blank
  bool get isFillInBlank => type == 'FILL_IN_BLANK';

  /// Check if question is drawing
  bool get isDrawing => type == 'DRAWING';

  /// Get question type display name
  String get typeDisplayName {
    switch (type) {
      case 'MULTIPLE_CHOICE':
        return 'Multiple Choice';
      case 'TRUE_FALSE':
        return 'True/False';
      case 'FILL_IN_BLANK':
        return 'Fill in Blank';
      case 'DRAWING':
        return 'Draw Kanji';
      default:
        return type;
    }
  }
}
