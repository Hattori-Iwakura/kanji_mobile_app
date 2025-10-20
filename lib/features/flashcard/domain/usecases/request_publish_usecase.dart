import '../repositories/flashcard_repository.dart';

class RequestPublishUseCase {
  final FlashcardRepository repository;

  RequestPublishUseCase(this.repository);

  Future<void> call(int deckId) {
    return repository.requestPublish(deckId);
  }
}
