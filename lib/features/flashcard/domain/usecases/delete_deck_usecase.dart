import '../repositories/flashcard_repository.dart';

class DeleteDeckUseCase {
  final FlashcardRepository repository;

  DeleteDeckUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteDeck(id);
  }
}
