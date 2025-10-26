import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/question.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/get_quiz_questions.dart';

// Mock repository
class MockQuizRepository extends Mock implements QuizRepository {}

void main() {
  late GetQuizQuestions useCase;
  late MockQuizRepository mockRepository;

  setUp(() {
    mockRepository = MockQuizRepository();
    useCase = GetQuizQuestions(mockRepository);
  });

  group('GetQuizQuestions', () {
    const testQuizId = 'quiz-1';
    final testQuestions = [
      Question(
        id: 'q1',
        quizId: testQuizId,
        type: 'MULTIPLE_CHOICE',
        questionText: 'What is the reading of 日?',
        options: ['にち', 'げつ', 'か', 'すい'],
        correctAnswer: 'にち',
        explanation: '日 is read as "にち" for day/sun',
        points: 10,
        orderIndex: 0,
        createdAt: DateTime(2024, 1, 1),
      ),
      Question(
        id: 'q2',
        quizId: testQuizId,
        type: 'TRUE_FALSE',
        questionText: '月 means "moon"',
        options: ['True', 'False'],
        correctAnswer: 'True',
        explanation: '月 (げつ/つき) means moon/month',
        points: 5,
        orderIndex: 1,
        createdAt: DateTime(2024, 1, 1),
      ),
    ];

    test('should get questions for specific quiz', () async {
      // Arrange
      when(
        () => mockRepository.getQuizQuestions(testQuizId),
      ).thenAnswer((_) async => Right(testQuestions));

      // Act
      final result = await useCase(testQuizId);

      // Assert
      expect(result, Right(testQuestions));
      verify(() => mockRepository.getQuizQuestions(testQuizId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when quiz has no questions', () async {
      // Arrange
      when(
        () => mockRepository.getQuizQuestions(testQuizId),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(testQuizId);

      // Assert
      result.fold(
        (failure) => fail('Should not fail'),
        (questions) => expect(questions, isEmpty),
      );
    });

    test('should return questions with correct properties', () async {
      // Arrange
      when(
        () => mockRepository.getQuizQuestions(testQuizId),
      ).thenAnswer((_) async => Right(testQuestions));

      // Act
      final result = await useCase(testQuizId);

      // Assert
      result.fold((failure) => fail('Should not fail'), (questions) {
        expect(questions.length, 2);
        expect(questions[0].id, 'q1');
        expect(questions[0].type, 'MULTIPLE_CHOICE');
        expect(questions[0].isMultipleChoice, true);
        expect(questions[0].options.length, 4);
        expect(questions[0].correctAnswer, 'にち');
        expect(questions[1].id, 'q2');
        expect(questions[1].type, 'TRUE_FALSE');
        expect(questions[1].isTrueFalse, true);
      });
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      const failure = ServerFailure('Quiz not found');
      when(
        () => mockRepository.getQuizQuestions(testQuizId),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(testQuizId);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getQuizQuestions(testQuizId)).called(1);
    });

    test('should return NetworkFailure when no connection', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(
        () => mockRepository.getQuizQuestions(testQuizId),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(testQuizId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should get questions for different quiz IDs', () async {
      // Arrange
      const anotherQuizId = 'quiz-2';
      final otherQuestions = [
        Question(
          id: 'q3',
          quizId: anotherQuizId,
          type: 'FILL_IN_BLANK',
          questionText: 'The kanji for water is ___',
          options: [],
          correctAnswer: '水',
          points: 15,
          orderIndex: 0,
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      when(
        () => mockRepository.getQuizQuestions(anotherQuizId),
      ).thenAnswer((_) async => Right(otherQuestions));

      // Act
      final result = await useCase(anotherQuizId);

      // Assert
      result.fold((failure) => fail('Should not fail'), (questions) {
        expect(questions.length, 1);
        expect(questions[0].quizId, anotherQuizId);
        expect(questions[0].isFillInBlank, true);
      });
    });
  });
}
