import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';

/// Remote data source for quiz operations
class QuizRemoteDataSource {
  final DioClient dioClient;

  QuizRemoteDataSource(this.dioClient);

  /// Get all quizzes
  Future<List<QuizModel>> getAllQuizzes() async {
    final response = await dioClient.dio.get(ApiEndpoints.quizzes);
    return (response.data as List)
        .map((json) => QuizModel.fromJson(json))
        .toList();
  }

  /// Get quiz by ID
  Future<QuizModel> getQuizById(String quizId) async {
    final response = await dioClient.dio.get('${ApiEndpoints.quizzes}/$quizId');
    return QuizModel.fromJson(response.data);
  }

  /// Get questions for a quiz
  Future<List<QuestionModel>> getQuizQuestions(String quizId) async {
    final response = await dioClient.dio.get(
      '${ApiEndpoints.quizzes}/$quizId/questions',
    );
    return (response.data as List)
        .map((json) => QuestionModel.fromJson(json))
        .toList();
  }

  /// Submit quiz answer
  Future<bool> submitAnswer({
    required String quizId,
    required String questionId,
    required String answer,
  }) async {
    final response = await dioClient.dio.post(
      '${ApiEndpoints.quizzes}/$quizId/answer',
      data: {'questionId': questionId, 'answer': answer},
    );
    return response.data['isCorrect'] as bool;
  }

  /// Complete quiz and get result
  Future<QuizResultModel> completeQuiz({
    required String quizId,
    required int timeSpent,
  }) async {
    final response = await dioClient.dio.post(
      '${ApiEndpoints.quizzes}/$quizId/complete',
      data: {'timeSpent': timeSpent},
    );
    return QuizResultModel.fromJson(response.data);
  }

  /// Get quiz history for current user
  Future<List<QuizResultModel>> getQuizHistory() async {
    final response = await dioClient.dio.get(ApiEndpoints.quizHistory);
    return (response.data as List)
        .map((json) => QuizResultModel.fromJson(json))
        .toList();
  }

  /// Get quiz result by ID
  Future<QuizResultModel> getQuizResultById(String resultId) async {
    final response = await dioClient.dio.get(
      '${ApiEndpoints.quizHistory}/$resultId',
    );
    return QuizResultModel.fromJson(response.data);
  }

  /// Get quiz attempts for a specific quiz
  Future<List<QuizResultModel>> getQuizAttempts(String quizId) async {
    final response = await dioClient.dio.get(
      '${ApiEndpoints.quizzes}/$quizId/attempts',
    );
    return (response.data as List)
        .map((json) => QuizResultModel.fromJson(json))
        .toList();
  }

  /// Get user's best score for a quiz
  Future<QuizResultModel?> getBestScore(String quizId) async {
    final response = await dioClient.dio.get(
      '${ApiEndpoints.quizzes}/$quizId/best-score',
    );
    if (response.data == null) return null;
    return QuizResultModel.fromJson(response.data);
  }

  /// Start quiz session
  Future<String> startQuiz(String quizId) async {
    final response = await dioClient.dio.post(
      '${ApiEndpoints.quizzes}/$quizId/start',
    );
    return response.data['sessionId'] as String;
  }

  /// Retry quiz (reset progress)
  Future<void> retryQuiz(String quizId) async {
    await dioClient.dio.post('${ApiEndpoints.quizzes}/$quizId/retry');
  }
}
