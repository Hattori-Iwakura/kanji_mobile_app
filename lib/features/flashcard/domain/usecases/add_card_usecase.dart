import '../entities/flashcard_card_entity.dart';
import '../repositories/flashcard_repository.dart';

class AddCardUseCase {
  final FlashcardRepository repository;

  AddCardUseCase(this.repository);

  Future<FlashcardCardEntity> call({
    required int deckId,
    required int kanjiId,
  }) {
    return repository.addCard(deckId: deckId, kanjiId: kanjiId);
  }
}
