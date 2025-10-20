import '../entities/quiz_entity.dart';
import '../repositories/quiz_repository.dart';

class UpdateQuizUseCase {
  final QuizRepository repository;

  UpdateQuizUseCase(this.repository);

  Future<QuizEntity> call({
    required int id,
    String? title,
    String? description,
    bool? isPublic,
  }) {
    return repository.updateQuiz(
      id: id,
      title: title,
      description: description,
      isPublic: isPublic,
    );
  }
}
