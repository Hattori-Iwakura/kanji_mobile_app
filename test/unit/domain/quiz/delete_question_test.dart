import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/delete_question.dart';

class MockQuizRepository extends Mock implements QuizRepository {}

void main() {
  late DeleteQuestion useCase;
  late MockQuizRepository mockRepository;

  setUp(() {
    mockRepository = MockQuizRepository();
    useCase = DeleteQuestion(mockRepository);
  });

  group('DeleteQuestion', () {
    const testQuizId = 'quiz-1';
    const testQuestionId = 'q-1';

    test('should delete question successfully', () async {
      // Arrange
      when(
        () => mockRepository.deleteQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: testQuestionId,
      );

      // Assert
      expect(result, const Right(null));
      verify(
        () => mockRepository.deleteQuestion(
          quizId: testQuizId,
          questionId: testQuestionId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotFoundFailure when question not found', () async {
      // Arrange
      const failure = NotFoundFailure('Question not found');
      when(
        () => mockRepository.deleteQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: 'invalid-id',
      );

      // Assert
      expect(result, const Left(failure));
      verify(
        () => mockRepository.deleteQuestion(
          quizId: testQuizId,
          questionId: 'invalid-id',
        ),
      ).called(1);
    });

    test('should return NotFoundFailure when quiz not found', () async {
      // Arrange
      const failure = NotFoundFailure('Quiz not found');
      when(
        () => mockRepository.deleteQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        quizId: 'invalid-quiz-id',
        questionId: testQuestionId,
      );

      // Assert
      expect(result, const Left(failure));
    });

    test(
      'should return UnauthorizedFailure when user not authorized',
      () async {
        // Arrange
        const failure = UnauthorizedFailure(
          'Not authorized to delete question',
        );
        when(
          () => mockRepository.deleteQuestion(
            quizId: any(named: 'quizId'),
            questionId: any(named: 'questionId'),
          ),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          quizId: testQuizId,
          questionId: testQuestionId,
        );

        // Assert
        expect(result, const Left(failure));
      },
    );

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(
        () => mockRepository.deleteQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: testQuestionId,
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when no connection', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(
        () => mockRepository.deleteQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: testQuestionId,
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should call repository with correct parameters', () async {
      // Arrange
      const customQuizId = 'custom-quiz';
      const customQuestionId = 'custom-q';
      when(
        () => mockRepository.deleteQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      await useCase(quizId: customQuizId, questionId: customQuestionId);

      // Assert
      verify(
        () => mockRepository.deleteQuestion(
          quizId: customQuizId,
          questionId: customQuestionId,
        ),
      ).called(1);
    });
  });
}
