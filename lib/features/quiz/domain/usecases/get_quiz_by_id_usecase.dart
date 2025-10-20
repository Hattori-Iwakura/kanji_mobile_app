import '../entities/quiz_entity.dart';
import '../repositories/quiz_repository.dart';

class GetQuizByIdUseCase {
  final QuizRepository repository;

  GetQuizByIdUseCase(this.repository);

  Future<QuizEntity> call(int id) {
    return repository.getQuizById(id);
  }
}
