import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/quiz_result.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/complete_quiz.dart';

// Mock repository
class MockQuizRepository extends Mock implements QuizRepository {}

void main() {
  late CompleteQuiz useCase;
  late MockQuizRepository mockRepository;

  setUp(() {
    mockRepository = MockQuizRepository();
    useCase = CompleteQuiz(mockRepository);
  });

  group('CompleteQuiz', () {
    const testQuizId = 'quiz-1';
    const testTimeSpent = 300; // 5 minutes

    final testResult = QuizResult(
      id: 'result-1',
      userId: 'user-1',
      quizId: testQuizId,
      totalQuestions: 10,
      correctAnswers: 8,
      incorrectAnswers: 2,
      skippedQuestions: 0,
      totalPoints: 100,
      earnedPoints: 80,
      scorePercentage: 80.0,
      timeSpent: testTimeSpent,
      isPassed: true,
      answers: const [],
      completedAt: DateTime(2024, 1, 1, 12, 0),
      createdAt: DateTime(2024, 1, 1, 12, 0),
    );

    test('should complete quiz and return result', () async {
      // Arrange
      when(
        () => mockRepository.completeQuiz(
          quizId: testQuizId,
          timeSpent: testTimeSpent,
        ),
      ).thenAnswer((_) async => Right(testResult));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        timeSpent: testTimeSpent,
      );

      // Assert
      expect(result, Right(testResult));
      verify(
        () => mockRepository.completeQuiz(
          quizId: testQuizId,
          timeSpent: testTimeSpent,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return result with correct properties', () async {
      // Arrange
      when(
        () => mockRepository.completeQuiz(
          quizId: testQuizId,
          timeSpent: testTimeSpent,
        ),
      ).thenAnswer((_) async => Right(testResult));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        timeSpent: testTimeSpent,
      );

      // Assert
      result.fold((failure) => fail('Should not fail'), (quizResult) {
        expect(quizResult.id, 'result-1');
        expect(quizResult.quizId, testQuizId);
        expect(quizResult.totalQuestions, 10);
        expect(quizResult.correctAnswers, 8);
        expect(quizResult.incorrectAnswers, 2);
        expect(quizResult.scorePercentage, 80.0);
        expect(quizResult.isPassed, true);
        expect(quizResult.accuracy, 80.0);
        expect(quizResult.grade, 'A');
      });
    });

    test('should return ServerFailure when completion fails', () async {
      // Arrange
      const failure = ServerFailure('Failed to complete quiz');
      when(
        () => mockRepository.completeQuiz(
          quizId: testQuizId,
          timeSpent: testTimeSpent,
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        timeSpent: testTimeSpent,
      );

      // Assert
      expect(result, const Left(failure));
      verify(
        () => mockRepository.completeQuiz(
          quizId: testQuizId,
          timeSpent: testTimeSpent,
        ),
      ).called(1);
    });

    test('should return NetworkFailure when no connection', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(
        () => mockRepository.completeQuiz(
          quizId: testQuizId,
          timeSpent: testTimeSpent,
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        timeSpent: testTimeSpent,
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should handle failing quiz result', () async {
      // Arrange
      final failedResult = QuizResult(
        id: 'result-2',
        userId: 'user-1',
        quizId: testQuizId,
        totalQuestions: 10,
        correctAnswers: 4,
        incorrectAnswers: 6,
        skippedQuestions: 0,
        totalPoints: 100,
        earnedPoints: 40,
        scorePercentage: 40.0,
        timeSpent: testTimeSpent,
        isPassed: false,
        answers: const [],
        completedAt: DateTime(2024, 1, 1, 12, 0),
        createdAt: DateTime(2024, 1, 1, 12, 0),
      );

      when(
        () => mockRepository.completeQuiz(
          quizId: testQuizId,
          timeSpent: testTimeSpent,
        ),
      ).thenAnswer((_) async => Right(failedResult));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        timeSpent: testTimeSpent,
      );

      // Assert
      result.fold((failure) => fail('Should not fail'), (quizResult) {
        expect(quizResult.isPassed, false);
        expect(quizResult.scorePercentage, 40.0);
        expect(quizResult.grade, 'F');
      });
    });

    test('should handle perfect score result', () async {
      // Arrange
      final perfectResult = QuizResult(
        id: 'result-3',
        userId: 'user-1',
        quizId: testQuizId,
        totalQuestions: 10,
        correctAnswers: 10,
        incorrectAnswers: 0,
        skippedQuestions: 0,
        totalPoints: 100,
        earnedPoints: 100,
        scorePercentage: 100.0,
        timeSpent: testTimeSpent,
        isPassed: true,
        answers: const [],
        completedAt: DateTime(2024, 1, 1, 12, 0),
        createdAt: DateTime(2024, 1, 1, 12, 0),
      );

      when(
        () => mockRepository.completeQuiz(
          quizId: testQuizId,
          timeSpent: testTimeSpent,
        ),
      ).thenAnswer((_) async => Right(perfectResult));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        timeSpent: testTimeSpent,
      );

      // Assert
      result.fold((failure) => fail('Should not fail'), (quizResult) {
        expect(quizResult.scorePercentage, 100.0);
        expect(quizResult.isExcellent, true);
        expect(quizResult.grade, 'A+');
      });
    });
  });
}
