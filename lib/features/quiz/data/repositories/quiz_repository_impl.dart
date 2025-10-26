import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/quiz_result.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_remote_datasource.dart';

/// Implementation of QuizRepository
class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;

  QuizRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Quiz>>> getAllQuizzes() async {
    try {
      final quizzes = await remoteDataSource.getAllQuizzes();
      return Right(quizzes);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Quiz>> getQuizById(String quizId) async {
    try {
      final quiz = await remoteDataSource.getQuizById(quizId);
      return Right(quiz);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Question>>> getQuizQuestions(
    String quizId,
  ) async {
    try {
      final questions = await remoteDataSource.getQuizQuestions(quizId);
      return Right(questions);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> submitAnswer({
    required String quizId,
    required String questionId,
    required String answer,
  }) async {
    try {
      final isCorrect = await remoteDataSource.submitAnswer(
        quizId: quizId,
        questionId: questionId,
        answer: answer,
      );
      return Right(isCorrect);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuizResult>> completeQuiz({
    required String quizId,
    required int timeSpent,
  }) async {
    try {
      final result = await remoteDataSource.completeQuiz(
        quizId: quizId,
        timeSpent: timeSpent,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuizResult>>> getQuizHistory() async {
    try {
      final history = await remoteDataSource.getQuizHistory();
      return Right(history);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuizResult>> getQuizResultById(String resultId) async {
    try {
      final result = await remoteDataSource.getQuizResultById(resultId);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuizResult>>> getQuizAttempts(
    String quizId,
  ) async {
    try {
      final attempts = await remoteDataSource.getQuizAttempts(quizId);
      return Right(attempts);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuizResult?>> getBestScore(String quizId) async {
    try {
      final bestScore = await remoteDataSource.getBestScore(quizId);
      return Right(bestScore);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> startQuiz(String quizId) async {
    try {
      final sessionId = await remoteDataSource.startQuiz(quizId);
      return Right(sessionId);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> retryQuiz(String quizId) async {
    try {
      await remoteDataSource.retryQuiz(quizId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Question>> addQuestion({
    required String quizId,
    required String type,
    required String questionText,
    required List<String> options,
    required String correctAnswer,
    String? explanation,
    int points = 10,
    List<String> meanings = const [],
  }) async {
    try {
      final question = await remoteDataSource.addQuestion(
        quizId: quizId,
        type: type,
        questionText: questionText,
        options: options,
        correctAnswer: correctAnswer,
        explanation: explanation,
        points: points,
        meanings: meanings,
      );
      return Right(question);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final question = await remoteDataSource.updateQuestion(
        quizId: quizId,
        questionId: questionId,
        type: type,
        questionText: questionText,
        options: options,
        correctAnswer: correctAnswer,
        explanation: explanation,
        points: points,
        meanings: meanings,
      );
      return Right(question);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteQuestion({
    required String quizId,
    required String questionId,
  }) async {
    try {
      await remoteDataSource.deleteQuestion(
        quizId: quizId,
        questionId: questionId,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Handle Dio errors and convert to Failure
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Request timeout. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return UnauthorizedFailure('Unauthorized access');
        } else if (statusCode == 404) {
          return NotFoundFailure('Quiz not found');
        } else if (statusCode == 500) {
          return ServerFailure('Server error. Please try again later.');
        }
        return ServerFailure(
          error.response?.data['message'] ?? 'Server error occurred',
        );

      case DioExceptionType.connectionError:
        return NetworkFailure(
          'No internet connection. Please check your network.',
        );

      default:
        return UnknownFailure('An unexpected error occurred');
    }
  }
}
