import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/quiz/data/models/question_model.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/question.dart';
import '../../../helpers/fixtures/quiz_fixtures.dart';

void main() {
  group('QuestionModel', () {
    group('fromJson', () {
      test('should parse MULTIPLE_CHOICE question from JSON', () {
        // Arrange
        final json = {
          'id': '1',
          'quizId': '1',
          'type': 'MULTIPLE_CHOICE',
          'questionText': 'What does 日 mean?',
          'options': ['sun', 'moon', 'fire', 'water'],
          'correctAnswer': 'sun',
          'explanation': '日 (にち/ひ) means sun or day',
          'points': 10,
          'orderIndex': 0,
          'createdAt': '2024-01-01T00:00:00.000',
          'meanings': [],
        };

        // Act
        final result = QuestionModel.fromJson(json);

        // Assert
        expect(result, isA<Question>());
        expect(result.id, '1');
        expect(result.type, 'MULTIPLE_CHOICE');
        expect(result.options.length, 4);
        expect(result.meanings.isEmpty, true);
      });

      test('should parse TRUE_FALSE question from JSON', () {
        // Arrange
        final json = {
          'id': '3',
          'quizId': '1',
          'type': 'TRUE_FALSE',
          'questionText': '火 means water',
          'options': ['True', 'False'],
          'correctAnswer': 'False',
          'explanation': '火 means fire, not water',
          'points': 10,
          'orderIndex': 2,
          'createdAt': '2024-01-01T00:00:00.000',
          'meanings': [],
        };

        // Act
        final result = QuestionModel.fromJson(json);

        // Assert
        expect(result.type, 'TRUE_FALSE');
        expect(result.options.length, 2);
        expect(result.correctAnswer, 'False');
      });

      test('should parse FILL_IN_BLANK question from JSON', () {
        // Arrange
        final json = {
          'id': '5',
          'quizId': '1',
          'type': 'FILL_IN_BLANK',
          'questionText': 'The kanji for water is ___',
          'options': [],
          'correctAnswer': '水',
          'explanation': '水 (みず) means water',
          'points': 15,
          'orderIndex': 4,
          'createdAt': '2024-01-01T00:00:00.000',
          'meanings': [],
        };

        // Act
        final result = QuestionModel.fromJson(json);

        // Assert
        expect(result.type, 'FILL_IN_BLANK');
        expect(result.options.isEmpty, true);
        expect(result.correctAnswer, '水');
      });

      test('should parse DRAWING question from JSON with meanings', () {
        // Arrange
        final json = {
          'id': '7',
          'quizId': '3',
          'type': 'DRAWING',
          'questionText': 'Draw the kanji for: sun, day',
          'options': [],
          'correctAnswer': '日',
          'explanation': 'Draw the kanji 日',
          'points': 20,
          'orderIndex': 0,
          'createdAt': '2024-01-03T00:00:00.000',
          'meanings': ['sun', 'day'],
        };

        // Act
        final result = QuestionModel.fromJson(json);

        // Assert
        expect(result.type, 'DRAWING');
        expect(result.meanings.length, 2);
        expect(result.meanings, ['sun', 'day']);
        expect(result.options.isEmpty, true);
      });

      test('should handle null explanation', () {
        // Arrange
        final json = {
          'id': '1',
          'quizId': '1',
          'type': 'MULTIPLE_CHOICE',
          'questionText': 'Test question',
          'options': ['A', 'B'],
          'correctAnswer': 'A',
          'explanation': null,
          'points': 10,
          'orderIndex': 0,
          'createdAt': '2024-01-01T00:00:00.000',
          'meanings': [],
        };

        // Act
        final result = QuestionModel.fromJson(json);

        // Assert
        expect(result.explanation, null);
      });

      test('should handle missing meanings field', () {
        // Arrange
        final json = {
          'id': '1',
          'quizId': '1',
          'type': 'MULTIPLE_CHOICE',
          'questionText': 'Test question',
          'options': ['A', 'B'],
          'correctAnswer': 'A',
          'points': 10,
          'orderIndex': 0,
          'createdAt': '2024-01-01T00:00:00.000',
          // No meanings field
        };

        // Act
        final result = QuestionModel.fromJson(json);

        // Assert
        expect(result.meanings, []);
      });

      test('should parse DateTime correctly', () {
        // Arrange
        final json = {
          'id': '1',
          'quizId': '1',
          'type': 'MULTIPLE_CHOICE',
          'questionText': 'Test',
          'options': [],
          'correctAnswer': 'A',
          'points': 10,
          'orderIndex': 0,
          'createdAt': '2024-01-01T12:30:45.000',
          'meanings': [],
        };

        // Act
        final result = QuestionModel.fromJson(json);

        // Assert
        expect(result.createdAt, DateTime(2024, 1, 1, 12, 30, 45));
      });
    });

    group('toJson', () {
      test('should convert MULTIPLE_CHOICE question to JSON', () {
        // Arrange
        final model = QuestionModel(
          id: '1',
          quizId: '1',
          type: 'MULTIPLE_CHOICE',
          questionText: 'What does 日 mean?',
          options: ['sun', 'moon', 'fire', 'water'],
          correctAnswer: 'sun',
          explanation: '日 (にち/ひ) means sun or day',
          points: 10,
          orderIndex: 0,
          createdAt: DateTime(2024, 1, 1),
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], '1');
        expect(json['type'], 'MULTIPLE_CHOICE');
        expect(json['options'], ['sun', 'moon', 'fire', 'water']);
        expect(json['createdAt'], '2024-01-01T00:00:00.000');
        expect(json['meanings'], []);
      });

      test('should convert DRAWING question with meanings to JSON', () {
        // Arrange
        final model = QuestionModel(
          id: '7',
          quizId: '3',
          type: 'DRAWING',
          questionText: 'Draw the kanji for: sun, day',
          options: [],
          correctAnswer: '日',
          explanation: 'Draw the kanji 日',
          points: 20,
          orderIndex: 0,
          createdAt: DateTime(2024, 1, 3),
          meanings: ['sun', 'day'],
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['type'], 'DRAWING');
        expect(json['meanings'], ['sun', 'day']);
        expect(json['options'], []);
      });

      test('should include null explanation in JSON', () {
        // Arrange
        final model = QuestionModel(
          id: '1',
          quizId: '1',
          type: 'TRUE_FALSE',
          questionText: 'Test',
          options: ['True', 'False'],
          correctAnswer: 'True',
          explanation: null,
          points: 10,
          orderIndex: 0,
          createdAt: DateTime(2024, 1, 1),
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['explanation'], null);
      });

      test('should convert all fields correctly', () {
        // Arrange
        final model = QuestionModel(
          id: 'test-id',
          quizId: 'quiz-id',
          type: 'FILL_IN_BLANK',
          questionText: 'Fill ___ blank',
          options: [],
          correctAnswer: 'the',
          explanation: 'Test explanation',
          points: 15,
          orderIndex: 5,
          createdAt: DateTime(2024, 2, 15, 10, 30),
          meanings: [],
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'test-id');
        expect(json['quizId'], 'quiz-id');
        expect(json['questionText'], 'Fill ___ blank');
        expect(json['points'], 15);
        expect(json['orderIndex'], 5);
      });
    });

    group('fromEntity', () {
      test('should create QuestionModel from Question entity', () {
        // Arrange
        final entity = tQuestionMultipleChoice1;

        // Act
        final model = QuestionModel.fromEntity(entity);

        // Assert
        expect(model, isA<QuestionModel>());
        expect(model.id, entity.id);
        expect(model.type, entity.type);
        expect(model.questionText, entity.questionText);
        expect(model.options, entity.options);
        expect(model.correctAnswer, entity.correctAnswer);
      });

      test('should preserve all fields when converting from entity', () {
        // Arrange
        final entity = tQuestionDrawing1;

        // Act
        final model = QuestionModel.fromEntity(entity);

        // Assert
        expect(model.meanings, entity.meanings);
        expect(model.explanation, entity.explanation);
        expect(model.points, entity.points);
        expect(model.orderIndex, entity.orderIndex);
        expect(model.createdAt, entity.createdAt);
      });
    });

    group('JSON round trip', () {
      test('should maintain data integrity through fromJson -> toJson', () {
        // Arrange
        final originalJson = tQuestionMultipleChoiceJson;

        // Act
        final model = QuestionModel.fromJson(originalJson);
        final resultJson = model.toJson();

        // Assert
        expect(resultJson['id'], originalJson['id']);
        expect(resultJson['type'], originalJson['type']);
        expect(resultJson['questionText'], originalJson['questionText']);
        expect(resultJson['options'], originalJson['options']);
        expect(resultJson['correctAnswer'], originalJson['correctAnswer']);
      });

      test('should maintain DRAWING question data through round trip', () {
        // Arrange
        final originalJson = tQuestionDrawingJson;

        // Act
        final model = QuestionModel.fromJson(originalJson);
        final resultJson = model.toJson();

        // Assert
        expect(resultJson['meanings'], originalJson['meanings']);
        expect(resultJson['options'], originalJson['options']);
      });
    });

    group('Question type helpers', () {
      test('should correctly identify MULTIPLE_CHOICE type', () {
        // Arrange
        final model = QuestionModel.fromEntity(tQuestionMultipleChoice1);

        // Assert
        expect(model.isMultipleChoice, true);
        expect(model.isTrueFalse, false);
        expect(model.isFillInBlank, false);
        expect(model.isDrawing, false);
      });

      test('should correctly identify TRUE_FALSE type', () {
        // Arrange
        final model = QuestionModel.fromEntity(tQuestionTrueFalse1);

        // Assert
        expect(model.isMultipleChoice, false);
        expect(model.isTrueFalse, true);
        expect(model.isFillInBlank, false);
        expect(model.isDrawing, false);
      });

      test('should correctly identify FILL_IN_BLANK type', () {
        // Arrange
        final model = QuestionModel.fromEntity(tQuestionFillInBlank1);

        // Assert
        expect(model.isMultipleChoice, false);
        expect(model.isTrueFalse, false);
        expect(model.isFillInBlank, true);
        expect(model.isDrawing, false);
      });

      test('should correctly identify DRAWING type', () {
        // Arrange
        final model = QuestionModel.fromEntity(tQuestionDrawing1);

        // Assert
        expect(model.isMultipleChoice, false);
        expect(model.isTrueFalse, false);
        expect(model.isFillInBlank, false);
        expect(model.isDrawing, true);
      });
    });
  });
}
