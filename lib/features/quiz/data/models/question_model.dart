import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  QuestionModel({
    required super.id,
    required super.quizId,
    required super.type,
    required super.questionText,
    required super.correctAnswer,
    super.options,
    super.explanation,
    required super.points,
    super.meanings,
    required super.order,
    required super.createdAt,
    required super.updatedAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: (json['id'] as int?) ?? 0,
      quizId: (json['quizId'] as int?) ?? 0,
      type: _parseQuestionType(json['type'] as String?),
      questionText: (json['questionText'] as String?) ?? '',
      correctAnswer: (json['correctAnswer'] as String?) ?? '',
      options: json['options'] != null ? _parseOptions(json['options']) : null,
      explanation: json['explanation'] as String?,
      points: (json['points'] as int?) ?? 10,
      meanings: json['meanings'] != null
          ? List<String>.from(json['meanings'] as List)
          : null,
      order: (json['order'] as int?) ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'type': _questionTypeToString(type),
      'questionText': questionText,
      'correctAnswer': correctAnswer,
      if (options != null) 'options': options,
      if (explanation != null) 'explanation': explanation,
      'points': points,
      if (meanings != null) 'meanings': meanings,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static QuestionType _parseQuestionType(String? type) {
    switch (type) {
      case 'MULTIPLE_CHOICE':
        return QuestionType.multipleChoice;
      case 'TRUE_FALSE':
        return QuestionType.fillBlank; // TRUE_FALSE mapped to fillBlank for now
      case 'FILL_IN_BLANK':
        return QuestionType.fillBlank;
      case 'DRAWING':
        return QuestionType.drawing;
      default:
        return QuestionType.fillBlank;
    }
  }

  static List<String>? _parseOptions(dynamic options) {
    if (options == null) return null;

    // If options is a Map with 'choices' key (backend format)
    if (options is Map<String, dynamic> && options.containsKey('choices')) {
      final choices = options['choices'];
      if (choices is List) {
        return List<String>.from(choices);
      }
    }

    // If options is already a List (legacy format or direct format)
    if (options is List) {
      return List<String>.from(options);
    }

    return null;
  }

  static String _questionTypeToString(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'MULTIPLE_CHOICE';
      case QuestionType.fillBlank:
        return 'FILL_IN_BLANK';
      case QuestionType.drawing:
        return 'DRAWING';
    }
  }
}
