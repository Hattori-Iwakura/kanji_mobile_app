import '../../domain/entities/quiz.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/quiz_attempt.dart';
import '../../domain/entities/quiz_answer.dart';
import '../../domain/entities/quiz_enums.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_remote_datasource.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;

  QuizRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Quiz>> getQuizzes({
    bool? myQuizzes,
    bool? isPublic,
    String? category,
    QuizDifficulty? difficulty,
  }) async {
    try {
      final quizzes = await remoteDataSource.getQuizzes(
        myQuizzes: myQuizzes,
        isPublic: isPublic,
        category: category,
        difficulty: difficulty?.value,
      );
      return quizzes.map((q) => q.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to load quizzes: $e');
    }
  }

  @override
  Future<Quiz> getQuizById(int quizId) async {
    try {
      final quiz = await remoteDataSource.getQuizById(quizId);
      return quiz.toEntity();
    } catch (e) {
      throw Exception('Failed to load quiz: $e');
    }
  }

  @override
  Future<Quiz> createQuiz(Map<String, dynamic> data) async {
    try {
      final quiz = await remoteDataSource.createQuiz(data);
      return quiz.toEntity();
    } catch (e) {
      throw Exception('Failed to create quiz: $e');
    }
  }

  @override
  Future<Quiz> updateQuiz(int quizId, Map<String, dynamic> data) async {
    try {
      final quiz = await remoteDataSource.updateQuiz(quizId, data);
      return quiz.toEntity();
    } catch (e) {
      throw Exception('Failed to update quiz: $e');
    }
  }

  @override
  Future<void> deleteQuiz(int quizId) async {
    try {
      await remoteDataSource.deleteQuiz(quizId);
    } catch (e) {
      throw Exception('Failed to delete quiz: $e');
    }
  }

  @override
  Future<Question> addQuestion(int quizId, Map<String, dynamic> data) async {
    try {
      final question = await remoteDataSource.addQuestion(quizId, data);
      return question.toEntity();
    } catch (e) {
      throw Exception('Failed to add question: $e');
    }
  }

  @override
  Future<void> deleteQuestion(int questionId) async {
    try {
      await remoteDataSource.deleteQuestion(questionId);
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  @override
  Future<QuizAttempt> startQuiz(int quizId) async {
    try {
      final attempt = await remoteDataSource.startQuiz(quizId);
      return attempt.toEntity();
    } catch (e) {
      throw Exception('Failed to start quiz: $e');
    }
  }

  @override
  Future<QuizAnswer> submitAnswer(Map<String, dynamic> data) async {
    try {
      final answer = await remoteDataSource.submitAnswer(data);
      return answer.toEntity();
    } catch (e) {
      throw Exception('Failed to submit answer: $e');
    }
  }

  @override
  Future<QuizAttempt> getAttemptResults(int attemptId) async {
    try {
      final attempt = await remoteDataSource.getAttemptResults(attemptId);
      return attempt.toEntity();
    } catch (e) {
      throw Exception('Failed to load results: $e');
    }
  }

  @override
  Future<List<QuizAttempt>> getUserAttempts({int? quizId}) async {
    try {
      final attempts = await remoteDataSource.getUserAttempts(quizId: quizId);
      return attempts.map((a) => a.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to load attempts: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getQuizStatistics(int quizId) async {
    try {
      return await remoteDataSource.getQuizStatistics(quizId);
    } catch (e) {
      throw Exception('Failed to load statistics: $e');
    }
  }
}
