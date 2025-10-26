import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/quiz/data/models/quiz_result_model.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/quiz_result.dart';
import '../../../helpers/fixtures/quiz_fixtures.dart';

void main() {
  group('QuizResultModel', () {
    group('fromJson', () {
      test('should parse quiz result from JSON correctly', () {
        // Arrange
        final json = tQuizResultJson;

        // Act
        final result = QuizResultModel.fromJson(json);

        // Assert
        expect(result, isA<QuizResult>());
        expect(result.id, '1');
        expect(result.userId, '1');
        expect(result.quizId, '1');
        expect(result.totalQuestions, 10);
        expect(result.correctAnswers, 8);
        expect(result.isPassed, true);
      });

      test('should parse passed result', () {
        // Arrange
        final json = {
          ...tQuizResultJson,
          'scorePercentage': 90.0,
          'isPassed': true,
        };

        // Act
        final result = QuizResultModel.fromJson(json);

        // Assert
        expect(result.isPassed, true);
        expect(result.scorePercentage, 90.0);
      });

      test('should parse failed result', () {
        // Arrange
        final json = {
          ...tQuizResultJson,
          'scorePercentage': 45.0,
          'isPassed': false,
        };

        // Act
        final result = QuizResultModel.fromJson(json);

        // Assert
        expect(result.isPassed, false);
        expect(result.scorePercentage, 45.0);
      });

      test('should parse all statistics fields', () {
        // Act
        final result = QuizResultModel.fromJson(tQuizResultJson);

        // Assert
        expect(result.incorrectAnswers, 2);
        expect(result.skippedQuestions, 0);
        expect(result.totalPoints, 100);
        expect(result.earnedPoints, 80);
        expect(result.timeSpent, 480);
      });

      test('should parse DateTime fields correctly', () {
        // Act
        final result = QuizResultModel.fromJson(tQuizResultJson);

        // Assert
        expect(result.completedAt, DateTime.parse('2024-01-01T10:15:00.000Z'));
        expect(result.createdAt, DateTime.parse('2024-01-01T10:00:00.000Z'));
      });

      test('should parse answers list', () {
        // Arrange
        final json = {
          ...tQuizResultJson,
          'answers': [
            {
              'questionId': 'q-1',
              'userAnswer': 'A',
              'isCorrect': true,
              'pointsEarned': 10,
              'answeredAt': '2024-01-01T10:01:00.000',
            },
          ],
        };

        // Act
        final result = QuizResultModel.fromJson(json);

        // Assert
        expect(result.answers.length, 1);
        expect(result.answers.first.questionId, 'q-1');
      });
    });

    group('toJson', () {
      test('should convert result to JSON correctly', () {
        // Arrange
        final model = QuizResultModel(
          id: 'r-1',
          userId: 'u-1',
          quizId: 'q-1',
          totalQuestions: 10,
          correctAnswers: 8,
          incorrectAnswers: 2,
          skippedQuestions: 0,
          totalPoints: 100,
          earnedPoints: 80,
          scorePercentage: 80.0,
          timeSpent: 600,
          isPassed: true,
          answers: [],
          completedAt: DateTime(2024, 1, 1, 10, 0),
          createdAt: DateTime(2024, 1, 1, 9, 50),
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'r-1');
        expect(json['totalQuestions'], 10);
        expect(json['scorePercentage'], 80.0);
        expect(json['isPassed'], true);
      });

      test('should include all statistics in JSON', () {
        // Arrange
        final model = QuizResultModel(
          id: 'r-1',
          userId: 'u-1',
          quizId: 'q-1',
          totalQuestions: 15,
          correctAnswers: 10,
          incorrectAnswers: 4,
          skippedQuestions: 1,
          totalPoints: 150,
          earnedPoints: 100,
          scorePercentage: 66.67,
          timeSpent: 900,
          isPassed: false,
          answers: [],
          completedAt: DateTime(2024, 1, 1, 10, 0),
          createdAt: DateTime(2024, 1, 1, 9, 45),
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['correctAnswers'], 10);
        expect(json['incorrectAnswers'], 4);
        expect(json['skippedQuestions'], 1);
        expect(json['totalPoints'], 150);
        expect(json['earnedPoints'], 100);
        expect(json['timeSpent'], 900);
      });
    });

    group('fromEntity', () {
      test('should create QuizResultModel from QuizResult entity', () {
        // Arrange
        final entity = tQuizResult1;

        // Act
        final model = QuizResultModel.fromEntity(entity);

        // Assert
        expect(model, isA<QuizResultModel>());
        expect(model.id, entity.id);
        expect(model.totalQuestions, entity.totalQuestions);
        expect(model.scorePercentage, entity.scorePercentage);
      });

      test('should preserve all fields when converting from entity', () {
        // Arrange
        final entity = tQuizResult2;

        // Act
        final model = QuizResultModel.fromEntity(entity);

        // Assert
        expect(model.correctAnswers, entity.correctAnswers);
        expect(model.incorrectAnswers, entity.incorrectAnswers);
        expect(model.earnedPoints, entity.earnedPoints);
        expect(model.isPassed, entity.isPassed);
      });
    });

    group('JSON round trip', () {
      test('should maintain data integrity through fromJson -> toJson', () {
        // Arrange
        final originalJson = tQuizResultJson;

        // Act
        final model = QuizResultModel.fromJson(originalJson);
        final resultJson = model.toJson();

        // Assert
        expect(resultJson['id'], originalJson['id']);
        expect(resultJson['scorePercentage'], originalJson['scorePercentage']);
        expect(resultJson['isPassed'], originalJson['isPassed']);
        expect(resultJson['totalQuestions'], originalJson['totalQuestions']);
      });
    });

    group('QuizResult properties', () {
      test('should calculate accuracy correctly', () {
        // Arrange
        final model = QuizResultModel.fromEntity(tQuizResult1);

        // Assert
        expect(model.accuracy, 80.0);
      });

      test('should get formatted time spent', () {
        // Arrange
        final model = QuizResultModel.fromEntity(tQuizResult1);

        // Assert
        expect(model.formattedTimeSpent, '8:00');
      });

      test('should identify excellent result', () {
        // Arrange
        final model = QuizResultModel.fromEntity(tQuizResultDrawing);

        // Assert
        expect(model.isExcellent, true);
        expect(model.grade, 'A+');
      });

      test('should identify good result', () {
        // Arrange
        final model = QuizResultModel.fromEntity(tQuizResult1);

        // Assert
        expect(model.isGood, true);
      });
    });
  });
}
