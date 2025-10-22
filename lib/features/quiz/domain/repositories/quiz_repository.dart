import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
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
}
