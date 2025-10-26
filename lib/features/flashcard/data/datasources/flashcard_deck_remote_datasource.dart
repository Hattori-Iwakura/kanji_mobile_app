import 'package:dio/dio.dart';
import '../models/flashcard_deck_new_model.dart';

/// Remote data source for Flashcard Deck API (new backend module)
abstract class FlashcardDeckRemoteDataSource {
  /// Get all flashcard decks (public + user's own if authenticated)
  Future<FlashcardDecksResponse> getAllDecks({
    String? search,
    int? limit,
    int? offset,
  });

  /// Get single deck by ID
  Future<FlashcardDeckNewModel> getDeckById(int id);

  /// Create new flashcard deck
  Future<FlashcardDeckNewModel> createDeck({
    required String name,
    String? description,
    List<int>? kanjiIds,
  });

  /// Update flashcard deck
  Future<FlashcardDeckNewModel> updateDeck({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  });

  /// Delete flashcard deck
  Future<void> deleteDeck(int id);

  /// Add kanji card to deck
  Future<FlashcardDeckNewModel> addCardToDeck(int deckId, int kanjiId);

  /// Remove kanji card from deck
  Future<FlashcardDeckNewModel> removeCardFromDeck(int deckId, int kanjiId);
}

class FlashcardDeckRemoteDataSourceImpl
    implements FlashcardDeckRemoteDataSource {
  final Dio dio;

  FlashcardDeckRemoteDataSourceImpl({required this.dio});

  @override
  Future<FlashcardDecksResponse> getAllDecks({
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await dio.get(
        '/flashcard-decks',
        queryParameters: queryParams,
      );

      // Response structure: {data: [...], total, limit, offset}
      return FlashcardDecksResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<FlashcardDeckNewModel> getDeckById(int id) async {
    try {
      final response = await dio.get('/flashcard-decks/$id');
      return FlashcardDeckNewModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<FlashcardDeckNewModel> createDeck({
    required String name,
    String? description,
    List<int>? kanjiIds,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        if (description != null) 'description': description,
        if (kanjiIds != null && kanjiIds.isNotEmpty) 'kanjiIds': kanjiIds,
      };

      final response = await dio.post('/flashcard-decks', data: data);
      return FlashcardDeckNewModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<FlashcardDeckNewModel> updateDeck({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (isPublic != null) data['isPublic'] = isPublic;

      final response = await dio.put('/flashcard-decks/$id', data: data);
      return FlashcardDeckNewModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteDeck(int id) async {
    try {
      await dio.delete('/flashcard-decks/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<FlashcardDeckNewModel> addCardToDeck(int deckId, int kanjiId) async {
    try {
      final response = await dio.post(
        '/flashcard-decks/$deckId/cards/$kanjiId',
      );
      return FlashcardDeckNewModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<FlashcardDeckNewModel> removeCardFromDeck(
    int deckId,
    int kanjiId,
  ) async {
    try {
      final response = await dio.delete(
        '/flashcard-decks/$deckId/cards/$kanjiId',
      );
      return FlashcardDeckNewModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return Exception('Unauthorized');
        } else if (statusCode == 404) {
          return Exception('Deck not found');
        } else if (statusCode == 400) {
          final message = e.response?.data?['message'] ?? 'Bad request';
          return Exception(message);
        }
        return Exception('Server error: $statusCode');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error');
    }
  }
}
