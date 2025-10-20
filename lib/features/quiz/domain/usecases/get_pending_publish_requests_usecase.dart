import '../repositories/quiz_repository.dart';

class GetPendingPublishRequestsUseCase {
  final QuizRepository repository;

  GetPendingPublishRequestsUseCase(this.repository);

  Future<List<dynamic>> call() {
    return repository.getPendingPublishRequests();
  }
}
