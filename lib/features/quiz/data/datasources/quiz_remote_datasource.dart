import '../../../../core/network/api_client.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../models/quiz_attempt_model.dart';
import '../models/quiz_answer_model.dart';

abstract class QuizRemoteDataSource {
  Future<List<QuizModel>> getQuizzes({
    bool? myQuizzes,
    bool? isPublic,
    String? category,
    String? difficulty,
  });
  Future<QuizModel> getQuizById(int quizId);
  Future<QuizModel> createQuiz(Map<String, dynamic> data);
  Future<QuizModel> updateQuiz(int quizId, Map<String, dynamic> data);
  Future<void> deleteQuiz(int quizId);

  Future<QuestionModel> addQuestion(int quizId, Map<String, dynamic> data);
  Future<void> deleteQuestion(int questionId);

  Future<QuizAttemptModel> startQuiz(int quizId);
  Future<QuizAnswerModel> submitAnswer(Map<String, dynamic> data);
  Future<QuizAttemptModel> getAttemptResults(int attemptId);
  Future<List<QuizAttemptModel>> getUserAttempts({int? quizId});
  Future<Map<String, dynamic>> getQuizStatistics(int quizId);
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final ApiClient apiClient;

  QuizRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<QuizModel>> getQuizzes({
    bool? myQuizzes,
    bool? isPublic,
    String? category,
    String? difficulty,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (myQuizzes != null) {
        queryParameters['my_quizzes'] = myQuizzes.toString();
      }
      if (isPublic != null) queryParameters['public'] = isPublic.toString();
      if (category != null) queryParameters['category'] = category;
      if (difficulty != null) queryParameters['difficulty'] = difficulty;

      final response = await apiClient.get(
        '/quiz',
        queryParameters: queryParameters,
      );

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] ?? responseData;

      if (data is! List) {
        print('ERROR: Expected List but got ${data.runtimeType}');
        print('Response data: $responseData');
        throw Exception('Invalid response format: expected List');
      }

      return data
          .map((q) => QuizModel.fromJson(q as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error in getQuizzes: $e');
      rethrow;
    }
  }

  @override
  Future<QuizModel> getQuizById(int quizId) async {
    final response = await apiClient.get('/quiz/$quizId');
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] ?? responseData;
    return QuizModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<QuizModel> createQuiz(Map<String, dynamic> data) async {
    final response = await apiClient.post('/quiz', data);
    final responseData = response.data as Map<String, dynamic>;
    final quizData = responseData['data'] ?? responseData;
    return QuizModel.fromJson(quizData as Map<String, dynamic>);
  }

  @override
  Future<QuizModel> updateQuiz(int quizId, Map<String, dynamic> data) async {
    final response = await apiClient.put('/quiz/$quizId', data);
    final responseData = response.data as Map<String, dynamic>;
    final quizData = responseData['data'] ?? responseData;
    return QuizModel.fromJson(quizData as Map<String, dynamic>);
  }

  @override
  Future<void> deleteQuiz(int quizId) async {
    await apiClient.delete('/quiz/$quizId');
  }

  @override
  Future<QuestionModel> addQuestion(
    int quizId,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.post('/quiz/$quizId/question', data);
    final responseData = response.data as Map<String, dynamic>;
    final questionData = responseData['data'] ?? responseData;
    return QuestionModel.fromJson(questionData as Map<String, dynamic>);
  }

  @override
  Future<void> deleteQuestion(int questionId) async {
    await apiClient.delete('/quiz/question/$questionId');
  }

  @override
  Future<QuizAttemptModel> startQuiz(int quizId) async {
    final response = await apiClient.post('/quiz/start', {'quiz_id': quizId});
    final responseData = response.data as Map<String, dynamic>;
    final attemptData = responseData['data'] ?? responseData;
    return QuizAttemptModel.fromJson(attemptData as Map<String, dynamic>);
  }

  @override
  Future<QuizAnswerModel> submitAnswer(Map<String, dynamic> data) async {
    final response = await apiClient.post('/quiz/answer', data);
    final responseData = response.data as Map<String, dynamic>;
    final answerData = responseData['data'] ?? responseData;
    return QuizAnswerModel.fromJson(answerData as Map<String, dynamic>);
  }

  @override
  Future<QuizAttemptModel> getAttemptResults(int attemptId) async {
    final response = await apiClient.get('/quiz/attempt/$attemptId');
    final responseData = response.data as Map<String, dynamic>;
    final attemptData = responseData['data'] ?? responseData;
    return QuizAttemptModel.fromJson(attemptData as Map<String, dynamic>);
  }

  @override
  Future<List<QuizAttemptModel>> getUserAttempts({int? quizId}) async {
    final queryParameters = <String, dynamic>{};
    if (quizId != null) queryParameters['quiz_id'] = quizId.toString();

    final response = await apiClient.get(
      '/quiz/my-attempts',
      queryParameters: queryParameters,
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] ?? responseData;

    return (data as List)
        .map((a) => QuizAttemptModel.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getQuizStatistics(int quizId) async {
    final response = await apiClient.get('/quiz/$quizId/statistics');
    final responseData = response.data as Map<String, dynamic>;
    return responseData['data'] ?? responseData;
  }
}
