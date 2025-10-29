import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../models/quiz_attempt_model.dart';
import '../../domain/entities/question.dart';

abstract class QuizRemoteDataSource {
  // Quiz CRUD
  Future<List<QuizModel>> getQuizzes({String? search, int? limit, int? offset});
  Future<QuizModel> getQuizById(int quizId);
  Future<QuizModel> createQuiz({required String title, String? description});
  Future<QuizModel> updateQuiz({
    required int quizId,
    String? title,
    String? description,
    bool? isPublic,
  });
  Future<void> deleteQuiz(int quizId);

  // Question Management
  Future<QuestionModel> addQuestion({
    required int quizId,
    required QuestionType type,
    required String questionText,
    required String correctAnswer,
    List<String>? options,
    String? explanation,
    int? points,
    List<String>? meanings,
    int? order,
  });
  Future<QuestionModel> updateQuestion({
    required int quizId,
    required int questionId,
    QuestionType? type,
    String? questionText,
    String? correctAnswer,
    List<String>? options,
    String? explanation,
    int? points,
    List<String>? meanings,
    int? order,
  });
  Future<void> deleteQuestion({required int quizId, required int questionId});
  Future<QuizModel> reorderQuestions({
    required int quizId,
    required List<Map<String, int>> questionOrders,
  });

  // Quiz Attempts
  Future<QuizAttemptModel> startQuizAttempt(int quizId);
  Future<QuizAttemptModel> submitQuizAttempt({
    required int attemptId,
    required List<Map<String, dynamic>> answers,
    int? timeSpent,
  });
  Future<List<QuizAttemptModel>> getQuizAttempts(int quizId);
  Future<QuizAttemptModel> getQuizAttemptDetails(int attemptId);

  // Publish Request
  Future<void> requestPublish({required int quizId, String? message});
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final ApiClient apiClient;
  final SecureStorage secureStorage;

  QuizRemoteDataSourceImpl({
    required this.apiClient,
    required this.secureStorage,
  });

  Future<Options> _getAuthHeaders() async {
    final token = await secureStorage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // Extract data from response wrapper {statusCode, data: {...}, timestamp}
  // Backend quiz_new still uses this wrapper format
  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  String _questionTypeToString(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'MULTIPLE_CHOICE';
      case QuestionType.fillBlank:
        return 'FILL_IN_BLANK';
      case QuestionType.drawing:
        return 'DRAWING';
    }
  }

  @override
  Future<List<QuizModel>> getQuizzes({
    String? search,
    int? limit,
    int? offset,
  }) async {
    final options = await _getAuthHeaders();
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (limit != null) {
      queryParams['limit'] = limit;
    }
    if (offset != null) {
      queryParams['offset'] = offset;
    }

    final response = await apiClient.dio.get(
      '/quizzes',
      queryParameters: queryParams,
      options: options,
    );

    final data = _extractData(response.data);

    print('🔍 DEBUG getQuizzes - extracted data type: ${data.runtimeType}');
    print('🔍 DEBUG getQuizzes - extracted data: $data');

    // Response structure: {data: [...], total, limit, offset}
    // data is a Map with keys: data (List), total, limit, offset
    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Invalid response format: expected Map, got ${data.runtimeType}',
      );
    }

    final dataMap = data as Map<String, dynamic>;

    print('🔍 DEBUG getQuizzes - dataMap keys: ${dataMap.keys}');

    if (!dataMap.containsKey('data')) {
      throw Exception('Response missing "data" field');
    }

    final quizListData = dataMap['data'];

    print(
      '🔍 DEBUG getQuizzes - quizListData type: ${quizListData.runtimeType}',
    );
    print('🔍 DEBUG getQuizzes - quizListData: $quizListData');

    if (quizListData is! List) {
      throw Exception(
        'Invalid data format: expected List, got ${quizListData.runtimeType}',
      );
    }

    final quizList = (quizListData as List)
        .map((json) => QuizModel.fromJson(json as Map<String, dynamic>))
        .toList();

    print('🔍 DEBUG getQuizzes - quizList length: ${quizList.length}');
    print('🔍 DEBUG getQuizzes - quizList type: ${quizList.runtimeType}');
    print('🔍 DEBUG getQuizzes - returning quizList directly');

    return quizList;
  }

  @override
  Future<QuizModel> getQuizById(int quizId) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.get(
      '/quizzes/$quizId',
      options: options,
    );

    final data = _extractData(response.data);
    return QuizModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<QuizModel> createQuiz({
    required String title,
    String? description,
  }) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.post(
      '/quizzes',
      data: {
        'title': title,
        if (description != null) 'description': description,
      },
      options: options,
    );

    final data = _extractData(response.data);
    return QuizModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<QuizModel> updateQuiz({
    required int quizId,
    String? title,
    String? description,
    bool? isPublic,
  }) async {
    final options = await _getAuthHeaders();
    final requestBody = <String, dynamic>{};
    if (title != null) requestBody['title'] = title;
    if (description != null) requestBody['description'] = description;
    if (isPublic != null) requestBody['isPublic'] = isPublic;

    final response = await apiClient.dio.put(
      '/quizzes/$quizId',
      data: requestBody,
      options: options,
    );

    final data = _extractData(response.data);
    return QuizModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteQuiz(int quizId) async {
    final options = await _getAuthHeaders();
    await apiClient.dio.delete('/quizzes/$quizId', options: options);
  }

  // ============ QUESTION MANAGEMENT ============

  @override
  Future<QuestionModel> addQuestion({
    required int quizId,
    required QuestionType type,
    required String questionText,
    required String correctAnswer,
    List<String>? options,
    String? explanation,
    int? points,
    List<String>? meanings,
    int? order,
  }) async {
    final authOptions = await _getAuthHeaders();

    final requestBody = {
      'type': _questionTypeToString(type),
      'questionText': questionText,
      'correctAnswer': correctAnswer,
      if (options != null && options.isNotEmpty) 'options': options,
      if (explanation != null && explanation.isNotEmpty)
        'explanation': explanation,
      if (points != null) 'points': points,
      if (meanings != null && meanings.isNotEmpty) 'meanings': meanings,
      if (order != null) 'order': order,
    };

    print('🔵 DEBUG addQuestion - quizId: $quizId');
    print('🔵 DEBUG addQuestion - requestBody: $requestBody');

    final response = await apiClient.dio.post(
      '/quizzes/$quizId/questions',
      data: requestBody,
      options: authOptions,
    );

    final data = _extractData(response.data);
    return QuestionModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<QuestionModel> updateQuestion({
    required int quizId,
    required int questionId,
    QuestionType? type,
    String? questionText,
    String? correctAnswer,
    List<String>? options,
    String? explanation,
    int? points,
    List<String>? meanings,
    int? order,
  }) async {
    final authOptions = await _getAuthHeaders();
    final requestBody = <String, dynamic>{};
    if (type != null) requestBody['type'] = _questionTypeToString(type);
    if (questionText != null) requestBody['questionText'] = questionText;
    if (correctAnswer != null) requestBody['correctAnswer'] = correctAnswer;
    if (options != null) requestBody['options'] = options;
    if (explanation != null) requestBody['explanation'] = explanation;
    if (points != null) requestBody['points'] = points;
    if (meanings != null) requestBody['meanings'] = meanings;
    if (order != null) requestBody['order'] = order;

    final response = await apiClient.dio.put(
      '/quizzes/$quizId/questions/$questionId',
      data: requestBody,
      options: authOptions,
    );

    final data = _extractData(response.data);
    return QuestionModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteQuestion({
    required int quizId,
    required int questionId,
  }) async {
    final options = await _getAuthHeaders();
    await apiClient.dio.delete(
      '/quizzes/$quizId/questions/$questionId',
      options: options,
    );
  }

  @override
  Future<QuizModel> reorderQuestions({
    required int quizId,
    required List<Map<String, int>> questionOrders,
  }) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.put(
      '/quizzes/$quizId/questions/reorder',
      data: {'questionOrders': questionOrders},
      options: options,
    );

    final data = _extractData(response.data);
    return QuizModel.fromJson(data as Map<String, dynamic>);
  }

  // ============ QUIZ ATTEMPTS ============

  @override
  Future<QuizAttemptModel> startQuizAttempt(int quizId) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.post(
      '/quizzes/$quizId/start',
      options: options,
    );

    final data = _extractData(response.data);
    return QuizAttemptModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<QuizAttemptModel> submitQuizAttempt({
    required int attemptId,
    required List<Map<String, dynamic>> answers,
    int? timeSpent,
  }) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.post(
      '/quizzes/attempts/$attemptId/submit',
      data: {'answers': answers, if (timeSpent != null) 'timeSpent': timeSpent},
      options: options,
    );

    final data = _extractData(response.data);
    return QuizAttemptModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<QuizAttemptModel>> getQuizAttempts(int quizId) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.get(
      '/quizzes/$quizId/attempts',
      options: options,
    );

    final data = _extractData(response.data);
    return (data as List)
        .map((json) => QuizAttemptModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<QuizAttemptModel> getQuizAttemptDetails(int attemptId) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.get(
      '/quizzes/attempts/$attemptId',
      options: options,
    );

    final data = _extractData(response.data);
    return QuizAttemptModel.fromJson(data as Map<String, dynamic>);
  }

  // ============ PUBLISH REQUEST ============

  @override
  Future<void> requestPublish({required int quizId, String? message}) async {
    final options = await _getAuthHeaders();
    await apiClient.dio.post(
      '/quizzes/$quizId/publish-request',
      data: {if (message != null) 'message': message},
      options: options,
    );
  }
}
