import '../entities/flashcard_card_entity.dart';
import '../entities/flashcard_deck_entity.dart';

abstract class FlashcardRepository {
  // Deck operations (dựa theo Backend API /flashcard-decks)
  Future<List<FlashcardDeckEntity>> getAllDecks({
    String? search,
    int? limit,
    int? offset,
  });

  Future<FlashcardDeckEntity> getDeckById(int id);

  Future<FlashcardDeckEntity> createDeck({
    required String name,
    String? description,
    List<int>? kanjiIds,
  });

  Future<FlashcardDeckEntity> updateDeck({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  });

  Future<void> deleteDeck(int id);

  // Card operations (dựa theo Backend API)
  Future<FlashcardCardEntity> addCard({
    required int deckId,
    required int kanjiId,
  });

  Future<void> removeCard({required int deckId, required int kanjiId});

  // Publish operations (dựa theo Backend API)
  Future<void> requestPublish(int deckId);

  Future<List<dynamic>> getPublishRequests({String? status});

  Future<void> approvePublishRequest(int requestId);

  Future<void> rejectPublishRequest(int requestId, String? reason);
}
