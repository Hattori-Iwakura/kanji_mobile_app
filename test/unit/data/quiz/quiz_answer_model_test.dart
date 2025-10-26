import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/quiz/data/models/quiz_answer_model.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/quiz_answer.dart';

void main() {
  group('QuizAnswerModel', () {
    const tQuizAnswerJson = {
      'questionId': 'q-1',
      'userAnswer': 'sun',
      'isCorrect': true,
      'pointsEarned': 10,
      'answeredAt': '2024-01-10T10:00:00.000',
    };

    final tQuizAnswer = QuizAnswer(
      questionId: 'q-1',
      userAnswer: 'sun',
      isCorrect: true,
      pointsEarned: 10,
      answeredAt: DateTime(2024, 1, 10, 10, 0),
    );

    group('fromJson', () {
      test('should parse correct answer from JSON', () {
        // Act
        final result = QuizAnswerModel.fromJson(tQuizAnswerJson);

        // Assert
        expect(result, isA<QuizAnswer>());
        expect(result.questionId, 'q-1');
        expect(result.userAnswer, 'sun');
        expect(result.isCorrect, true);
        expect(result.pointsEarned, 10);
      });

      test('should parse incorrect answer from JSON', () {
        // Arrange
        final json = {
          ...tQuizAnswerJson,
          'isCorrect': false,
          'pointsEarned': 0,
        };

        // Act
        final result = QuizAnswerModel.fromJson(json);

        // Assert
        expect(result.isCorrect, false);
        expect(result.pointsEarned, 0);
      });

      test('should parse DateTime correctly', () {
        // Act
        final result = QuizAnswerModel.fromJson(tQuizAnswerJson);

        // Assert
        expect(result.answeredAt, DateTime(2024, 1, 10, 10, 0));
      });
    });

    group('toJson', () {
      test('should convert answer to JSON correctly', () {
        // Arrange
        final model = QuizAnswerModel(
          questionId: 'q-1',
          userAnswer: 'sun',
          isCorrect: true,
          pointsEarned: 10,
          answeredAt: DateTime(2024, 1, 10, 10, 0),
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['questionId'], 'q-1');
        expect(json['userAnswer'], 'sun');
        expect(json['isCorrect'], true);
        expect(json['pointsEarned'], 10);
        expect(json['answeredAt'], '2024-01-10T10:00:00.000');
      });
    });

    group('fromEntity', () {
      test('should create QuizAnswerModel from QuizAnswer entity', () {
        // Act
        final model = QuizAnswerModel.fromEntity(tQuizAnswer);

        // Assert
        expect(model, isA<QuizAnswerModel>());
        expect(model.questionId, tQuizAnswer.questionId);
        expect(model.userAnswer, tQuizAnswer.userAnswer);
        expect(model.isCorrect, tQuizAnswer.isCorrect);
        expect(model.pointsEarned, tQuizAnswer.pointsEarned);
      });
    });

    group('JSON round trip', () {
      test('should maintain data integrity through fromJson -> toJson', () {
        // Act
        final model = QuizAnswerModel.fromJson(tQuizAnswerJson);
        final resultJson = model.toJson();

        // Assert
        expect(resultJson['questionId'], tQuizAnswerJson['questionId']);
        expect(resultJson['isCorrect'], tQuizAnswerJson['isCorrect']);
        expect(resultJson['pointsEarned'], tQuizAnswerJson['pointsEarned']);
      });
    });
  });
}
