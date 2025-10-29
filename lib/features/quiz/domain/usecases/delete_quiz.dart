import '../repositories/quiz_repository.dart';

class DeleteQuizUseCase {
  final QuizRepository repository;

  DeleteQuizUseCase(this.repository);

  Future<void> call(int quizId) async {
    return await repository.deleteQuiz(quizId);
  }
}
