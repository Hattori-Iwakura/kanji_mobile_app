import 'package:hive/hive.dart';
import '../models/flashcard_model.dart';
import '../models/flashcard_deck_model.dart';

/// Local data source for offline flashcard storage
abstract class FlashcardLocalDataSource {
  // Cache decks
  Future<void> cacheDecks(List<FlashcardDeckModel> decks);
  Future<List<FlashcardDeckModel>?> getCachedDecks();

  // Cache cards for a deck
  Future<void> cacheCards(String deckId, List<FlashcardModel> cards);
  Future<List<FlashcardModel>?> getCachedCards(String deckId);

  // Update single card (for SM-2 algorithm updates)
  Future<void> updateCachedCard(FlashcardModel card);

  // Clear cache
  Future<void> clearCache();
}

class FlashcardLocalDataSourceImpl implements FlashcardLocalDataSource {
  static const String decksBoxName = 'flashcard_decks';
  static const String cardsBoxName = 'flashcard_cards';

  @override
  Future<void> cacheDecks(List<FlashcardDeckModel> decks) async {
    final box = await Hive.openBox<Map>(decksBoxName);
    final decksJson = decks.map((deck) => deck.toJson()).toList();
    await box.put('all_decks', {'decks': decksJson});
  }

  @override
  Future<List<FlashcardDeckModel>?> getCachedDecks() async {
    final box = await Hive.openBox<Map>(decksBoxName);
    final data = box.get('all_decks');

    if (data == null) return null;

    final decksJson = (data['decks'] as List).cast<Map<String, dynamic>>();
    return decksJson.map((json) => FlashcardDeckModel.fromJson(json)).toList();
  }

  @override
  Future<void> cacheCards(String deckId, List<FlashcardModel> cards) async {
    final box = await Hive.openBox<Map>(cardsBoxName);
    final cardsJson = cards.map((card) => card.toJson()).toList();
    await box.put(deckId, {'cards': cardsJson});
  }

  @override
  Future<List<FlashcardModel>?> getCachedCards(String deckId) async {
    final box = await Hive.openBox<Map>(cardsBoxName);
    final data = box.get(deckId);

    if (data == null) return null;

    final cardsJson = (data['cards'] as List).cast<Map<String, dynamic>>();
    return cardsJson.map((json) => FlashcardModel.fromJson(json)).toList();
  }

  @override
  Future<void> updateCachedCard(FlashcardModel card) async {
    final box = await Hive.openBox<Map>(cardsBoxName);
    final data = box.get(card.deckId);

    if (data == null) return;

    final cardsJson = (data['cards'] as List).cast<Map<String, dynamic>>();
    final cards = cardsJson
        .map((json) => FlashcardModel.fromJson(json))
        .toList();

    // Find and update the card
    final index = cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      cards[index] = card;
      await cacheCards(card.deckId, cards);
    }
  }

  @override
  Future<void> clearCache() async {
    final decksBox = await Hive.openBox<Map>(decksBoxName);
    final cardsBox = await Hive.openBox<Map>(cardsBoxName);
    await decksBox.clear();
    await cardsBox.clear();
  }
}
