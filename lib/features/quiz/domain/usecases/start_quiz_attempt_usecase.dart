import '../entities/quiz_attempt_entity.dart';
import '../repositories/quiz_repository.dart';

class StartQuizAttemptUseCase {
  final QuizRepository repository;

  StartQuizAttemptUseCase(this.repository);

  Future<QuizAttemptEntity> call(int quizId) {
    return repository.startQuizAttempt(quizId);
  }
}
