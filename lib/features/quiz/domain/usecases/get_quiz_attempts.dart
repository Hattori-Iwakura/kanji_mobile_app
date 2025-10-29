import '../entities/quiz_attempt.dart';
import '../repositories/quiz_repository.dart';

class GetQuizAttemptsUseCase {
  final QuizRepository repository;

  GetQuizAttemptsUseCase(this.repository);

  Future<List<QuizAttempt>> call(int quizId) async {
    return await repository.getQuizAttempts(quizId);
  }
}
