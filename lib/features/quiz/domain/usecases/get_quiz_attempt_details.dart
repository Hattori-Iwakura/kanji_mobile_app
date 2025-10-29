import '../entities/quiz_attempt.dart';
import '../repositories/quiz_repository.dart';

class GetQuizAttemptDetailsUseCase {
  final QuizRepository repository;

  GetQuizAttemptDetailsUseCase(this.repository);

  Future<QuizAttempt> call(int attemptId) async {
    return await repository.getQuizAttemptDetails(attemptId);
  }
}
