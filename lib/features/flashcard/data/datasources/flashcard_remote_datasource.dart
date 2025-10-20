import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoint.dart';
import '../../domain/entities/flashcard_exception.dart';
import '../models/flashcard_card.dart';
import '../models/flashcard_deck.dart';

abstract class FlashcardRemoteDataSource {
  Future<List<FlashcardDeck>> getAllDecks({
    String? search,
    int? limit,
    int? offset,
  });
  Future<FlashcardDeck> getDeckById(int id);
  Future<FlashcardDeck> createDeck({
    required String name,
    String? description,
    List<int>? kanjiIds,
  });
  Future<FlashcardDeck> updateDeck({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  });
  Future<void> deleteDeck(int id);
  Future<FlashcardCard> addCard({required int deckId, required int kanjiId});
  Future<void> removeCard({required int deckId, required int kanjiId});
  Future<void> requestPublish(int deckId);
  Future<List<dynamic>> getPublishRequests({String? status});
  Future<void> approvePublishRequest(int requestId);
  Future<void> rejectPublishRequest(int requestId, String? reason);
}

class FlashcardRemoteDataSourceImpl implements FlashcardRemoteDataSource {
  final ApiClient _apiClient;

  FlashcardRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<FlashcardDeck>> getAllDecks({
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiClient.get(
        ApiEndpoints.flashcardDecks,
        queryParameters: queryParams,
      );

      final responseData = response.data;
      final data =
          responseData is Map<String, dynamic> &&
              responseData.containsKey('data')
          ? responseData['data'] as List<dynamic>
          : responseData as List<dynamic>;

      return data
          .map((json) => FlashcardDeck.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw FlashcardException(
        e.response?.data['message'] ?? 'Failed to load flashcard decks',
      );
    }
  }

  @override
  Future<FlashcardDeck> getDeckById(int id) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.flashcardDecks}/$id',
      );
      return FlashcardDeck.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw FlashcardException(
        e.response?.data['message'] ?? 'Failed to load deck',
      );
    }
  }

  @override
  Future<FlashcardDeck> createDeck({
    required String name,
    String? description,
    List<int>? kanjiIds,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        if (description != null) 'description': description,
        if (kanjiIds != null) 'kanjiIds': kanjiIds,
      };

      final response = await _apiClient.post(
        ApiEndpoints.flashcardDecks,
        data: data,
      );
      return FlashcardDeck.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw FlashcardException(
        e.response?.data['message'] ?? 'Failed to create deck',
      );
    }
  }

  @override
  Future<FlashcardDeck> updateDeck({
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

      final response = await _apiClient.put(
        '${ApiEndpoints.flashcardDecks}/$id',
        data: data,
      );
      return FlashcardDeck.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw FlashcardException(
        e.response?.data['message'] ?? 'Failed to update deck',
      );
    }
  }

  @override
  Future<void> deleteDeck(int id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.flashcardDecks}/$id');
    } on DioException catch (e) {
      throw FlashcardException(
        e.response?.data['message'] ?? 'Failed to delete deck',
      );
    }
  }

  @override
  Future<FlashcardCard> addCard({
    required int deckId,
    required int kanjiId,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.flashcardDecks}/$deckId/cards/$kanjiId',
      );
      return FlashcardCard.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw FlashcardException(
        e.response?.data['message'] ?? 'Failed to add card',
      );
    }
  }

  @override
  Future<void> removeCard({required int deckId, required int kanjiId}) async {
    try {
      await _apiClient.delete(
        '${ApiEndpoints.flashcardDecks}/$deckId/cards/$kanjiId',
      );
    } on DioException catch (e) {
      throw FlashcardException(
        e.response?.data['message'] ?? 'Failed to remove card',
      );
    }
  }

  @override
  Future<void> requestPublish(int deckId) async {
    try {
      await _apiClient.post('${ApiEndpoints.flashcardDecks}/$deckId/publish');
    } on DioException catch (e) {
      throw FlashcardException(
        e.response?.data['message'] ?? 'Failed to request publish',
      );
    }
  }

  @override
  Future<List<dynamic>> getPublishRequests({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.get(
        '${ApiEndpoints.flashcardDecks}/admin/publish-requests',
        queryParameters: queryParams,
      );

      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw FlashcardException(
        e.response?.data['message'] ?? 'Failed to get publish requests',
      );
    }
  }

  @override
  Future<void> approvePublishRequest(int requestId) async {
    try {
      await _apiClient.post(
        '${ApiEndpoints.flashcardDecks}/admin/publish-requests/$requestId/approve',
      );
    } on DioException catch (e) {
      throw FlashcardException(
        e.response?.data['message'] ?? 'Failed to approve publish request',
      );
    }
  }

  @override
  Future<void> rejectPublishRequest(int requestId, String? reason) async {
    try {
      final data = <String, dynamic>{};
      if (reason != null) data['reason'] = reason;

      await _apiClient.post(
        '${ApiEndpoints.flashcardDecks}/admin/publish-requests/$requestId/reject',
        data: data,
      );
    } on DioException catch (e) {
      throw FlashcardException(
        e.response?.data['message'] ?? 'Failed to reject publish request',
      );
    }
  }
}
