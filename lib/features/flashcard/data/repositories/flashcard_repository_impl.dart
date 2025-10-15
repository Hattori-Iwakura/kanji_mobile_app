import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/flashcard_deck.dart';
import '../../domain/entities/flashcard_card.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../datasources/flashcard_remote_data_source.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  final FlashcardRemoteDataSource remoteDataSource;

  FlashcardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FlashcardDeck>> createDeck({
    required String name,
    String? description,
    required String sourceType,
    int? sourceId,
    bool? isPublic,
  }) async {
    try {
      final deck = await remoteDataSource.createDeck(
        name: name,
        description: description,
        sourceType: sourceType,
        sourceId: sourceId,
        isPublic: isPublic,
      );
      return Right(deck);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FlashcardDeck>>> getUserDecks() async {
    try {
      final decks = await remoteDataSource.getUserDecks();
      return Right(decks);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeck>> getDeckById(int deckId) async {
    try {
      final deck = await remoteDataSource.getDeckById(deckId);
      return Right(deck);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeck>> updateDeck({
    required int deckId,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final deck = await remoteDataSource.updateDeck(
        deckId: deckId,
        name: name,
        description: description,
        isPublic: isPublic,
      );
      return Right(deck);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDeck(int deckId) async {
    try {
      await remoteDataSource.deleteDeck(deckId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlashcardCard>> addCardToDeck({
    required int deckId,
    required int kanjiId,
  }) async {
    try {
      final card = await remoteDataSource.addCardToDeck(
        deckId: deckId,
        kanjiId: kanjiId,
      );
      return Right(card);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeCardFromDeck(int cardId) async {
    try {
      await remoteDataSource.removeCardFromDeck(cardId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudySession>> startStudySession({
    required int deckId,
    int? maxCards,
  }) async {
    try {
      final session = await remoteDataSource.startStudySession(
        deckId: deckId,
        maxCards: maxCards,
      );
      return Right(session);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> reviewCard({
    required int sessionId,
    required int cardId,
    required int rating,
    required int timeSpent,
  }) async {
    try {
      final result = await remoteDataSource.reviewCard(
        sessionId: sessionId,
        cardId: cardId,
        rating: rating,
        timeSpent: timeSpent,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudySession>> completeSession(int sessionId) async {
    try {
      final session = await remoteDataSource.completeSession(sessionId);
      return Right(session);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudySession>>> getStudyHistory({
    int? deckId,
  }) async {
    try {
      final history = await remoteDataSource.getStudyHistory(deckId: deckId);
      return Right(history);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
