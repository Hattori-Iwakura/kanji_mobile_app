import '../entities/quiz_attempt_entity.dart';
import '../repositories/quiz_repository.dart';

class GetQuizAttemptDetailsUseCase {
  final QuizRepository repository;

  GetQuizAttemptDetailsUseCase(this.repository);

  Future<QuizAttemptEntity> call(int attemptId) {
    return repository.getQuizAttemptDetails(attemptId);
  }
}
