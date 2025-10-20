import '../repositories/quiz_repository.dart';

class RejectPublishRequestUseCase {
  final QuizRepository repository;

  RejectPublishRequestUseCase(this.repository);

  Future<void> call(int requestId) {
    return repository.rejectPublishRequest(requestId);
  }
}
