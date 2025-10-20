import '../entities/flashcard_deck_entity.dart';
import '../repositories/flashcard_repository.dart';

class GetDeckByIdUseCase {
  final FlashcardRepository repository;

  GetDeckByIdUseCase(this.repository);

  Future<FlashcardDeckEntity> call(int id) {
    return repository.getDeckById(id);
  }
}
