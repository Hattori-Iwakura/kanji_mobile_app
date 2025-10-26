import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/quiz_result.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/get_quiz_history.dart';

// Mock repository
class MockQuizRepository extends Mock implements QuizRepository {}

void main() {
  late GetQuizHistory useCase;
  late MockQuizRepository mockRepository;

  setUp(() {
    mockRepository = MockQuizRepository();
    useCase = GetQuizHistory(mockRepository);
  });

  group('GetQuizHistory', () {
    final testHistory = [
      QuizResult(
        id: 'result-1',
        userId: 'user-1',
        quizId: 'quiz-1',
        totalQuestions: 10,
        correctAnswers: 8,
        incorrectAnswers: 2,
        skippedQuestions: 0,
        totalPoints: 100,
        earnedPoints: 80,
        scorePercentage: 80.0,
        timeSpent: 300,
        isPassed: true,
        answers: const [],
        completedAt: DateTime(2024, 1, 1, 12, 0),
        createdAt: DateTime(2024, 1, 1, 12, 0),
      ),
      QuizResult(
        id: 'result-2',
        userId: 'user-1',
        quizId: 'quiz-2',
        totalQuestions: 20,
        correctAnswers: 18,
        incorrectAnswers: 2,
        skippedQuestions: 0,
        totalPoints: 200,
        earnedPoints: 180,
        scorePercentage: 90.0,
        timeSpent: 600,
        isPassed: true,
        answers: const [],
        completedAt: DateTime(2024, 1, 2, 12, 0),
        createdAt: DateTime(2024, 1, 2, 12, 0),
      ),
    ];

    test('should get quiz history from repository', () async {
      // Arrange
      when(
        () => mockRepository.getQuizHistory(),
      ).thenAnswer((_) async => Right(testHistory));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Right(testHistory));
      verify(() => mockRepository.getQuizHistory()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no history', () async {
      // Arrange
      when(
        () => mockRepository.getQuizHistory(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase();

      // Assert
      result.fold(
        (failure) => fail('Should not fail'),
        (history) => expect(history, isEmpty),
      );
    });

    test('should return history with correct properties', () async {
      // Arrange
      when(
        () => mockRepository.getQuizHistory(),
      ).thenAnswer((_) async => Right(testHistory));

      // Act
      final result = await useCase();

      // Assert
      result.fold((failure) => fail('Should not fail'), (history) {
        expect(history.length, 2);
        expect(history[0].id, 'result-1');
        expect(history[0].quizId, 'quiz-1');
        expect(history[0].scorePercentage, 80.0);
        expect(history[0].isPassed, true);
        expect(history[1].id, 'result-2');
        expect(history[1].scorePercentage, 90.0);
        expect(history[1].isExcellent, true);
      });
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      const failure = ServerFailure('Failed to get history');
      when(
        () => mockRepository.getQuizHistory(),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getQuizHistory()).called(1);
    });

    test('should return NetworkFailure when no connection', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(
        () => mockRepository.getQuizHistory(),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left(failure));
    });

    test('should calculate statistics correctly from history', () async {
      // Arrange
      final historyWithStats = [
        QuizResult(
          id: 'r1',
          userId: 'user-1',
          quizId: 'q1',
          totalQuestions: 10,
          correctAnswers: 9,
          incorrectAnswers: 1,
          skippedQuestions: 0,
          totalPoints: 100,
          earnedPoints: 90,
          scorePercentage: 90.0,
          timeSpent: 300,
          isPassed: true,
          answers: const [],
          completedAt: DateTime(2024, 1, 1),
          createdAt: DateTime(2024, 1, 1),
        ),
        QuizResult(
          id: 'r2',
          userId: 'user-1',
          quizId: 'q2',
          totalQuestions: 10,
          correctAnswers: 8,
          incorrectAnswers: 2,
          skippedQuestions: 0,
          totalPoints: 100,
          earnedPoints: 80,
          scorePercentage: 80.0,
          timeSpent: 400,
          isPassed: true,
          answers: const [],
          completedAt: DateTime(2024, 1, 2),
          createdAt: DateTime(2024, 1, 2),
        ),
        QuizResult(
          id: 'r3',
          userId: 'user-1',
          quizId: 'q3',
          totalQuestions: 10,
          correctAnswers: 5,
          incorrectAnswers: 5,
          skippedQuestions: 0,
          totalPoints: 100,
          earnedPoints: 50,
          scorePercentage: 50.0,
          timeSpent: 200,
          isPassed: false,
          answers: const [],
          completedAt: DateTime(2024, 1, 3),
          createdAt: DateTime(2024, 1, 3),
        ),
      ];

      when(
        () => mockRepository.getQuizHistory(),
      ).thenAnswer((_) async => Right(historyWithStats));

      // Act
      final result = await useCase();

      // Assert
      result.fold((failure) => fail('Should not fail'), (history) {
        expect(history.length, 3);
        // Average: (90 + 80 + 50) / 3 = 73.33
        final totalPassed = history.where((r) => r.isPassed).length;
        expect(totalPassed, 2);
        final totalFailed = history.where((r) => !r.isPassed).length;
        expect(totalFailed, 1);
      });
    });
  });
}
