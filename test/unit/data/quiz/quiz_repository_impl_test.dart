import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/quiz/data/datasources/quiz_remote_datasource.dart';
import 'package:kanji_mobile_v1/features/quiz/data/models/question_model.dart';
import 'package:kanji_mobile_v1/features/quiz/data/models/quiz_model.dart';
import 'package:kanji_mobile_v1/features/quiz/data/models/quiz_result_model.dart';
import 'package:kanji_mobile_v1/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/question.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/quiz.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/quiz_result.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/fixtures/quiz_fixtures.dart';

class MockQuizRemoteDataSource extends Mock implements QuizRemoteDataSource {}

void main() {
  late QuizRepositoryImpl repository;
  late MockQuizRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockQuizRemoteDataSource();
    repository = QuizRepositoryImpl(mockDataSource);
  });

  group('getAllQuizzes', () {
    final tQuizModels = [
      QuizModel.fromEntity(tQuiz1),
      QuizModel.fromEntity(tQuiz2),
    ];

    test('should return list of Quiz when successful', () async {
      // Arrange
      when(
        () => mockDataSource.getAllQuizzes(),
      ).thenAnswer((_) async => tQuizModels);

      // Act
      final result = await repository.getAllQuizzes();

      // Assert
      expect(result, Right(tQuizModels));
      verify(() => mockDataSource.getAllQuizzes()).called(1);
    });

    test('should return ServerFailure on DioException', () async {
      // Arrange
      when(() => mockDataSource.getAllQuizzes()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ),
        ),
      );

      // Act
      final result = await repository.getAllQuizzes();

      // Assert
      expect(result, isA<Left<Failure, List<Quiz>>>());
    });
  });

  group('getQuizById', () {
    const tQuizId = '1';
    final tQuizModel = QuizModel.fromEntity(tQuiz1);

    test('should return Quiz when successful', () async {
      // Arrange
      when(
        () => mockDataSource.getQuizById(tQuizId),
      ).thenAnswer((_) async => tQuizModel);

      // Act
      final result = await repository.getQuizById(tQuizId);

      // Assert
      expect(result, Right(tQuizModel));
      verify(() => mockDataSource.getQuizById(tQuizId)).called(1);
    });

    test('should return NotFoundFailure when quiz not found', () async {
      // Arrange
      when(() => mockDataSource.getQuizById(tQuizId)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 404,
          ),
        ),
      );

      // Act
      final result = await repository.getQuizById(tQuizId);

      // Assert
      expect(result, isA<Left<Failure, Quiz>>());
    });
  });

  group('getQuizQuestions', () {
    const tQuizId = '1';
    final tQuestionModels = [
      QuestionModel.fromEntity(tQuestionMultipleChoice1),
      QuestionModel.fromEntity(tQuestionTrueFalse1),
    ];

    test('should return list of Question when successful', () async {
      // Arrange
      when(
        () => mockDataSource.getQuizQuestions(tQuizId),
      ).thenAnswer((_) async => tQuestionModels);

      // Act
      final result = await repository.getQuizQuestions(tQuizId);

      // Assert
      expect(result, Right(tQuestionModels));
      verify(() => mockDataSource.getQuizQuestions(tQuizId)).called(1);
    });
  });

  group('submitAnswer', () {
    const tQuizId = '1';
    const tQuestionId = 'q-1';
    const tAnswer = 'sun';

    test('should return true for correct answer', () async {
      // Arrange
      when(
        () => mockDataSource.submitAnswer(
          quizId: tQuizId,
          questionId: tQuestionId,
          answer: tAnswer,
        ),
      ).thenAnswer((_) async => true);

      // Act
      final result = await repository.submitAnswer(
        quizId: tQuizId,
        questionId: tQuestionId,
        answer: tAnswer,
      );

      // Assert
      expect(result, const Right(true));
    });

    test('should return false for incorrect answer', () async {
      // Arrange
      when(
        () => mockDataSource.submitAnswer(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
          answer: any(named: 'answer'),
        ),
      ).thenAnswer((_) async => false);

      // Act
      final result = await repository.submitAnswer(
        quizId: tQuizId,
        questionId: tQuestionId,
        answer: 'wrong',
      );

      // Assert
      expect(result, const Right(false));
    });
  });

  group('completeQuiz', () {
    const tQuizId = '1';
    const tTimeSpent = 480;
    final tQuizResultModel = QuizResultModel.fromEntity(tQuizResult1);

    test('should return QuizResult when successful', () async {
      // Arrange
      when(
        () =>
            mockDataSource.completeQuiz(quizId: tQuizId, timeSpent: tTimeSpent),
      ).thenAnswer((_) async => tQuizResultModel);

      // Act
      final result = await repository.completeQuiz(
        quizId: tQuizId,
        timeSpent: tTimeSpent,
      );

      // Assert
      expect(result, Right(tQuizResultModel));
    });
  });

  group('getQuizHistory', () {
    final tQuizResultModels = [
      QuizResultModel.fromEntity(tQuizResult1),
      QuizResultModel.fromEntity(tQuizResult2),
    ];

    test('should return list of QuizResult when successful', () async {
      // Arrange
      when(
        () => mockDataSource.getQuizHistory(),
      ).thenAnswer((_) async => tQuizResultModels);

      // Act
      final result = await repository.getQuizHistory();

      // Assert
      expect(result, Right(tQuizResultModels));
    });
  });

  group('addQuestion', () {
    const tQuizId = 'quiz-1';
    final tQuestionModel = QuestionModel.fromEntity(tQuestionMultipleChoice1);

    test('should return Question when successful', () async {
      // Arrange
      when(
        () => mockDataSource.addQuestion(
          quizId: any(named: 'quizId'),
          type: any(named: 'type'),
          questionText: any(named: 'questionText'),
          options: any(named: 'options'),
          correctAnswer: any(named: 'correctAnswer'),
          points: any(named: 'points'),
        ),
      ).thenAnswer((_) async => tQuestionModel);

      // Act
      final result = await repository.addQuestion(
        quizId: tQuizId,
        type: 'MULTIPLE_CHOICE',
        questionText: 'Test?',
        options: ['A', 'B'],
        correctAnswer: 'A',
      );

      // Assert
      expect(result, Right(tQuestionModel));
    });
  });

  group('updateQuestion', () {
    const tQuizId = 'quiz-1';
    const tQuestionId = 'q-1';
    final tUpdatedQuestion = QuestionModel.fromEntity(tQuestionMultipleChoice1);

    test('should return updated Question when successful', () async {
      // Arrange
      when(
        () => mockDataSource.updateQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
          questionText: any(named: 'questionText'),
        ),
      ).thenAnswer((_) async => tUpdatedQuestion);

      // Act
      final result = await repository.updateQuestion(
        quizId: tQuizId,
        questionId: tQuestionId,
        questionText: 'Updated',
      );

      // Assert
      expect(result, Right(tUpdatedQuestion));
    });
  });

  group('deleteQuestion', () {
    const tQuizId = 'quiz-1';
    const tQuestionId = 'q-1';

    test('should return Right(null) when successful', () async {
      // Arrange
      when(
        () => mockDataSource.deleteQuestion(
          quizId: tQuizId,
          questionId: tQuestionId,
        ),
      ).thenAnswer((_) async => {});

      // Act
      final result = await repository.deleteQuestion(
        quizId: tQuizId,
        questionId: tQuestionId,
      );

      // Assert
      expect(result, const Right(null));
    });

    test('should return Failure on error', () async {
      // Arrange
      when(
        () => mockDataSource.deleteQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 404,
          ),
        ),
      );

      // Act
      final result = await repository.deleteQuestion(
        quizId: tQuizId,
        questionId: tQuestionId,
      );

      // Assert
      expect(result, isA<Left<Failure, void>>());
    });
  });
}
