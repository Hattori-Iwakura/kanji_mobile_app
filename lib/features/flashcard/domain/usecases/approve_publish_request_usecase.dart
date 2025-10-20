import '../repositories/flashcard_repository.dart';

class ApprovePublishRequestUseCase {
  final FlashcardRepository repository;

  ApprovePublishRequestUseCase(this.repository);

  Future<void> call(int requestId) {
    return repository.approvePublishRequest(requestId);
  }
}
