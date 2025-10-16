import '../../../../core/network/api_client.dart';
import '../models/flashcard_deck_model.dart';
import '../models/flashcard_card_model.dart';
import '../models/study_session_model.dart';
import '../models/flashcard_card_detail_model.dart';
import '../models/flashcard_stats_model.dart';

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

  Future<FlashcardCardDetailModel> getCardDetail(int cardId);

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

  Future<void> bulkAddCards({required int deckId, required List<int> kanjiIds});

  Future<void> reorderCards({required int deckId, required List<int> cardIds});

  Future<StudySessionModel> startStudySession({
    required int deckId,
    int? maxCards,
    String? mode,
    bool? randomize,
    bool? includeNew,
    bool? includeDue,
    bool? includeHard,
    int? difficultyThreshold,
    bool? resumeExisting,
  });

  Future<StudySessionModel> pauseSession(int sessionId);

  Future<StudySessionModel> resumeSession(int sessionId);

  Future<StudySessionModel> getSessionDetail(int sessionId);

  Future<List<StudySessionModel>> getActiveSessions({int? deckId});

  Future<Map<String, dynamic>> reviewCard({
    required int sessionId,
    required int cardId,
    required int rating,
    required int timeSpent,
  });

  Future<StudySessionModel> completeSession(int sessionId);

  Future<List<dynamic>> getStudyHistory({int? deckId});

  Future<FlashcardStatsModel> getStats({int? deckId});
}

class FlashcardRemoteDataSourceImpl implements FlashcardRemoteDataSource {
  final ApiClient apiClient;

  FlashcardRemoteDataSourceImpl({required this.apiClient});

  StudySessionModel _parseSessionPayload(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('session')) {
        return StudySessionModel.fromEnvelope(raw);
      }
      return StudySessionModel.fromJson(raw);
    }
    throw const FormatException('Invalid study session payload');
  }

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
  Future<FlashcardCardDetailModel> getCardDetail(int cardId) async {
    final response = await apiClient.get('/flashcard/cards/$cardId');
    return FlashcardCardDetailModel.fromJson(response.data['data']);
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
  Future<void> bulkAddCards({
    required int deckId,
    required List<int> kanjiIds,
  }) async {
    await apiClient.post('/flashcard/decks/$deckId/cards/bulk', {
      'kanjiIds': kanjiIds,
    });
  }

  @override
  Future<void> reorderCards({
    required int deckId,
    required List<int> cardIds,
  }) async {
    await apiClient.put('/flashcard/decks/$deckId/reorder', {
      'cardIds': cardIds,
    });
  }

  @override
  Future<StudySessionModel> startStudySession({
    required int deckId,
    int? maxCards,
    String? mode,
    bool? randomize,
    bool? includeNew,
    bool? includeDue,
    bool? includeHard,
    int? difficultyThreshold,
    bool? resumeExisting,
  }) async {
    final payload = <String, dynamic>{
      if (maxCards != null) 'max_cards': maxCards,
      if (mode != null) 'mode': mode,
      if (randomize != null) 'randomize': randomize,
      if (includeNew != null) 'include_new': includeNew,
      if (includeDue != null) 'include_due': includeDue,
      if (includeHard != null) 'include_hard': includeHard,
      if (difficultyThreshold != null)
        'difficulty_threshold': difficultyThreshold,
      if (resumeExisting != null) 'resume_existing': resumeExisting,
    };

    final response = await apiClient.post(
      '/flashcard/decks/$deckId/study',
      payload,
    );

    final rawData = response.data['data'];
    if (rawData is! Map<String, dynamic>) {
      throw const FormatException('Invalid study session payload');
    }

    final sessionData = rawData['session'];
    final cardsData = (rawData['cards'] as List?) ?? const [];

    if (sessionData is! Map<String, dynamic>) {
      return StudySessionModel.empty(deckId: deckId, cards: cardsData);
    }

    if (rawData.containsKey('meta')) {
      return StudySessionModel.fromEnvelope({
        'session': sessionData,
        'cards': cardsData,
        'meta': rawData['meta'],
      });
    }

    final sessionMap = Map<String, dynamic>.from(sessionData);
    sessionMap['cards'] = cardsData;

    return StudySessionModel.fromJson(sessionMap);
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
      const {},
    );

    final data = response.data['data'];
    return _parseSessionPayload(data);
  }

  @override
  Future<StudySessionModel> pauseSession(int sessionId) async {
    final response = await apiClient.post(
      '/flashcard/sessions/$sessionId/pause',
      const {},
    );

    final data = response.data['data'];
    return _parseSessionPayload(data);
  }

  @override
  Future<StudySessionModel> resumeSession(int sessionId) async {
    final response = await apiClient.post(
      '/flashcard/sessions/$sessionId/resume',
      const {},
    );

    final data = response.data['data'];
    return _parseSessionPayload(data);
  }

  @override
  Future<StudySessionModel> getSessionDetail(int sessionId) async {
    final response = await apiClient.get('/flashcard/sessions/$sessionId');
    final data = response.data['data'];

    if (data is Map<String, dynamic>) {
      return _parseSessionPayload(data);
    }

    throw const FormatException('Invalid session detail payload');
  }

  @override
  Future<List<StudySessionModel>> getActiveSessions({int? deckId}) async {
    final response = await apiClient.get(
      '/flashcard/sessions/active',
      queryParameters: deckId != null ? {'deckId': deckId.toString()} : null,
    );

    final data = response.data['data'];
    if (data is! List) {
      throw const FormatException('Invalid active sessions payload');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(_parseSessionPayload)
        .toList();
  }

  @override
  Future<List<dynamic>> getStudyHistory({int? deckId}) async {
    final response = await apiClient.get(
      '/flashcard/history',
      queryParameters: deckId != null ? {'deckId': deckId.toString()} : null,
    );

    final data = response.data['data'];
    if (data is! List) {
      throw const FormatException('Invalid study history payload');
    }

    return data;
  }

  @override
  Future<FlashcardStatsModel> getStats({int? deckId}) async {
    final response = await apiClient.get(
      '/flashcard/stats',
      queryParameters: deckId != null ? {'deckId': deckId.toString()} : null,
    );

    return FlashcardStatsModel.fromJson(response.data['data']);
  }
}
