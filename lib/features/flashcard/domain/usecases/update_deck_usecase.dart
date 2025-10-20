import '../entities/flashcard_deck_entity.dart';
import '../repositories/flashcard_repository.dart';

class UpdateDeckUseCase {
  final FlashcardRepository repository;

  UpdateDeckUseCase(this.repository);

  Future<FlashcardDeckEntity> call({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  }) {
    return repository.updateDeck(
      id: id,
      name: name,
      description: description,
      isPublic: isPublic,
    );
  }
}
