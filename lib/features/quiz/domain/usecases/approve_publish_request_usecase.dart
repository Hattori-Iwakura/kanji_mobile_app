import '../repositories/quiz_repository.dart';

class ApprovePublishRequestUseCase {
  final QuizRepository repository;

  ApprovePublishRequestUseCase(this.repository);

  Future<void> call(int requestId) {
    return repository.approvePublishRequest(requestId);
  }
}
