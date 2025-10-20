import '../repositories/flashcard_repository.dart';

class RemoveCardUseCase {
  final FlashcardRepository repository;

  RemoveCardUseCase(this.repository);

  Future<void> call({required int deckId, required int kanjiId}) {
    return repository.removeCard(deckId: deckId, kanjiId: kanjiId);
  }
}
