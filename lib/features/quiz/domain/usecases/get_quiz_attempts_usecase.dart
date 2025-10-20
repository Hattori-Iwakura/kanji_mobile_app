import '../entities/quiz_attempt_entity.dart';
import '../repositories/quiz_repository.dart';

class GetQuizAttemptsUseCase {
  final QuizRepository repository;

  GetQuizAttemptsUseCase(this.repository);

  Future<List<QuizAttemptEntity>> call(int quizId) {
    return repository.getQuizAttempts(quizId);
  }
}
