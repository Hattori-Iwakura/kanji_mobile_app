import '../entities/quiz_entity.dart';
import '../repositories/quiz_repository.dart';

class CreateQuizUseCase {
  final QuizRepository repository;

  CreateQuizUseCase(this.repository);

  Future<QuizEntity> call({required String title, String? description}) {
    return repository.createQuiz(title: title, description: description);
  }
}
