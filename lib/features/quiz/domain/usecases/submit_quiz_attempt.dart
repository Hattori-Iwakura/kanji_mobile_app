import '../entities/quiz_attempt.dart';
import '../repositories/quiz_repository.dart';

class SubmitQuizAttemptUseCase {
  final QuizRepository repository;

  SubmitQuizAttemptUseCase(this.repository);

  Future<QuizAttempt> call({
    required int attemptId,
    required List<Map<String, dynamic>> answers,
    int? timeSpent,
  }) async {
    return await repository.submitQuizAttempt(
      attemptId: attemptId,
      answers: answers,
      timeSpent: timeSpent,
    );
  }
}
