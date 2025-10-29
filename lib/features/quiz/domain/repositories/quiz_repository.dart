import '../entities/quiz.dart';
import '../entities/question.dart';
import '../entities/quiz_attempt.dart';

abstract class QuizRepository {
  // Quiz CRUD
  Future<List<Quiz>> getQuizzes({
    String? search,
    int? limit,
    int? offset,
  });
  Future<Quiz> getQuizById(int quizId);
  Future<Quiz> createQuiz({required String title, String? description});
  Future<Quiz> updateQuiz({
    required int quizId,
    String? title,
    String? description,
    bool? isPublic,
  });
  Future<void> deleteQuiz(int quizId);

  // Question Management
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
  });
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
  });
  Future<void> deleteQuestion({required int quizId, required int questionId});
  Future<Quiz> reorderQuestions({
    required int quizId,
    required List<Map<String, int>> questionOrders,
  });

  // Quiz Attempts
  Future<QuizAttempt> startQuizAttempt(int quizId);
  Future<QuizAttempt> submitQuizAttempt({
    required int attemptId,
    required List<Map<String, dynamic>> answers,
    int? timeSpent,
  });
  Future<List<QuizAttempt>> getQuizAttempts(int quizId);
  Future<QuizAttempt> getQuizAttemptDetails(int attemptId);

  // Publish Request
  Future<void> requestPublish({required int quizId, String? message});
}
