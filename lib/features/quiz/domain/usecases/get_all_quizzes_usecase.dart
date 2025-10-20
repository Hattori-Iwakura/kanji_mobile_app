import '../entities/quiz_entity.dart';
import '../repositories/quiz_repository.dart';

class GetAllQuizzesUseCase {
  final QuizRepository repository;

  GetAllQuizzesUseCase(this.repository);

  Future<List<QuizEntity>> call({String? search, int? limit, int? offset}) {
    return repository.getAllQuizzes(
      search: search,
      limit: limit,
      offset: offset,
    );
  }
}
