import '../repositories/flashcard_repository.dart';

class RejectPublishRequestUseCase {
  final FlashcardRepository repository;

  RejectPublishRequestUseCase(this.repository);

  Future<void> call(int requestId, String? reason) {
    return repository.rejectPublishRequest(requestId, reason);
  }
}
