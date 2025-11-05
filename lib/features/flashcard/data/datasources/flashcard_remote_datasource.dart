import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/flashcard_deck_model.dart';
import '../models/study_session_model.dart';
import '../models/next_card_model.dart';
import '../models/deck_statistics_model.dart';
import '../models/active_session_model.dart';
import '../../domain/entities/review_type.dart';

abstract class FlashcardRemoteDataSource {
  Future<List<FlashcardDeckModel>> getDecks({String? search});
  Future<FlashcardDeckModel> getDeckById(int deckId);
  Future<FlashcardDeckModel> createDeck({
    required String name,
    String? description,
    List<int>? kanjiIds,
  });
  Future<FlashcardDeckModel> updateDeck({
    required int deckId,
    String? name,
    String? description,
    bool? isPublic,
  });
  Future<void> deleteDeck(int deckId);
  Future<FlashcardDeckModel> addCardToDeck({
    required int deckId,
    required int kanjiId,
  });
  Future<FlashcardDeckModel> removeCardFromDeck({
    required int deckId,
    required int kanjiId,
  });
  Future<StudySessionModel> startSession({
    required int deckId,
    int? maxNewCards,
    int? maxReviewCards,
    ReviewType? reviewType,
  });
  Future<ActiveSessionModel?> getActiveSession(int deckId);
  Future<StudySessionModel> getSessionProgress(int sessionId);
  Future<NextCardModel?> getNextCard(int sessionId);
  Future<void> reviewCard({
    required int sessionId,
    required int cardId,
    required int quality,
    double? timeSpent,
  });
  Future<StudySessionModel> completeSession(int sessionId);
  Future<Map<String, dynamic>> getDueCards(int deckId);
  Future<DeckStatisticsModel> getDeckStatistics(int deckId);
}

class FlashcardRemoteDataSourceImpl implements FlashcardRemoteDataSource {
  final ApiClient apiClient;
  final SecureStorage secureStorage;

  FlashcardRemoteDataSourceImpl({
    required this.apiClient,
    required this.secureStorage,
  });

  Future<Options> _getAuthHeaders() async {
    final token = await secureStorage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // Helper to extract data from response wrapper {statusCode, data: {...}, timestamp}
  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'] as Map<String, dynamic>;
    }
    return responseData as Map<String, dynamic>;
  }

  Map<String, dynamic>? _extractDataNullable(dynamic responseData) {
    if (responseData == null) {
      return null;
    }
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      final data = responseData['data'];
      return data as Map<String, dynamic>?;
    }
    return responseData as Map<String, dynamic>?;
  }

  @override
  Future<List<FlashcardDeckModel>> getDecks({String? search}) async {
    final options = await _getAuthHeaders();
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await apiClient.dio.get(
      '/flashcard-decks',
      queryParameters: queryParams,
      options: options,
    );

    final responseData = response.data;
    // Response format: {statusCode, data: {data: [...], total, limit, offset}, timestamp}
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      final data = responseData['data'];
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return (data['data'] as List)
            .map((e) => FlashcardDeckModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    // Fallback for direct array response
    return (responseData as List)
        .map((e) => FlashcardDeckModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FlashcardDeckModel> getDeckById(int deckId) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.get(
      '/flashcard-decks/$deckId',
      options: options,
    );
    return FlashcardDeckModel.fromJson(_extractData(response.data));
  }

  @override
  Future<FlashcardDeckModel> createDeck({
    required String name,
    String? description,
    List<int>? kanjiIds,
  }) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.post(
      '/flashcard-decks',
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (kanjiIds != null) 'kanjiIds': kanjiIds,
      },
      options: options,
    );

    // Response format: {statusCode, data: {deck_object}, timestamp}
    final responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return FlashcardDeckModel.fromJson(
        responseData['data'] as Map<String, dynamic>,
      );
    }
    return FlashcardDeckModel.fromJson(responseData as Map<String, dynamic>);
  }

  @override
  Future<FlashcardDeckModel> updateDeck({
    required int deckId,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.put(
      '/flashcard-decks/$deckId',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (isPublic != null) 'isPublic': isPublic,
      },
      options: options,
    );
    return FlashcardDeckModel.fromJson(_extractData(response.data));
  }

  @override
  Future<void> deleteDeck(int deckId) async {
    final options = await _getAuthHeaders();
    await apiClient.dio.delete('/flashcard-decks/$deckId', options: options);
  }

  @override
  Future<FlashcardDeckModel> addCardToDeck({
    required int deckId,
    required int kanjiId,
  }) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.post(
      '/flashcard-decks/$deckId/cards/$kanjiId',
      options: options,
    );
    return FlashcardDeckModel.fromJson(_extractData(response.data));
  }

  @override
  Future<FlashcardDeckModel> removeCardFromDeck({
    required int deckId,
    required int kanjiId,
  }) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.delete(
      '/flashcard-decks/$deckId/cards/$kanjiId',
      options: options,
    );
    return FlashcardDeckModel.fromJson(_extractData(response.data));
  }

  @override
  Future<StudySessionModel> startSession({
    required int deckId,
    int? maxNewCards,
    int? maxReviewCards,
    ReviewType? reviewType,
  }) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.post(
      '/flashcard-sessions/start',
      data: {
        'deckId': deckId,
        if (maxNewCards != null) 'maxNewCards': maxNewCards,
        if (maxReviewCards != null) 'maxReviewCards': maxReviewCards,
        if (reviewType != null) 'reviewType': reviewType.value,
      },
      options: options,
    );
    return StudySessionModel.fromJson(_extractData(response.data));
  }

  @override
  Future<ActiveSessionModel?> getActiveSession(int deckId) async {
    try {
      final options = await _getAuthHeaders();
      final response = await apiClient.dio.get(
        '/flashcard-sessions/active/$deckId',
        options: options,
      );
      final data = _extractDataNullable(response.data);
      if (data == null) {
        return null;
      }
      return ActiveSessionModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<StudySessionModel> getSessionProgress(int sessionId) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.get(
      '/flashcard-sessions/$sessionId',
      options: options,
    );
    return StudySessionModel.fromJson(_extractData(response.data));
  }

  @override
  Future<NextCardModel?> getNextCard(int sessionId) async {
    try {
      final options = await _getAuthHeaders();
      final response = await apiClient.dio.get(
        '/flashcard-sessions/$sessionId/next-card',
        options: options,
      );
      return NextCardModel.fromJson(_extractData(response.data));
    } on DioException catch (e) {
      // When session is complete, backend returns 404
      if (e.response?.statusCode == 404) {
        return null; // No more cards available
      }
      rethrow;
    }
  }

  @override
  Future<void> reviewCard({
    required int sessionId,
    required int cardId,
    required int quality,
    double? timeSpent,
  }) async {
    final options = await _getAuthHeaders();
    await apiClient.dio.post(
      '/flashcard-sessions/$sessionId/review/$cardId',
      data: {'quality': quality, if (timeSpent != null) 'timeSpent': timeSpent},
      options: options,
    );
  }

  @override
  Future<StudySessionModel> completeSession(int sessionId) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.post(
      '/flashcard-sessions/$sessionId/complete',
      options: options,
    );
    return StudySessionModel.fromJson(_extractData(response.data));
  }

  @override
  Future<Map<String, dynamic>> getDueCards(int deckId) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.get(
      '/flashcard-sessions/due-cards/$deckId',
      options: options,
    );
    return _extractData(response.data);
  }

  @override
  Future<DeckStatisticsModel> getDeckStatistics(int deckId) async {
    final options = await _getAuthHeaders();
    final response = await apiClient.dio.get(
      '/flashcard-sessions/statistics/deck/$deckId',
      options: options,
    );
    return DeckStatisticsModel.fromJson(_extractData(response.data));
  }
}
