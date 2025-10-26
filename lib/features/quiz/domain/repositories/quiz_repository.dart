import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/quiz.dart';
import '../entities/question.dart';
import '../entities/quiz_result.dart';

/// Repository interface for quiz operations
abstract class QuizRepository {
  /// Get all available quizzes
  Future<Either<Failure, List<Quiz>>> getAllQuizzes();

  /// Get quiz by ID
  Future<Either<Failure, Quiz>> getQuizById(String quizId);

  /// Get questions for a quiz
  Future<Either<Failure, List<Question>>> getQuizQuestions(String quizId);

  /// Submit quiz answer
  Future<Either<Failure, bool>> submitAnswer({
    required String quizId,
    required String questionId,
    required String answer,
  });

  /// Complete quiz and get result
  Future<Either<Failure, QuizResult>> completeQuiz({
    required String quizId,
    required int timeSpent,
  });

  /// Get quiz history for current user
  Future<Either<Failure, List<QuizResult>>> getQuizHistory();

  /// Get quiz result by ID
  Future<Either<Failure, QuizResult>> getQuizResultById(String resultId);

  /// Get quiz attempts for a specific quiz
  Future<Either<Failure, List<QuizResult>>> getQuizAttempts(String quizId);

  /// Get user's best score for a quiz
  Future<Either<Failure, QuizResult?>> getBestScore(String quizId);

  /// Start quiz session
  Future<Either<Failure, String>> startQuiz(String quizId);

  /// Retry quiz (reset progress)
  Future<Either<Failure, void>> retryQuiz(String quizId);

  /// Add question to quiz
  Future<Either<Failure, Question>> addQuestion({
    required String quizId,
    required String type,
    required String questionText,
    required List<String> options,
    required String correctAnswer,
    String? explanation,
    int points = 10,
    List<String> meanings = const [],
  });

  /// Update question in quiz
  Future<Either<Failure, Question>> updateQuestion({
    required String quizId,
    required String questionId,
    String? type,
    String? questionText,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    int? points,
    List<String>? meanings,
  });

  /// Delete question from quiz
  Future<Either<Failure, void>> deleteQuestion({
    required String quizId,
    required String questionId,
  });
}
