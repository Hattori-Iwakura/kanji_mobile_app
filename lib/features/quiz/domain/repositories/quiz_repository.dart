import '../../domain/entities/quiz.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/quiz_attempt.dart';
import '../../domain/entities/quiz_answer.dart';
import '../../domain/entities/quiz_enums.dart';

abstract class QuizRepository {
  Future<List<Quiz>> getQuizzes({
    bool? myQuizzes,
    bool? isPublic,
    String? category,
    QuizDifficulty? difficulty,
  });

  Future<Quiz> getQuizById(int quizId);
  Future<Quiz> createQuiz(Map<String, dynamic> data);
  Future<Quiz> updateQuiz(int quizId, Map<String, dynamic> data);
  Future<void> deleteQuiz(int quizId);

  Future<Question> addQuestion(int quizId, Map<String, dynamic> data);
  Future<void> deleteQuestion(int questionId);

  Future<QuizAttempt> startQuiz(int quizId);
  Future<QuizAnswer> submitAnswer(Map<String, dynamic> data);
  Future<QuizAttempt> getAttemptResults(int attemptId);
  Future<List<QuizAttempt>> getUserAttempts({int? quizId});
  Future<Map<String, dynamic>> getQuizStatistics(int quizId);
}
