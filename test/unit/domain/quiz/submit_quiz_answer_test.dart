import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/submit_quiz_answer.dart';

// Mock repository
class MockQuizRepository extends Mock implements QuizRepository {}

void main() {
  late SubmitQuizAnswer useCase;
  late MockQuizRepository mockRepository;

  setUp(() {
    mockRepository = MockQuizRepository();
    useCase = SubmitQuizAnswer(mockRepository);
  });

  group('SubmitQuizAnswer', () {
    const testQuizId = 'quiz-1';
    const testQuestionId = 'q1';
    const testAnswer = 'にち';

    test('should submit answer and return true for correct answer', () async {
      // Arrange
      when(
        () => mockRepository.submitAnswer(
          quizId: testQuizId,
          questionId: testQuestionId,
          answer: testAnswer,
        ),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: testQuestionId,
        answer: testAnswer,
      );

      // Assert
      expect(result, const Right(true));
      verify(
        () => mockRepository.submitAnswer(
          quizId: testQuizId,
          questionId: testQuestionId,
          answer: testAnswer,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should submit answer and return false for incorrect answer',
      () async {
        // Arrange
        when(
          () => mockRepository.submitAnswer(
            quizId: testQuizId,
            questionId: testQuestionId,
            answer: 'げつ',
          ),
        ).thenAnswer((_) async => const Right(false));

        // Act
        final result = await useCase(
          quizId: testQuizId,
          questionId: testQuestionId,
          answer: 'げつ',
        );

        // Assert
        expect(result, const Right(false));
        result.fold(
          (failure) => fail('Should not fail'),
          (isCorrect) => expect(isCorrect, false),
        );
      },
    );

    test('should return ServerFailure when submission fails', () async {
      // Arrange
      const failure = ServerFailure('Failed to submit answer');
      when(
        () => mockRepository.submitAnswer(
          quizId: testQuizId,
          questionId: testQuestionId,
          answer: testAnswer,
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: testQuestionId,
        answer: testAnswer,
      );

      // Assert
      expect(result, const Left(failure));
      verify(
        () => mockRepository.submitAnswer(
          quizId: testQuizId,
          questionId: testQuestionId,
          answer: testAnswer,
        ),
      ).called(1);
    });

    test('should return NetworkFailure when no connection', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(
        () => mockRepository.submitAnswer(
          quizId: testQuizId,
          questionId: testQuestionId,
          answer: testAnswer,
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: testQuestionId,
        answer: testAnswer,
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should handle multiple answers for different questions', () async {
      // Arrange
      const q1 = 'q1';
      const q2 = 'q2';
      when(
        () => mockRepository.submitAnswer(
          quizId: testQuizId,
          questionId: q1,
          answer: 'にち',
        ),
      ).thenAnswer((_) async => const Right(true));

      when(
        () => mockRepository.submitAnswer(
          quizId: testQuizId,
          questionId: q2,
          answer: 'True',
        ),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result1 = await useCase(
        quizId: testQuizId,
        questionId: q1,
        answer: 'にち',
      );
      final result2 = await useCase(
        quizId: testQuizId,
        questionId: q2,
        answer: 'True',
      );

      // Assert
      expect(result1, const Right(true));
      expect(result2, const Right(true));
      verify(
        () => mockRepository.submitAnswer(
          quizId: testQuizId,
          questionId: q1,
          answer: 'にち',
        ),
      ).called(1);
      verify(
        () => mockRepository.submitAnswer(
          quizId: testQuizId,
          questionId: q2,
          answer: 'True',
        ),
      ).called(1);
    });

    test('should handle empty answer submission', () async {
      // Arrange
      when(
        () => mockRepository.submitAnswer(
          quizId: testQuizId,
          questionId: testQuestionId,
          answer: '',
        ),
      ).thenAnswer((_) async => const Right(false));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: testQuestionId,
        answer: '',
      );

      // Assert
      result.fold(
        (failure) => fail('Should not fail'),
        (isCorrect) => expect(isCorrect, false),
      );
    });
  });
}
