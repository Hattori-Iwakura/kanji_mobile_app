import '../../../../core/network/api_client.dart';
import '../models/flashcard_deck_model.dart';
import '../models/flashcard_card_model.dart';
import '../models/study_session_model.dart';

abstract class FlashcardRemoteDataSource {
  Future<FlashcardDeckModel> createDeck({
    required String name,
    String? description,
    required String sourceType,
    int? sourceId,
    bool? isPublic,
  });

  Future<List<FlashcardDeckModel>> getUserDecks();

  Future<FlashcardDeckModel> getDeckById(int deckId);

  Future<FlashcardDeckModel> updateDeck({
    required int deckId,
    String? name,
    String? description,
    bool? isPublic,
  });

  Future<void> deleteDeck(int deckId);

  Future<FlashcardCardModel> addCardToDeck({
    required int deckId,
    required int kanjiId,
  });

  Future<void> removeCardFromDeck(int cardId);

  Future<StudySessionModel> startStudySession({
    required int deckId,
    int? maxCards,
  });

  Future<Map<String, dynamic>> reviewCard({
    required int sessionId,
    required int cardId,
    required int rating,
    required int timeSpent,
  });

  Future<StudySessionModel> completeSession(int sessionId);

  Future<List<StudySessionModel>> getStudyHistory({int? deckId});
}

class FlashcardRemoteDataSourceImpl implements FlashcardRemoteDataSource {
  final ApiClient apiClient;

  FlashcardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<FlashcardDeckModel> createDeck({
    required String name,
    String? description,
    required String sourceType,
    int? sourceId,
    bool? isPublic,
  }) async {
    final response = await apiClient.post('/flashcard/decks', {
      'name': name,
      'description': description,
      'source_type': sourceType,
      'source_id': sourceId,
      'is_public': isPublic,
    });

    return FlashcardDeckModel.fromJson(response.data['data']);
  }

  @override
  Future<List<FlashcardDeckModel>> getUserDecks() async {
    final response = await apiClient.get('/flashcard/decks');

    return (response.data['data'] as List)
        .map((deck) => FlashcardDeckModel.fromJson(deck))
        .toList();
  }

  @override
  Future<FlashcardDeckModel> getDeckById(int deckId) async {
    final response = await apiClient.get('/flashcard/decks/$deckId');

    return FlashcardDeckModel.fromJson(response.data['data']);
  }

  @override
  Future<FlashcardDeckModel> updateDeck({
    required int deckId,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    final response = await apiClient.put('/flashcard/decks/$deckId', {
      'name': name,
      'description': description,
      'is_public': isPublic,
    });

    return FlashcardDeckModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteDeck(int deckId) async {
    await apiClient.delete('/flashcard/decks/$deckId');
  }

  @override
  Future<FlashcardCardModel> addCardToDeck({
    required int deckId,
    required int kanjiId,
  }) async {
    final response = await apiClient.post('/flashcard/decks/$deckId/cards', {
      'kanji_id': kanjiId,
    });

    return FlashcardCardModel.fromJson(response.data['data']);
  }

  @override
  Future<void> removeCardFromDeck(int cardId) async {
    await apiClient.delete('/flashcard/cards/$cardId');
  }

  @override
  Future<StudySessionModel> startStudySession({
    required int deckId,
    int? maxCards,
  }) async {
    final response = await apiClient.post('/flashcard/decks/$deckId/study', {
      'max_cards': maxCards,
    });

    // Parse response structure: { session: {...}, cards: [...] }
    final data = response.data['data'];
    final sessionData = data['session'];
    final cardsData = data['cards'] as List;

    // Add cards to session data
    sessionData['cards'] = cardsData;

    return StudySessionModel.fromJson(sessionData);
  }

  @override
  Future<Map<String, dynamic>> reviewCard({
    required int sessionId,
    required int cardId,
    required int rating,
    required int timeSpent,
  }) async {
    final response = await apiClient.post(
      '/flashcard/sessions/$sessionId/cards/$cardId/review',
      {'rating': rating, 'time_spent': timeSpent},
    );

    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<StudySessionModel> completeSession(int sessionId) async {
    final response = await apiClient.post(
      '/flashcard/sessions/$sessionId/complete',
      {},
    );

    return StudySessionModel.fromJson(response.data['data']);
  }

  @override
  Future<List<StudySessionModel>> getStudyHistory({int? deckId}) async {
    final response = await apiClient.get(
      '/flashcard/history',
      queryParameters: deckId != null ? {'deckId': deckId} : null,
    );

    return (response.data['data'] as List)
        .map((session) => StudySessionModel.fromJson(session))
        .toList();
  }
}
