import '../../domain/entities/quiz_question_entity.dart';

enum QuestionType {
  multipleChoice('MULTIPLE_CHOICE'),
  fillInBlank('FILL_IN_BLANK'),
  trueFalse('TRUE_FALSE'),
  matching('MATCHING');

  final String value;
  const QuestionType(this.value);

  static QuestionType fromString(String value) {
    return QuestionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => QuestionType.multipleChoice,
    );
  }
}

class QuizQuestion extends QuizQuestionEntity {
  final QuestionType type;

  const QuizQuestion({
    required super.id,
    required super.quizId,
    required super.kanjiId,
    required super.questionText,
    required super.questionType,
    required super.options,
    required super.correctAnswer,
    required super.orderIndex,
    required super.createAt,
    required super.updateAt,
    required this.type,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final questionType = QuestionType.fromString(
      json['questionType'] as String,
    );
    return QuizQuestion(
      id: json['id'] as int,
      quizId: json['quizId'] as int,
      kanjiId: json['kanjiId'] as int,
      questionText: json['questionText'] as String,
      questionType: json['questionType'] as String,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : [],
      correctAnswer: json['correctAnswer'] as String,
      orderIndex: json['orderIndex'] as int? ?? json['order'] as int? ?? 0,
      createAt: DateTime.parse(json['createdAt'] as String),
      updateAt: DateTime.parse(json['updatedAt'] as String),
      type: questionType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'kanjiId': kanjiId,
      'questionText': questionText,
      'questionType': questionType,
      'correctAnswer': correctAnswer,
      'options': options,
      'orderIndex': orderIndex,
      'createdAt': createAt.toIso8601String(),
      'updatedAt': updateAt.toIso8601String(),
    };
  }

  QuizQuestionEntity toEntity() {
    return QuizQuestionEntity(
      id: id,
      quizId: quizId,
      kanjiId: kanjiId,
      questionText: questionText,
      questionType: questionType,
      options: options,
      correctAnswer: correctAnswer,
      orderIndex: orderIndex,
      createAt: createAt,
      updateAt: updateAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, type];
}
