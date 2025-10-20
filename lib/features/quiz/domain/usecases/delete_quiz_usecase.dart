import '../repositories/quiz_repository.dart';

class DeleteQuizUseCase {
  final QuizRepository repository;

  DeleteQuizUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteQuiz(id);
  }
}
