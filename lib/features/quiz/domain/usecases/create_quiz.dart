import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

class CreateQuizUseCase {
  final QuizRepository repository;

  CreateQuizUseCase(this.repository);

  Future<Quiz> call({required String title, String? description}) async {
    return await repository.createQuiz(title: title, description: description);
  }
}
