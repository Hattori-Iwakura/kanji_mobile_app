enum QuestionType { multipleChoice, fillBlank, drawing }

class Question {
  final int id;
  final int quizId;
  final QuestionType type;
  final String questionText;
  final String correctAnswer;
  final List<String>? options;
  final String? explanation;
  final int points;
  final List<String>? meanings;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  Question({
    required this.id,
    required this.quizId,
    required this.type,
    required this.questionText,
    required this.correctAnswer,
    this.options,
    this.explanation,
    required this.points,
    this.meanings,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  Question copyWith({
    int? id,
    int? quizId,
    QuestionType? type,
    String? questionText,
    String? correctAnswer,
    List<String>? options,
    String? explanation,
    int? points,
    List<String>? meanings,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Question(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      type: type ?? this.type,
      questionText: questionText ?? this.questionText,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      explanation: explanation ?? this.explanation,
      points: points ?? this.points,
      meanings: meanings ?? this.meanings,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
