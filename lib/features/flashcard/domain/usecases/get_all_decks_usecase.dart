import '../entities/flashcard_deck_entity.dart';
import '../repositories/flashcard_repository.dart';

class GetAllDecksUseCase {
  final FlashcardRepository repository;

  GetAllDecksUseCase(this.repository);

  Future<List<FlashcardDeckEntity>> call({
    String? search,
    int? limit,
    int? offset,
  }) {
    return repository.getAllDecks(search: search, limit: limit, offset: offset);
  }
}
