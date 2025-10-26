import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/quiz.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/get_all_quizzes.dart';

// Mock repository
class MockQuizRepository extends Mock implements QuizRepository {}

void main() {
  late GetAllQuizzes useCase;
  late MockQuizRepository mockRepository;

  setUp(() {
    mockRepository = MockQuizRepository();
    useCase = GetAllQuizzes(mockRepository);
  });

  group('GetAllQuizzes', () {
    final testQuizzes = [
      Quiz(
        id: '1',
        title: 'JLPT N5 Quiz',
        description: 'Basic kanji quiz',
        difficulty: 'EASY',
        totalQuestions: 10,
        timeLimit: 600,
        passingScore: 70,
        isPublished: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      Quiz(
        id: '2',
        title: 'JLPT N4 Quiz',
        description: 'Intermediate kanji quiz',
        difficulty: 'MEDIUM',
        totalQuestions: 20,
        timeLimit: 1200,
        passingScore: 75,
        isPublished: true,
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
      ),
    ];

    test('should get all quizzes from repository', () async {
      // Arrange
      when(
        () => mockRepository.getAllQuizzes(),
      ).thenAnswer((_) async => Right(testQuizzes));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Right(testQuizzes));
      verify(() => mockRepository.getAllQuizzes()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no quizzes available', () async {
      // Arrange
      when(
        () => mockRepository.getAllQuizzes(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase();

      // Assert
      result.fold(
        (failure) => fail('Should not fail'),
        (quizzes) => expect(quizzes, isEmpty),
      );
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      when(
        () => mockRepository.getAllQuizzes(),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getAllQuizzes()).called(1);
    });

    test('should return NetworkFailure when no connection', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(
        () => mockRepository.getAllQuizzes(),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left(failure));
    });

    test('should return quizzes with correct properties', () async {
      // Arrange
      when(
        () => mockRepository.getAllQuizzes(),
      ).thenAnswer((_) async => Right(testQuizzes));

      // Act
      final result = await useCase();

      // Assert
      result.fold((failure) => fail('Should not fail'), (quizzes) {
        expect(quizzes.length, 2);
        expect(quizzes[0].id, '1');
        expect(quizzes[0].title, 'JLPT N5 Quiz');
        expect(quizzes[0].difficulty, 'EASY');
        expect(quizzes[0].totalQuestions, 10);
        expect(quizzes[0].hasTimeLimit, true);
        expect(quizzes[1].id, '2');
        expect(quizzes[1].difficulty, 'MEDIUM');
      });
    });
  });
}
