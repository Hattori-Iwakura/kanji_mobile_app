enum QuizQuestionType { multipleChoice, fillInBlank, drawing }

extension QuizQuestionTypeExtension on QuizQuestionType {
  String get value {
    switch (this) {
      case QuizQuestionType.multipleChoice:
        return 'MULTIPLE_CHOICE';
      case QuizQuestionType.fillInBlank:
        return 'FILL_IN_BLANK';
      case QuizQuestionType.drawing:
        return 'DRAWING';
    }
  }

  static QuizQuestionType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'MULTIPLE_CHOICE':
        return QuizQuestionType.multipleChoice;
      case 'FILL_IN_BLANK':
        return QuizQuestionType.fillInBlank;
      case 'DRAWING':
        return QuizQuestionType.drawing;
      default:
        throw ArgumentError('Invalid QuizQuestionType: $value');
    }
  }
}

enum QuizDifficulty { beginner, intermediate, advanced, expert }

extension QuizDifficultyExtension on QuizDifficulty {
  String get value {
    switch (this) {
      case QuizDifficulty.beginner:
        return 'BEGINNER';
      case QuizDifficulty.intermediate:
        return 'INTERMEDIATE';
      case QuizDifficulty.advanced:
        return 'ADVANCED';
      case QuizDifficulty.expert:
        return 'EXPERT';
    }
  }

  String get label {
    switch (this) {
      case QuizDifficulty.beginner:
        return 'Beginner';
      case QuizDifficulty.intermediate:
        return 'Intermediate';
      case QuizDifficulty.advanced:
        return 'Advanced';
      case QuizDifficulty.expert:
        return 'Expert';
    }
  }

  static QuizDifficulty fromString(String value) {
    switch (value.toUpperCase()) {
      case 'BEGINNER':
        return QuizDifficulty.beginner;
      case 'INTERMEDIATE':
        return QuizDifficulty.intermediate;
      case 'ADVANCED':
        return QuizDifficulty.advanced;
      case 'EXPERT':
        return QuizDifficulty.expert;
      default:
        throw ArgumentError('Invalid QuizDifficulty: $value');
    }
  }
}
