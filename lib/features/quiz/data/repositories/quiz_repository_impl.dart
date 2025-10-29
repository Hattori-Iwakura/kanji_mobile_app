import '../../domain/entities/quiz.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/quiz_attempt.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_remote_datasource.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;

  QuizRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Quiz>> getQuizzes({
    String? search,
    int? limit,
    int? offset,
  }) async {
    print('🔍 REPOSITORY - getQuizzes called');
    final result = await remoteDataSource.getQuizzes(
      search: search,
      limit: limit,
      offset: offset,
    );
    print('🔍 REPOSITORY - result type: ${result.runtimeType}');
    print('🔍 REPOSITORY - result length: ${result.length}');
    print('🔍 REPOSITORY - returning result');
    return result;
  }

  @override
  Future<Quiz> getQuizById(int quizId) async {
    return await remoteDataSource.getQuizById(quizId);
  }

  @override
  Future<Quiz> createQuiz({required String title, String? description}) async {
    return await remoteDataSource.createQuiz(
      title: title,
      description: description,
    );
  }

  @override
  Future<Quiz> updateQuiz({
    required int quizId,
    String? title,
    String? description,
    bool? isPublic,
  }) async {
    return await remoteDataSource.updateQuiz(
      quizId: quizId,
      title: title,
      description: description,
      isPublic: isPublic,
    );
  }

  @override
  Future<void> deleteQuiz(int quizId) async {
    return await remoteDataSource.deleteQuiz(quizId);
  }

  @override
  Future<Question> addQuestion({
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
    return await remoteDataSource.addQuestion(
      quizId: quizId,
      type: type,
      questionText: questionText,
      correctAnswer: correctAnswer,
      options: options,
      explanation: explanation,
      points: points,
      meanings: meanings,
      order: order,
    );
  }

  @override
  Future<Question> updateQuestion({
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
    return await remoteDataSource.updateQuestion(
      quizId: quizId,
      questionId: questionId,
      type: type,
      questionText: questionText,
      correctAnswer: correctAnswer,
      options: options,
      explanation: explanation,
      points: points,
      meanings: meanings,
      order: order,
    );
  }

  @override
  Future<void> deleteQuestion({
    required int quizId,
    required int questionId,
  }) async {
    return await remoteDataSource.deleteQuestion(
      quizId: quizId,
      questionId: questionId,
    );
  }

  @override
  Future<Quiz> reorderQuestions({
    required int quizId,
    required List<Map<String, int>> questionOrders,
  }) async {
    return await remoteDataSource.reorderQuestions(
      quizId: quizId,
      questionOrders: questionOrders,
    );
  }

  @override
  Future<QuizAttempt> startQuizAttempt(int quizId) async {
    return await remoteDataSource.startQuizAttempt(quizId);
  }

  @override
  Future<QuizAttempt> submitQuizAttempt({
    required int attemptId,
    required List<Map<String, dynamic>> answers,
    int? timeSpent,
  }) async {
    return await remoteDataSource.submitQuizAttempt(
      attemptId: attemptId,
      answers: answers,
      timeSpent: timeSpent,
    );
  }

  @override
  Future<List<QuizAttempt>> getQuizAttempts(int quizId) async {
    return await remoteDataSource.getQuizAttempts(quizId);
  }

  @override
  Future<QuizAttempt> getQuizAttemptDetails(int attemptId) async {
    return await remoteDataSource.getQuizAttemptDetails(attemptId);
  }

  @override
  Future<void> requestPublish({required int quizId, String? message}) async {
    return await remoteDataSource.requestPublish(
      quizId: quizId,
      message: message,
    );
  }
}
