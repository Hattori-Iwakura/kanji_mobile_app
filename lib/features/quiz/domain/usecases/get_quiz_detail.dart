import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

class GetQuizDetailUseCase {
  final QuizRepository repository;

  GetQuizDetailUseCase(this.repository);

  Future<Quiz> call(int quizId) async {
    return await repository.getQuizById(quizId);
  }
}
