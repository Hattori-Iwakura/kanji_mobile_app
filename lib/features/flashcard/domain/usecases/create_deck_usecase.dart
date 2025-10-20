import '../entities/flashcard_deck_entity.dart';
import '../repositories/flashcard_repository.dart';

class CreateDeckUseCase {
  final FlashcardRepository repository;

  CreateDeckUseCase(this.repository);

  Future<FlashcardDeckEntity> call({
    required String name,
    String? description,
    List<int>? kanjiIds,
  }) {
    return repository.createDeck(
      name: name,
      description: description,
      kanjiIds: kanjiIds,
    );
  }
}
