import '../../domain/entities/quiz_entity.dart';
import '../../domain/entities/quiz_question_entity.dart';
import '../../domain/entities/quiz_attempt_entity.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_remote_datasource.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;

  QuizRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<QuizEntity>> getAllQuizzes({
    String? search,
    int? limit,
    int? offset,
  }) async {
    final quizzes = await remoteDataSource.getAllQuizzes(
      search: search,
      limit: limit,
      offset: offset,
    );
    return quizzes.map((quiz) => quiz.toEntity()).toList();
  }

  @override
  Future<QuizEntity> getQuizById(int id) async {
    final quiz = await remoteDataSource.getQuizById(id);
    return quiz.toEntity();
  }

  @override
  Future<QuizEntity> createQuiz({
    required String title,
    String? description,
  }) async {
    final quiz = await remoteDataSource.createQuiz(
      title: title,
      description: description,
    );
    return quiz.toEntity();
  }

  @override
  Future<QuizEntity> updateQuiz({
    required int id,
    String? title,
    String? description,
    bool? isPublic,
  }) async {
    final quiz = await remoteDataSource.updateQuiz(
      id: id,
      title: title,
      description: description,
      isPublic: isPublic,
    );
    return quiz.toEntity();
  }

  @override
  Future<void> deleteQuiz(int id) async {
    await remoteDataSource.deleteQuiz(id);
  }

  @override
  Future<QuizQuestionEntity> addQuestion({
    required int quizId,
    required int kanjiId,
    required String questionText,
    required String questionType,
    required List<String> options,
    required String correctAnswer,
  }) async {
    final question = await remoteDataSource.addQuestion(
      quizId: quizId,
      kanjiId: kanjiId,
      questionText: questionText,
      questionType: questionType,
      options: options,
      correctAnswer: correctAnswer,
    );
    return question.toEntity();
  }

  @override
  Future<QuizQuestionEntity> updateQuestion({
    required int quizId,
    required int questionId,
    String? questionText,
    String? questionType,
    List<String>? options,
    String? correctAnswer,
  }) async {
    final question = await remoteDataSource.updateQuestion(
      quizId: quizId,
      questionId: questionId,
      questionText: questionText,
      questionType: questionType,
      options: options,
      correctAnswer: correctAnswer,
    );
    return question.toEntity();
  }

  @override
  Future<void> deleteQuestion({
    required int quizId,
    required int questionId,
  }) async {
    await remoteDataSource.deleteQuestion(
      quizId: quizId,
      questionId: questionId,
    );
  }

  @override
  Future<void> reorderQuestions({
    required int quizId,
    required List<Map<String, int>> questionOrders,
  }) async {
    await remoteDataSource.reorderQuestions(
      quizId: quizId,
      questionOrders: questionOrders,
    );
  }

  @override
  Future<QuizAttemptEntity> startQuizAttempt(int quizId) async {
    final attempt = await remoteDataSource.startQuizAttempt(quizId);
    return attempt.toEntity();
  }

  @override
  Future<QuizAttemptEntity> submitQuizAttempt({
    required int attemptId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final attempt = await remoteDataSource.submitQuizAttempt(
      attemptId: attemptId,
      answers: answers,
    );
    return attempt.toEntity();
  }

  @override
  Future<List<QuizAttemptEntity>> getQuizAttempts(int quizId) async {
    final attempts = await remoteDataSource.getQuizAttempts(quizId);
    return attempts.map((attempt) => attempt.toEntity()).toList();
  }

  @override
  Future<QuizAttemptEntity> getQuizAttemptDetails(int attemptId) async {
    final attempt = await remoteDataSource.getQuizAttemptDetails(attemptId);
    return attempt.toEntity();
  }

  @override
  Future<void> requestPublish(int quizId, String? message) async {
    await remoteDataSource.requestPublish(quizId, message);
  }

  @override
  Future<List<dynamic>> getPendingPublishRequests() async {
    return await remoteDataSource.getPendingPublishRequests();
  }

  @override
  Future<void> approvePublishRequest(int requestId) async {
    await remoteDataSource.approvePublishRequest(requestId);
  }

  @override
  Future<void> rejectPublishRequest(int requestId) async {
    await remoteDataSource.rejectPublishRequest(requestId);
  }
}
