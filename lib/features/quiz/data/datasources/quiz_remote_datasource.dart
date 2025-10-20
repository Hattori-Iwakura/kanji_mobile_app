import 'package:dio/dio.dart';
import '../../../../core/network/endpoint.dart';
import '../models/quiz.dart';
import '../models/quiz_question.dart';
import '../models/quiz_attempt.dart';
import '../../domain/entities/quiz_exception.dart';

abstract class QuizRemoteDataSource {
  // Quiz CRUD
  Future<List<Quiz>> getAllQuizzes({String? search, int? limit, int? offset});
  Future<Quiz> getQuizById(int id);
  Future<Quiz> createQuiz({required String title, String? description});
  Future<Quiz> updateQuiz({
    required int id,
    String? title,
    String? description,
    bool? isPublic,
  });
  Future<void> deleteQuiz(int id);

  // Question Management
  Future<QuizQuestion> addQuestion({
    required int quizId,
    required int kanjiId,
    required String questionText,
    required String questionType,
    required List<String> options,
    required String correctAnswer,
  });
  Future<QuizQuestion> updateQuestion({
    required int quizId,
    required int questionId,
    String? questionText,
    String? questionType,
    List<String>? options,
    String? correctAnswer,
  });
  Future<void> deleteQuestion({required int quizId, required int questionId});
  Future<void> reorderQuestions({
    required int quizId,
    required List<Map<String, int>> questionOrders,
  });

  // Quiz Attempts
  Future<QuizAttempt> startQuizAttempt(int quizId);
  Future<QuizAttempt> submitQuizAttempt({
    required int attemptId,
    required List<Map<String, dynamic>> answers,
  });
  Future<List<QuizAttempt>> getQuizAttempts(int quizId);
  Future<QuizAttempt> getQuizAttemptDetails(int attemptId);

  // Publish Workflow
  Future<void> requestPublish(int quizId, String? message);
  Future<List<dynamic>> getPendingPublishRequests();
  Future<void> approvePublishRequest(int requestId);
  Future<void> rejectPublishRequest(int requestId);
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final Dio dio;

  QuizRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Quiz>> getAllQuizzes({
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await dio.get(
        ApiEndpoints.quizzes,
        queryParameters: queryParams,
      );
      return (response.data as List)
          .map((json) => Quiz.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw QuizException(
        message: e.response?.data['message'] ?? 'Failed to get quizzes',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Quiz> getQuizById(int id) async {
    try {
      final response = await dio.get('${ApiEndpoints.quizzes}/$id');
      return Quiz.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw QuizException(
        message: e.response?.data['message'] ?? 'Failed to get quiz',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Quiz> createQuiz({required String title, String? description}) async {
    try {
      final response = await dio.post(
        ApiEndpoints.quizzes,
        data: {
          'title': title,
          if (description != null) 'description': description,
        },
      );
      return Quiz.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw QuizException(
        message: e.response?.data['message'] ?? 'Failed to create quiz',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Quiz> updateQuiz({
    required int id,
    String? title,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final response = await dio.put(
        '${ApiEndpoints.quizzes}/$id',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (isPublic != null) 'isPublic': isPublic,
        },
      );
      return Quiz.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw QuizException(
        message: e.response?.data['message'] ?? 'Failed to update quiz',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteQuiz(int id) async {
    try {
      await dio.delete('${ApiEndpoints.quizzes}/$id');
    } on DioException catch (e) {
      throw QuizException(
        message: e.response?.data['message'] ?? 'Failed to delete quiz',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<QuizQuestion> addQuestion({
    required int quizId,
    required int kanjiId,
    required String questionText,
    required String questionType,
    required List<String> options,
    required String correctAnswer,
  }) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.quizzes}/$quizId/questions',
        data: {
          'kanjiId': kanjiId,
          'questionText': questionText,
          'questionType': questionType,
          'options': options,
          'correctAnswer': correctAnswer,
        },
      );
      return QuizQuestion.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw QuizException(
        message: e.response?.data['message'] ?? 'Failed to add question',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<QuizQuestion> updateQuestion({
    required int quizId,
    required int questionId,
    String? questionText,
    String? questionType,
    List<String>? options,
    String? correctAnswer,
  }) async {
    try {
      final response = await dio.put(
        '${ApiEndpoints.quizzes}/$quizId/questions/$questionId',
        data: {
          if (questionText != null) 'questionText': questionText,
          if (questionType != null) 'questionType': questionType,
          if (options != null) 'options': options,
          if (correctAnswer != null) 'correctAnswer': correctAnswer,
        },
      );
      return QuizQuestion.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw QuizException(
        message: e.response?.data['message'] ?? 'Failed to update question',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteQuestion({
    required int quizId,
    required int questionId,
  }) async {
    try {
      await dio.delete('${ApiEndpoints.quizzes}/$quizId/questions/$questionId');
    } on DioException catch (e) {
      throw QuizException(
        message: e.response?.data['message'] ?? 'Failed to delete question',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> reorderQuestions({
    required int quizId,
    required List<Map<String, int>> questionOrders,
  }) async {
    try {
      await dio.put(
        '${ApiEndpoints.quizzes}/$quizId/questions/reorder',
        data: {'questionOrders': questionOrders},
      );
    } on DioException catch (e) {
      throw QuizException(
        message: e.response?.data['message'] ?? 'Failed to reorder questions',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<QuizAttempt> startQuizAttempt(int quizId) async {
    try {
      final response = await dio.post('${ApiEndpoints.quizzes}/$quizId/start');
      return QuizAttempt.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw QuizException(
        message: e.response?.data['message'] ?? 'Failed to start quiz attempt',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<QuizAttempt> submitQuizAttempt({
    required int attemptId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.quizzes}/attempts/$attemptId/submit',
        data: {'answers': answers},
      );
      return QuizAttempt.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw QuizException(
        message: e.response?.data['message'] ?? 'Failed to submit quiz attempt',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<QuizAttempt>> getQuizAttempts(int quizId) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.quizzes}/$quizId/attempts',
      );
      return (response.data as List)
          .map((json) => QuizAttempt.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw QuizException(
        message: e.response?.data['message'] ?? 'Failed to get quiz attempts',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<QuizAttempt> getQuizAttemptDetails(int attemptId) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.quizzes}/attempts/$attemptId',
      );
      return QuizAttempt.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw QuizException(
        message: e.response?.data['message'] ?? 'Failed to get attempt details',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> requestPublish(int quizId, String? message) async {
    try {
      await dio.post(
        '${ApiEndpoints.quizzes}/$quizId/publish-request',
        data: {if (message != null) 'message': message},
      );
    } on DioException catch (e) {
      throw QuizException(
        message: e.response?.data['message'] ?? 'Failed to request publish',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<dynamic>> getPendingPublishRequests() async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.quizzes}/admin/publish-requests',
      );
      return response.data as List;
    } on DioException catch (e) {
      throw QuizException(
        message:
            e.response?.data['message'] ?? 'Failed to get publish requests',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> approvePublishRequest(int requestId) async {
    try {
      await dio.put(
        '${ApiEndpoints.quizzes}/admin/publish-requests/$requestId',
        data: {'action': 'approve'},
      );
    } on DioException catch (e) {
      throw QuizException(
        message:
            e.response?.data['message'] ?? 'Failed to approve publish request',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> rejectPublishRequest(int requestId) async {
    try {
      await dio.put(
        '${ApiEndpoints.quizzes}/admin/publish-requests/$requestId',
        data: {'action': 'reject'},
      );
    } on DioException catch (e) {
      throw QuizException(
        message:
            e.response?.data['message'] ?? 'Failed to reject publish request',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
