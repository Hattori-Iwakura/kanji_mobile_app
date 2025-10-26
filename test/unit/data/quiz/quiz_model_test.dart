import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/quiz/data/models/quiz_model.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/quiz.dart';
import '../../../helpers/fixtures/quiz_fixtures.dart';

void main() {
  group('QuizModel', () {
    group('fromJson', () {
      test('should parse quiz from JSON correctly', () {
        // Arrange
        final json = tQuizJson;

        // Act
        final result = QuizModel.fromJson(json);

        // Assert
        expect(result, isA<Quiz>());
        expect(result.id, '1');
        expect(result.title, 'JLPT N5 Practice Quiz');
        expect(result.difficulty, 'EASY');
        expect(result.isPublished, true);
      });

      test('should parse all difficulty levels', () {
        // Arrange
        final easyJson = {...tQuizJson, 'difficulty': 'EASY'};
        final mediumJson = {...tQuizJson, 'difficulty': 'MEDIUM'};
        final hardJson = {...tQuizJson, 'difficulty': 'HARD'};

        // Act
        final easy = QuizModel.fromJson(easyJson);
        final medium = QuizModel.fromJson(mediumJson);
        final hard = QuizModel.fromJson(hardJson);

        // Assert
        expect(easy.difficulty, 'EASY');
        expect(medium.difficulty, 'MEDIUM');
        expect(hard.difficulty, 'HARD');
      });

      test('should parse quiz with time limit', () {
        // Arrange
        final json = {...tQuizJson, 'timeLimit': 600};

        // Act
        final result = QuizModel.fromJson(json);

        // Assert
        expect(result.timeLimit, 600);
        expect(result.hasTimeLimit, true);
      });

      test('should parse quiz without time limit', () {
        // Arrange
        final json = {...tQuizJson, 'timeLimit': 0};

        // Act
        final result = QuizModel.fromJson(json);

        // Assert
        expect(result.timeLimit, 0);
        expect(result.hasTimeLimit, false);
      });

      test('should parse published quiz', () {
        // Arrange
        final json = {...tQuizJson, 'isPublished': true};

        // Act
        final result = QuizModel.fromJson(json);

        // Assert
        expect(result.isPublished, true);
      });

      test('should parse unpublished quiz', () {
        // Arrange
        final json = {...tQuizJson, 'isPublished': false};

        // Act
        final result = QuizModel.fromJson(json);

        // Assert
        expect(result.isPublished, false);
      });

      test('should parse DateTime correctly', () {
        // Act
        final result = QuizModel.fromJson(tQuizJson);

        // Assert
        expect(result.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
        expect(result.updatedAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
      });
    });

    group('toJson', () {
      test('should convert quiz to JSON correctly', () {
        // Arrange
        final model = QuizModel(
          id: '1',
          title: 'Test Quiz',
          description: 'A test quiz',
          difficulty: 'EASY',
          totalQuestions: 10,
          timeLimit: 600,
          passingScore: 70,
          isPublished: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], '1');
        expect(json['title'], 'Test Quiz');
        expect(json['difficulty'], 'EASY');
        expect(json['isPublished'], true);
      });

      test('should convert all fields correctly', () {
        // Arrange
        final model = QuizModel(
          id: 'quiz-id',
          title: 'Advanced Quiz',
          description: 'Hard quiz',
          difficulty: 'HARD',
          totalQuestions: 20,
          timeLimit: 1800,
          passingScore: 80,
          isPublished: false,
          createdAt: DateTime(2024, 2, 15, 10, 30),
          updatedAt: DateTime(2024, 2, 16, 11, 45),
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['totalQuestions'], 20);
        expect(json['timeLimit'], 1800);
        expect(json['passingScore'], 80);
        expect(json['createdAt'], '2024-02-15T10:30:00.000');
        expect(json['updatedAt'], '2024-02-16T11:45:00.000');
      });
    });

    group('fromEntity', () {
      test('should create QuizModel from Quiz entity', () {
        // Arrange
        final entity = tQuiz1;

        // Act
        final model = QuizModel.fromEntity(entity);

        // Assert
        expect(model, isA<QuizModel>());
        expect(model.id, entity.id);
        expect(model.title, entity.title);
        expect(model.difficulty, entity.difficulty);
      });

      test('should preserve all fields when converting from entity', () {
        // Arrange
        final entity = tQuiz2;

        // Act
        final model = QuizModel.fromEntity(entity);

        // Assert
        expect(model.description, entity.description);
        expect(model.totalQuestions, entity.totalQuestions);
        expect(model.timeLimit, entity.timeLimit);
        expect(model.passingScore, entity.passingScore);
        expect(model.isPublished, entity.isPublished);
        expect(model.createdAt, entity.createdAt);
        expect(model.updatedAt, entity.updatedAt);
      });
    });

    group('JSON round trip', () {
      test('should maintain data integrity through fromJson -> toJson', () {
        // Arrange
        final originalJson = tQuizJson;

        // Act
        final model = QuizModel.fromJson(originalJson);
        final resultJson = model.toJson();

        // Assert
        expect(resultJson['id'], originalJson['id']);
        expect(resultJson['title'], originalJson['title']);
        expect(resultJson['difficulty'], originalJson['difficulty']);
        expect(resultJson['totalQuestions'], originalJson['totalQuestions']);
        expect(resultJson['isPublished'], originalJson['isPublished']);
      });
    });

    group('Quiz properties', () {
      test('should correctly identify quiz with time limit', () {
        // Arrange
        final model = QuizModel.fromEntity(tQuiz1);

        // Assert
        expect(model.hasTimeLimit, true);
      });

      test('should correctly identify quiz without time limit', () {
        // Arrange
        final model = QuizModel.fromEntity(tQuiz3);

        // Assert
        expect(model.hasTimeLimit, false);
      });

      test('should get formatted time limit for quiz with limit', () {
        // Arrange
        final model = QuizModel.fromEntity(tQuiz1);

        // Assert
        expect(model.formattedTimeLimit, '10 min');
      });

      test('should get correct difficulty color', () {
        // Arrange
        final easy = QuizModel.fromEntity(tQuiz1);
        final medium = QuizModel.fromEntity(tQuiz2);
        final hard = QuizModel.fromEntity(tQuiz3);

        // Assert
        expect(easy.difficultyColor, 'green');
        expect(medium.difficultyColor, 'orange');
        expect(hard.difficultyColor, 'red');
      });
    });
  });
}
