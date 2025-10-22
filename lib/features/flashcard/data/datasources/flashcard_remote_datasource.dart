import 'package:dio/dio.dart';
import '../models/flashcard_model.dart';
import '../models/flashcard_deck_model.dart';
import '../models/study_progress_model.dart';

/// Remote data source for Flashcard API
abstract class FlashcardRemoteDataSource {
  // Deck operations
  Future<List<FlashcardDeckModel>> getAllDecks();
  Future<FlashcardDeckModel> getDeckById(String deckId);
  Future<FlashcardDeckModel> createDeck({
    required String name,
    String? description,
  });
  Future<FlashcardDeckModel> updateDeck({
    required String deckId,
    String? name,
    String? description,
  });
  Future<void> deleteDeck(String deckId);

  // Flashcard operations
  Future<List<FlashcardModel>> getCardsByDeck(String deckId);
  Future<List<FlashcardModel>> getDueCards(String deckId);
  Future<List<FlashcardModel>> getNewCards(String deckId, {int limit = 20});
  Future<FlashcardModel> getCardById(String cardId);
  Future<FlashcardModel> createCard({
    required String deckId,
    required String kanjiId,
    required String front,
    required String back,
    String? hint,
  });
  Future<FlashcardModel> updateCardReview({
    required String cardId,
    required int quality,
  });
  Future<void> deleteCard(String cardId);

  // Progress operations
  Future<StudyProgressModel> saveProgress({
    required String deckId,
    required int cardsStudied,
    required int cardsCorrect,
    required int cardsIncorrect,
    required int studyDuration,
  });
  Future<List<StudyProgressModel>> getProgressHistory({
    String? deckId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Map<String, dynamic>> getStudyStatistics();
}

class FlashcardRemoteDataSourceImpl implements FlashcardRemoteDataSource {
  final Dio dio;

  FlashcardRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<FlashcardDeckModel>> getAllDecks() async {
    try {
      final response = await dio.get('/flashcard/decks');

      if (response.statusCode == 200) {
        final data = response.data;
        final decks = data['data'] as List;
        return decks.map((json) => FlashcardDeckModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load decks');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<FlashcardDeckModel> getDeckById(String deckId) async {
    try {
      final response = await dio.get('/flashcard/decks/$deckId');

      if (response.statusCode == 200) {
        return FlashcardDeckModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load deck');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<FlashcardDeckModel> createDeck({
    required String name,
    String? description,
  }) async {
    try {
      final response = await dio.post(
        '/flashcard/decks',
        data: {
          'name': name,
          if (description != null) 'description': description,
        },
      );

      if (response.statusCode == 201) {
        return FlashcardDeckModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create deck');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<FlashcardDeckModel> updateDeck({
    required String deckId,
    String? name,
    String? description,
  }) async {
    try {
      final response = await dio.patch(
        '/flashcard/decks/$deckId',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
        },
      );

      if (response.statusCode == 200) {
        return FlashcardDeckModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update deck');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteDeck(String deckId) async {
    try {
      final response = await dio.delete('/flashcard/decks/$deckId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete deck');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<FlashcardModel>> getCardsByDeck(String deckId) async {
    try {
      final response = await dio.get('/flashcard/decks/$deckId/cards');

      if (response.statusCode == 200) {
        final data = response.data;
        final cards = data['data'] as List;
        return cards.map((json) => FlashcardModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cards');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<FlashcardModel>> getDueCards(String deckId) async {
    try {
      final response = await dio.get('/flashcard/decks/$deckId/due');

      if (response.statusCode == 200) {
        final data = response.data;
        final cards = data['data'] as List;
        return cards.map((json) => FlashcardModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load due cards');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<FlashcardModel>> getNewCards(
    String deckId, {
    int limit = 20,
  }) async {
    try {
      final response = await dio.get(
        '/flashcard/decks/$deckId/new',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final cards = data['data'] as List;
        return cards.map((json) => FlashcardModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load new cards');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<FlashcardModel> getCardById(String cardId) async {
    try {
      final response = await dio.get('/flashcard/cards/$cardId');

      if (response.statusCode == 200) {
        return FlashcardModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load card');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<FlashcardModel> createCard({
    required String deckId,
    required String kanjiId,
    required String front,
    required String back,
    String? hint,
  }) async {
    try {
      final response = await dio.post(
        '/flashcard/cards',
        data: {
          'deckId': deckId,
          'kanjiId': kanjiId,
          'front': front,
          'back': back,
          if (hint != null) 'hint': hint,
        },
      );

      if (response.statusCode == 201) {
        return FlashcardModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create card');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<FlashcardModel> updateCardReview({
    required String cardId,
    required int quality,
  }) async {
    try {
      final response = await dio.post(
        '/flashcard/cards/$cardId/review',
        data: {'quality': quality},
      );

      if (response.statusCode == 200) {
        return FlashcardModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update card review');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteCard(String cardId) async {
    try {
      final response = await dio.delete('/flashcard/cards/$cardId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete card');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<StudyProgressModel> saveProgress({
    required String deckId,
    required int cardsStudied,
    required int cardsCorrect,
    required int cardsIncorrect,
    required int studyDuration,
  }) async {
    try {
      final response = await dio.post(
        '/flashcard/progress',
        data: {
          'deckId': deckId,
          'cardsStudied': cardsStudied,
          'cardsCorrect': cardsCorrect,
          'cardsIncorrect': cardsIncorrect,
          'studyDuration': studyDuration,
        },
      );

      if (response.statusCode == 201) {
        return StudyProgressModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to save progress');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<StudyProgressModel>> getProgressHistory({
    String? deckId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (deckId != null) queryParams['deckId'] = deckId;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await dio.get(
        '/flashcard/progress',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final progressList = data['data'] as List;
        return progressList
            .map((json) => StudyProgressModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load progress history');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getStudyStatistics() async {
    try {
      final response = await dio.get('/flashcard/statistics');

      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load statistics');
      }
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
          return Exception('Not found');
        } else if (statusCode == 400) {
          return Exception('Bad request');
        }
        return Exception('Server error: $statusCode');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error');
    }
  }
}
