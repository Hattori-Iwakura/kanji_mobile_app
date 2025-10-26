import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/question.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/add_question.dart';

class MockQuizRepository extends Mock implements QuizRepository {}

void main() {
  late AddQuestion useCase;
  late MockQuizRepository mockRepository;

  setUp(() {
    mockRepository = MockQuizRepository();
    useCase = AddQuestion(mockRepository);
  });

  group('AddQuestion', () {
    const testQuizId = 'quiz-1';
    final testQuestion = Question(
      id: 'q-1',
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

    test('should add multiple choice question successfully', () async {
      // Arrange
      when(
        () => mockRepository.addQuestion(
          quizId: any(named: 'quizId'),
          type: any(named: 'type'),
          questionText: any(named: 'questionText'),
          options: any(named: 'options'),
          correctAnswer: any(named: 'correctAnswer'),
          explanation: any(named: 'explanation'),
          points: any(named: 'points'),
          meanings: any(named: 'meanings'),
        ),
      ).thenAnswer((_) async => Right(testQuestion));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        type: 'MULTIPLE_CHOICE',
        questionText: 'What is the meaning of 日?',
        options: ['Sun', 'Moon', 'Water', 'Fire'],
        correctAnswer: 'Sun',
        explanation: '日 means sun or day',
        points: 10,
      );

      // Assert
      expect(result, Right(testQuestion));
      verify(
        () => mockRepository.addQuestion(
          quizId: testQuizId,
          type: 'MULTIPLE_CHOICE',
          questionText: 'What is the meaning of 日?',
          options: ['Sun', 'Moon', 'Water', 'Fire'],
          correctAnswer: 'Sun',
          explanation: '日 means sun or day',
          points: 10,
          meanings: const [],
        ),
      ).called(1);
    });

    test('should add true/false question successfully', () async {
      // Arrange
      final trueFalseQuestion = Question(
        id: 'q-2',
        quizId: testQuizId,
        type: 'TRUE_FALSE',
        questionText: '日 means sun',
        options: ['True', 'False'],
        correctAnswer: 'True',
        points: 5,
        orderIndex: 1,
        createdAt: DateTime(2024, 1, 1),
      );

      when(
        () => mockRepository.addQuestion(
          quizId: any(named: 'quizId'),
          type: any(named: 'type'),
          questionText: any(named: 'questionText'),
          options: any(named: 'options'),
          correctAnswer: any(named: 'correctAnswer'),
          explanation: any(named: 'explanation'),
          points: any(named: 'points'),
          meanings: any(named: 'meanings'),
        ),
      ).thenAnswer((_) async => Right(trueFalseQuestion));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        type: 'TRUE_FALSE',
        questionText: '日 means sun',
        options: ['True', 'False'],
        correctAnswer: 'True',
        points: 5,
      );

      // Assert
      expect(result, Right(trueFalseQuestion));
    });

    test('should add fill in blank question successfully', () async {
      // Arrange
      final fillInBlankQuestion = Question(
        id: 'q-3',
        quizId: testQuizId,
        type: 'FILL_IN_BLANK',
        questionText: 'The kanji 日 means ___',
        options: [],
        correctAnswer: 'sun',
        points: 15,
        orderIndex: 2,
        createdAt: DateTime(2024, 1, 1),
      );

      when(
        () => mockRepository.addQuestion(
          quizId: any(named: 'quizId'),
          type: any(named: 'type'),
          questionText: any(named: 'questionText'),
          options: any(named: 'options'),
          correctAnswer: any(named: 'correctAnswer'),
          explanation: any(named: 'explanation'),
          points: any(named: 'points'),
          meanings: any(named: 'meanings'),
        ),
      ).thenAnswer((_) async => Right(fillInBlankQuestion));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        type: 'FILL_IN_BLANK',
        questionText: 'The kanji 日 means ___',
        options: [],
        correctAnswer: 'sun',
        points: 15,
      );

      // Assert
      expect(result, Right(fillInBlankQuestion));
    });

    test('should add drawing question with meanings successfully', () async {
      // Arrange
      final drawingQuestion = Question(
        id: 'q-4',
        quizId: testQuizId,
        type: 'DRAWING',
        questionText: 'Draw the kanji for "sun"',
        options: [],
        correctAnswer: '日',
        points: 20,
        orderIndex: 3,
        createdAt: DateTime(2024, 1, 1),
        meanings: ['sun', 'day'],
      );

      when(
        () => mockRepository.addQuestion(
          quizId: any(named: 'quizId'),
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
        type: 'DRAWING',
        questionText: 'Draw the kanji for "sun"',
        options: [],
        correctAnswer: '日',
        points: 20,
        meanings: ['sun', 'day'],
      );

      // Assert
      expect(result, Right(drawingQuestion));
      verify(
        () => mockRepository.addQuestion(
          quizId: testQuizId,
          type: 'DRAWING',
          questionText: 'Draw the kanji for "sun"',
          options: [],
          correctAnswer: '日',
          explanation: null,
          points: 20,
          meanings: ['sun', 'day'],
        ),
      ).called(1);
    });

    test('should use default points value of 10 when not specified', () async {
      // Arrange
      when(
        () => mockRepository.addQuestion(
          quizId: any(named: 'quizId'),
          type: any(named: 'type'),
          questionText: any(named: 'questionText'),
          options: any(named: 'options'),
          correctAnswer: any(named: 'correctAnswer'),
          explanation: any(named: 'explanation'),
          points: any(named: 'points'),
          meanings: any(named: 'meanings'),
        ),
      ).thenAnswer((_) async => Right(testQuestion));

      // Act
      await useCase(
        quizId: testQuizId,
        type: 'MULTIPLE_CHOICE',
        questionText: 'What is the meaning of 日?',
        options: ['Sun', 'Moon', 'Water', 'Fire'],
        correctAnswer: 'Sun',
        // points not specified, should default to 10
      );

      // Assert
      verify(
        () => mockRepository.addQuestion(
          quizId: testQuizId,
          type: 'MULTIPLE_CHOICE',
          questionText: 'What is the meaning of 日?',
          options: ['Sun', 'Moon', 'Water', 'Fire'],
          correctAnswer: 'Sun',
          explanation: null,
          points: 10, // default value
          meanings: const [],
        ),
      ).called(1);
    });

    test(
      'should return BadRequestFailure when question text is empty',
      () async {
        // Arrange
        const failure = BadRequestFailure('Question text cannot be empty');
        when(
          () => mockRepository.addQuestion(
            quizId: any(named: 'quizId'),
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
          type: 'MULTIPLE_CHOICE',
          questionText: '',
          options: ['A', 'B'],
          correctAnswer: 'A',
        );

        // Assert
        expect(result, const Left(failure));
      },
    );

    test(
      'should return BadRequestFailure when options are missing for multiple choice',
      () async {
        // Arrange
        const failure = BadRequestFailure('Multiple choice requires options');
        when(
          () => mockRepository.addQuestion(
            quizId: any(named: 'quizId'),
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
          type: 'MULTIPLE_CHOICE',
          questionText: 'What is this?',
          options: [],
          correctAnswer: 'Answer',
        );

        // Assert
        expect(result, const Left(failure));
      },
    );

    test('should return NotFoundFailure when quiz not found', () async {
      // Arrange
      const failure = NotFoundFailure('Quiz not found');
      when(
        () => mockRepository.addQuestion(
          quizId: any(named: 'quizId'),
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
        quizId: 'invalid-quiz-id',
        type: 'MULTIPLE_CHOICE',
        questionText: 'Question',
        options: ['A', 'B'],
        correctAnswer: 'A',
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(
        () => mockRepository.addQuestion(
          quizId: any(named: 'quizId'),
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
        type: 'MULTIPLE_CHOICE',
        questionText: 'Question',
        options: ['A', 'B'],
        correctAnswer: 'A',
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should verify added question has correct properties', () async {
      // Arrange
      when(
        () => mockRepository.addQuestion(
          quizId: any(named: 'quizId'),
          type: any(named: 'type'),
          questionText: any(named: 'questionText'),
          options: any(named: 'options'),
          correctAnswer: any(named: 'correctAnswer'),
          explanation: any(named: 'explanation'),
          points: any(named: 'points'),
          meanings: any(named: 'meanings'),
        ),
      ).thenAnswer((_) async => Right(testQuestion));

      // Act
      final result = await useCase(
        quizId: testQuizId,
        type: 'MULTIPLE_CHOICE',
        questionText: 'What is the meaning of 日?',
        options: ['Sun', 'Moon', 'Water', 'Fire'],
        correctAnswer: 'Sun',
        explanation: '日 means sun or day',
        points: 10,
      );

      // Assert
      result.fold((failure) => fail('Should not fail'), (question) {
        expect(question.id, 'q-1');
        expect(question.quizId, testQuizId);
        expect(question.type, 'MULTIPLE_CHOICE');
        expect(question.isMultipleChoice, true);
        expect(question.questionText, 'What is the meaning of 日?');
        expect(question.options, ['Sun', 'Moon', 'Water', 'Fire']);
        expect(question.correctAnswer, 'Sun');
        expect(question.explanation, '日 means sun or day');
        expect(question.points, 10);
      });
    });
  });
}
