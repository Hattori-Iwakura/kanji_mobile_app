import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/flashcard_deck.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/entities/next_card.dart';
import '../../domain/entities/deck_statistics.dart';
import '../../domain/entities/active_session.dart';
import '../../domain/entities/review_type.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../datasources/flashcard_remote_datasource.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  final FlashcardRemoteDataSource remoteDataSource;

  FlashcardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<FlashcardDeck>>> getDecks({
    String? search,
  }) async {
    try {
      final decks = await remoteDataSource.getDecks(search: search);
      return Right(decks);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeck>> getDeckById(int deckId) async {
    try {
      final deck = await remoteDataSource.getDeckById(deckId);
      return Right(deck);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeck>> createDeck({
    required String name,
    String? description,
    List<int>? kanjiIds,
  }) async {
    try {
      final deck = await remoteDataSource.createDeck(
        name: name,
        description: description,
        kanjiIds: kanjiIds,
      );
      return Right(deck);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDeck(int deckId) async {
    try {
      await remoteDataSource.deleteDeck(deckId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeck>> addCardToDeck({
    required int deckId,
    required int kanjiId,
  }) async {
    try {
      final deck = await remoteDataSource.addCardToDeck(
        deckId: deckId,
        kanjiId: kanjiId,
      );
      return Right(deck);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeck>> removeCardFromDeck({
    required int deckId,
    required int kanjiId,
  }) async {
    try {
      final deck = await remoteDataSource.removeCardFromDeck(
        deckId: deckId,
        kanjiId: kanjiId,
      );
      return Right(deck);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudySession>> startSession({
    required int deckId,
    int? maxNewCards,
    int? maxReviewCards,
    ReviewType? reviewType,
  }) async {
    try {
      final session = await remoteDataSource.startSession(
        deckId: deckId,
        maxNewCards: maxNewCards,
        maxReviewCards: maxReviewCards,
        reviewType: reviewType,
      );
      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ActiveSession?>> getActiveSession(int deckId) async {
    try {
      final activeSession = await remoteDataSource.getActiveSession(deckId);
      return Right(activeSession);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudySession>> getSessionProgress(
    int sessionId,
  ) async {
    try {
      final session = await remoteDataSource.getSessionProgress(sessionId);
      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NextCard?>> getNextCard(int sessionId) async {
    try {
      final card = await remoteDataSource.getNextCard(sessionId);
      return Right(card);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reviewCard({
    required int sessionId,
    required int cardId,
    required int quality,
    double? timeSpent,
  }) async {
    try {
      await remoteDataSource.reviewCard(
        sessionId: sessionId,
        cardId: cardId,
        quality: quality,
        timeSpent: timeSpent,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudySession>> completeSession(int sessionId) async {
    try {
      final session = await remoteDataSource.completeSession(sessionId);
      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDueCards(int deckId) async {
    try {
      final dueCards = await remoteDataSource.getDueCards(deckId);
      return Right(dueCards);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeckStatistics>> getDeckStatistics(int deckId) async {
    try {
      final stats = await remoteDataSource.getDeckStatistics(deckId);
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
