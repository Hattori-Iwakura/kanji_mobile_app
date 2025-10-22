import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/entities/flashcard_deck.dart';
import '../../domain/entities/study_progress.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../datasources/flashcard_remote_datasource.dart';
import '../datasources/flashcard_local_datasource.dart';

/// Implementation of FlashcardRepository with caching
class FlashcardRepositoryImpl implements FlashcardRepository {
  final FlashcardRemoteDataSource remoteDataSource;
  final FlashcardLocalDataSource localDataSource;

  FlashcardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<FlashcardDeck>>> getAllDecks() async {
    try {
      // Try remote first
      final deckModels = await remoteDataSource.getAllDecks();

      // Cache for offline use
      await localDataSource.cacheDecks(deckModels);

      final decks = deckModels.map((model) => model.toEntity()).toList();
      return Right(decks);
    } on Exception catch (e) {
      // Try cache if network fails
      final cachedDecks = await localDataSource.getCachedDecks();
      if (cachedDecks != null) {
        final decks = cachedDecks.map((model) => model.toEntity()).toList();
        return Right(decks);
      }
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeck>> getDeckById(String deckId) async {
    try {
      final deckModel = await remoteDataSource.getDeckById(deckId);
      return Right(deckModel.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeck>> createDeck({
    required String name,
    String? description,
  }) async {
    try {
      final deckModel = await remoteDataSource.createDeck(
        name: name,
        description: description,
      );
      return Right(deckModel.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeck>> updateDeck({
    required String deckId,
    String? name,
    String? description,
  }) async {
    try {
      final deckModel = await remoteDataSource.updateDeck(
        deckId: deckId,
        name: name,
        description: description,
      );
      return Right(deckModel.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDeck(String deckId) async {
    try {
      await remoteDataSource.deleteDeck(deckId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Flashcard>>> getCardsByDeck(String deckId) async {
    try {
      final cardModels = await remoteDataSource.getCardsByDeck(deckId);

      // Cache for offline use
      await localDataSource.cacheCards(deckId, cardModels);

      final cards = cardModels.map((model) => model.toEntity()).toList();
      return Right(cards);
    } on Exception catch (e) {
      // Try cache if network fails
      final cachedCards = await localDataSource.getCachedCards(deckId);
      if (cachedCards != null) {
        final cards = cachedCards.map((model) => model.toEntity()).toList();
        return Right(cards);
      }
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Flashcard>>> getDueCards(String deckId) async {
    try {
      final cardModels = await remoteDataSource.getDueCards(deckId);
      final cards = cardModels.map((model) => model.toEntity()).toList();
      return Right(cards);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Flashcard>>> getNewCards(
    String deckId, {
    int limit = 20,
  }) async {
    try {
      final cardModels = await remoteDataSource.getNewCards(
        deckId,
        limit: limit,
      );
      final cards = cardModels.map((model) => model.toEntity()).toList();
      return Right(cards);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Flashcard>> getCardById(String cardId) async {
    try {
      final cardModel = await remoteDataSource.getCardById(cardId);
      return Right(cardModel.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Flashcard>> createCard({
    required String deckId,
    required String kanjiId,
    required String front,
    required String back,
    String? hint,
  }) async {
    try {
      final cardModel = await remoteDataSource.createCard(
        deckId: deckId,
        kanjiId: kanjiId,
        front: front,
        back: back,
        hint: hint,
      );
      return Right(cardModel.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Flashcard>> updateCardReview({
    required String cardId,
    required int quality,
  }) async {
    try {
      final cardModel = await remoteDataSource.updateCardReview(
        cardId: cardId,
        quality: quality,
      );

      // Update cache for offline use
      await localDataSource.updateCachedCard(cardModel);

      return Right(cardModel.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCard(String cardId) async {
    try {
      await remoteDataSource.deleteCard(cardId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, StudyProgress>> saveProgress({
    required String deckId,
    required int cardsStudied,
    required int cardsCorrect,
    required int cardsIncorrect,
    required int studyDuration,
  }) async {
    try {
      final progressModel = await remoteDataSource.saveProgress(
        deckId: deckId,
        cardsStudied: cardsStudied,
        cardsCorrect: cardsCorrect,
        cardsIncorrect: cardsIncorrect,
        studyDuration: studyDuration,
      );
      return Right(progressModel.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<StudyProgress>>> getProgressHistory({
    String? deckId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final progressModels = await remoteDataSource.getProgressHistory(
        deckId: deckId,
        startDate: startDate,
        endDate: endDate,
      );
      final progressList = progressModels
          .map((model) => model.toEntity())
          .toList();
      return Right(progressList);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStudyStatistics() async {
    try {
      final stats = await remoteDataSource.getStudyStatistics();
      return Right(stats);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(Exception e) {
    final message = e.toString();

    if (message.contains('Unauthorized')) {
      return const UnauthorizedFailure();
    } else if (message.contains('Not found')) {
      return const NotFoundFailure();
    } else if (message.contains('Bad request')) {
      return const BadRequestFailure();
    } else if (message.contains('timeout') ||
        message.contains('Network error')) {
      return const NetworkFailure();
    } else if (message.contains('Server error')) {
      return const ServerFailure();
    }

    return UnknownFailure(message);
  }
}
