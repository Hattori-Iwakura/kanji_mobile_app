import '../repositories/quiz_repository.dart';
import '../entities/quiz.dart';

class GetQuizzesUseCase {
  final QuizRepository repository;

  GetQuizzesUseCase(this.repository);

  Future<List<Quiz>> call({
    String? search,
    int? limit,
    int? offset,
  }) async {
    print('🔍 USE CASE - getQuizzes called');
    final result = await repository.getQuizzes(
      search: search,
      limit: limit,
      offset: offset,
    );
    print('🔍 USE CASE - result type: ${result.runtimeType}');
    print('🔍 USE CASE - result length: ${result.length}');
    print('🔍 USE CASE - returning result');
    return result;
  }
}
