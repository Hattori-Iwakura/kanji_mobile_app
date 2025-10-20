import '../entities/quiz_attempt_entity.dart';
import '../repositories/quiz_repository.dart';

class SubmitQuizAttemptUseCase {
  final QuizRepository repository;

  SubmitQuizAttemptUseCase(this.repository);

  Future<QuizAttemptEntity> call({
    required int attemptId,
    required List<Map<String, dynamic>> answers,
  }) {
    return repository.submitQuizAttempt(attemptId: attemptId, answers: answers);
  }
}
