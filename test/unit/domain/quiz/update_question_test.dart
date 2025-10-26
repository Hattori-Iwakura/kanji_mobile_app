import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/question.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/update_question.dart';

class MockQuizRepository extends Mock implements QuizRepository {}

void main() {
  late UpdateQuestion useCase;
  late MockQuizRepository mockRepository;

  setUp(() {
    mockRepository = MockQuizRepository();
    useCase = UpdateQuestion(mockRepository);
  });

  group('UpdateQuestion', () {
    const testQuizId = 'quiz-1';
    const testQuestionId = 'q-1';
    final originalQuestion = Question(
      id: testQuestionId,
      quizId: testQuizId,
      type: 'MULTIPLE_CHOICE',
      questionText: 'What is the meaning of 日?',
      options: ['Sun', 'Moon', 'Water', 'Fire'],
      correctAnswer: 'Sun',
      explanation: '日 means sun or day',
      points: 10,
      orderIndex: 0,
      createdAt: DateTime(2024, 1, 1),
    );

    test('should update question text successfully', () async {
      // Arrange
      final updatedQuestion = Question(
        id: testQuestionId,
        quizId: testQuizId,
        type: 'MULTIPLE_CHOICE',
        questionText: 'Updated: What does 日 mean?',
        options: ['Sun', 'Moon', 'Water', 'Fire'],
        correctAnswer: 'Sun',
        explanation: '日 means sun or day',
        points: 10,
        orderIndex: 0,
        createdAt: DateTime(2024, 1, 1),
      );

      when(
        () => mockRepository.updateQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
          type: any(named: 'type'),
          questionText: any(named: 'questionText'),
          options: any(named: 'options'),
          correctAnswer: any(named: 'correctAnswer'),
          explanation: any(named: 'explanation'),
          points: any(named: 'points'),
          meanings: any(named: 'meanings'),
        ),
      ).thenAnswer((_) async => Right(updatedQuestion));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: testQuestionId,
        questionText: 'Updated: What does 日 mean?',
      );

      // Assert
      expect(result, Right(updatedQuestion));
      verify(
        () => mockRepository.updateQuestion(
          quizId: testQuizId,
          questionId: testQuestionId,
          type: null,
          questionText: 'Updated: What does 日 mean?',
          options: null,
          correctAnswer: null,
          explanation: null,
          points: null,
          meanings: null,
        ),
      ).called(1);
    });

    test('should update multiple fields successfully', () async {
      // Arrange
      final updatedQuestion = Question(
        id: testQuestionId,
        quizId: testQuizId,
        type: 'MULTIPLE_CHOICE',
        questionText: 'Updated question',
        options: ['A', 'B', 'C', 'D'],
        correctAnswer: 'A',
        explanation: 'Updated explanation',
        points: 15,
        orderIndex: 0,
        createdAt: DateTime(2024, 1, 1),
      );

      when(
        () => mockRepository.updateQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
          type: any(named: 'type'),
          questionText: any(named: 'questionText'),
          options: any(named: 'options'),
          correctAnswer: any(named: 'correctAnswer'),
          explanation: any(named: 'explanation'),
          points: any(named: 'points'),
          meanings: any(named: 'meanings'),
        ),
      ).thenAnswer((_) async => Right(updatedQuestion));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: testQuestionId,
        questionText: 'Updated question',
        options: ['A', 'B', 'C', 'D'],
        correctAnswer: 'A',
        explanation: 'Updated explanation',
        points: 15,
      );

      // Assert
      expect(result, Right(updatedQuestion));
    });

    test('should update only correct answer', () async {
      // Arrange
      final updatedQuestion = Question(
        id: testQuestionId,
        quizId: testQuizId,
        type: 'MULTIPLE_CHOICE',
        questionText: 'What is the meaning of 日?',
        options: ['Sun', 'Moon', 'Water', 'Fire'],
        correctAnswer: 'Moon', // Changed
        explanation: '日 means sun or day',
        points: 10,
        orderIndex: 0,
        createdAt: DateTime(2024, 1, 1),
      );

      when(
        () => mockRepository.updateQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
          type: any(named: 'type'),
          questionText: any(named: 'questionText'),
          options: any(named: 'options'),
          correctAnswer: any(named: 'correctAnswer'),
          explanation: any(named: 'explanation'),
          points: any(named: 'points'),
          meanings: any(named: 'meanings'),
        ),
      ).thenAnswer((_) async => Right(updatedQuestion));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: testQuestionId,
        correctAnswer: 'Moon',
      );

      // Assert
      expect(result, Right(updatedQuestion));
    });

    test('should update points value', () async {
      // Arrange
      final updatedQuestion = Question(
        id: testQuestionId,
        quizId: testQuizId,
        type: 'MULTIPLE_CHOICE',
        questionText: 'What is the meaning of 日?',
        options: ['Sun', 'Moon', 'Water', 'Fire'],
        correctAnswer: 'Sun',
        explanation: '日 means sun or day',
        points: 20, // Changed
        orderIndex: 0,
        createdAt: DateTime(2024, 1, 1),
      );

      when(
        () => mockRepository.updateQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
          type: any(named: 'type'),
          questionText: any(named: 'questionText'),
          options: any(named: 'options'),
          correctAnswer: any(named: 'correctAnswer'),
          explanation: any(named: 'explanation'),
          points: any(named: 'points'),
          meanings: any(named: 'meanings'),
        ),
      ).thenAnswer((_) async => Right(updatedQuestion));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: testQuestionId,
        points: 20,
      );

      // Assert
      expect(result, Right(updatedQuestion));
    });

    test('should update meanings for drawing question', () async {
      // Arrange
      final drawingQuestion = Question(
        id: testQuestionId,
        quizId: testQuizId,
        type: 'DRAWING',
        questionText: 'Draw the kanji for "sun"',
        options: [],
        correctAnswer: '日',
        points: 20,
        orderIndex: 0,
        createdAt: DateTime(2024, 1, 1),
        meanings: ['sun', 'day', 'Japan'], // Updated
      );

      when(
        () => mockRepository.updateQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
          type: any(named: 'type'),
          questionText: any(named: 'questionText'),
          options: any(named: 'options'),
          correctAnswer: any(named: 'correctAnswer'),
          explanation: any(named: 'explanation'),
          points: any(named: 'points'),
          meanings: any(named: 'meanings'),
        ),
      ).thenAnswer((_) async => Right(drawingQuestion));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: testQuestionId,
        meanings: ['sun', 'day', 'Japan'],
      );

      // Assert
      expect(result, Right(drawingQuestion));
    });

    test('should return NotFoundFailure when question not found', () async {
      // Arrange
      const failure = NotFoundFailure('Question not found');
      when(
        () => mockRepository.updateQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
          type: any(named: 'type'),
          questionText: any(named: 'questionText'),
          options: any(named: 'options'),
          correctAnswer: any(named: 'correctAnswer'),
          explanation: any(named: 'explanation'),
          points: any(named: 'points'),
          meanings: any(named: 'meanings'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: 'invalid-id',
        questionText: 'Updated',
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should return BadRequestFailure when no fields provided', () async {
      // Arrange
      const failure = BadRequestFailure('At least one field must be provided');
      when(
        () => mockRepository.updateQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
          type: any(named: 'type'),
          questionText: any(named: 'questionText'),
          options: any(named: 'options'),
          correctAnswer: any(named: 'correctAnswer'),
          explanation: any(named: 'explanation'),
          points: any(named: 'points'),
          meanings: any(named: 'meanings'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: testQuestionId,
        // No fields provided
      );

      // Assert
      expect(result, const Left(failure));
    });

    test(
      'should return UnauthorizedFailure when user not authorized',
      () async {
        // Arrange
        const failure = UnauthorizedFailure(
          'Not authorized to update question',
        );
        when(
          () => mockRepository.updateQuestion(
            quizId: any(named: 'quizId'),
            questionId: any(named: 'questionId'),
            type: any(named: 'type'),
            questionText: any(named: 'questionText'),
            options: any(named: 'options'),
            correctAnswer: any(named: 'correctAnswer'),
            explanation: any(named: 'explanation'),
            points: any(named: 'points'),
            meanings: any(named: 'meanings'),
          ),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          quizId: testQuizId,
          questionId: testQuestionId,
          questionText: 'Updated',
        );

        // Assert
        expect(result, const Left(failure));
      },
    );

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(
        () => mockRepository.updateQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
          type: any(named: 'type'),
          questionText: any(named: 'questionText'),
          options: any(named: 'options'),
          correctAnswer: any(named: 'correctAnswer'),
          explanation: any(named: 'explanation'),
          points: any(named: 'points'),
          meanings: any(named: 'meanings'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: testQuestionId,
        questionText: 'Updated',
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should verify updated question has correct properties', () async {
      // Arrange
      final updatedQuestion = Question(
        id: testQuestionId,
        quizId: testQuizId,
        type: 'MULTIPLE_CHOICE',
        questionText: 'Updated question',
        options: ['A', 'B'],
        correctAnswer: 'A',
        explanation: 'New explanation',
        points: 15,
        orderIndex: 0,
        createdAt: DateTime(2024, 1, 1),
      );

      when(
        () => mockRepository.updateQuestion(
          quizId: any(named: 'quizId'),
          questionId: any(named: 'questionId'),
          type: any(named: 'type'),
          questionText: any(named: 'questionText'),
          options: any(named: 'options'),
          correctAnswer: any(named: 'correctAnswer'),
          explanation: any(named: 'explanation'),
          points: any(named: 'points'),
          meanings: any(named: 'meanings'),
        ),
      ).thenAnswer((_) async => Right(updatedQuestion));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        questionId: testQuestionId,
        questionText: 'Updated question',
        explanation: 'New explanation',
        points: 15,
      );

      // Assert
      result.fold((failure) => fail('Should not fail'), (question) {
        expect(question.id, testQuestionId);
        expect(question.questionText, 'Updated question');
        expect(question.explanation, 'New explanation');
        expect(question.points, 15);
      });
    });
  });
}
