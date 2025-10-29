import '../entities/quiz_attempt.dart';
import '../repositories/quiz_repository.dart';

class StartQuizAttemptUseCase {
  final QuizRepository repository;

  StartQuizAttemptUseCase(this.repository);

  Future<QuizAttempt> call(int quizId) async {
    return await repository.startQuizAttempt(quizId);
  }
}
