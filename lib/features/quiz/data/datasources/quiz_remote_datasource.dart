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

  /// Add a new question to a quiz
  Future<QuestionModel> addQuestion({
    required String quizId,
    required String type,
    required String questionText,
    required List<String> options,
    required String correctAnswer,
    String? explanation,
    int points = 10,
    List<String> meanings = const [],
  }) async {
    final response = await dioClient.dio.post(
      '${ApiEndpoints.quizzes}/$quizId/questions',
      data: {
        'type': type,
        'questionText': questionText,
        'options': options,
        'correctAnswer': correctAnswer,
        if (explanation != null) 'explanation': explanation,
        'points': points,
        'meanings': meanings,
      },
    );
    return QuestionModel.fromJson(response.data);
  }

  /// Update an existing question
  Future<QuestionModel> updateQuestion({
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
    final response = await dioClient.dio.put(
      '${ApiEndpoints.quizzes}/$quizId/questions/$questionId',
      data: {
        if (type != null) 'type': type,
        if (questionText != null) 'questionText': questionText,
        if (options != null) 'options': options,
        if (correctAnswer != null) 'correctAnswer': correctAnswer,
        if (explanation != null) 'explanation': explanation,
        if (points != null) 'points': points,
        if (meanings != null) 'meanings': meanings,
      },
    );
    return QuestionModel.fromJson(response.data);
  }

  /// Delete a question from a quiz
  Future<void> deleteQuestion({
    required String quizId,
    required String questionId,
  }) async {
    await dioClient.dio.delete(
      '${ApiEndpoints.quizzes}/$quizId/questions/$questionId',
    );
  }
}
