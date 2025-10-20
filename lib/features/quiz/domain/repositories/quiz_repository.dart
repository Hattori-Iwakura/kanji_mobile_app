import '../entities/quiz_attempt_entity.dart';
import '../entities/quiz_entity.dart';
import '../entities/quiz_question_entity.dart';

abstract class QuizRepository {
  // Quiz operations (dựa theo Backend API /quizzes)
  Future<List<QuizEntity>> getAllQuizzes({
    String? search,
    int? limit,
    int? offset,
  });

  Future<QuizEntity> getQuizById(int id);

  Future<QuizEntity> createQuiz({required String title, String? description});

  Future<QuizEntity> updateQuiz({
    required int id,
    String? title,
    String? description,
    bool? isPublic,
  });

  Future<void> deleteQuiz(int id);

  // Question operations
  Future<QuizQuestionEntity> addQuestion({
    required int quizId,
    required int kanjiId,
    required String questionText,
    required String questionType,
    required List<String> options,
    required String correctAnswer,
  });

  Future<QuizQuestionEntity> updateQuestion({
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

  // Quiz attempt operations
  Future<QuizAttemptEntity> startQuizAttempt(int quizId);

  Future<QuizAttemptEntity> submitQuizAttempt({
    required int attemptId,
    required List<Map<String, dynamic>> answers,
  });

  Future<List<QuizAttemptEntity>> getQuizAttempts(int quizId);

  Future<QuizAttemptEntity> getQuizAttemptDetails(int attemptId);

  // Publish operations
  Future<void> requestPublish(int quizId, String? message);

  Future<List<dynamic>> getPendingPublishRequests();

  Future<void> approvePublishRequest(int requestId);

  Future<void> rejectPublishRequest(int requestId);
}
