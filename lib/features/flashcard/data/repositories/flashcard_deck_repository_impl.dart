import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/flashcard_deck_new.dart';
import '../../domain/repositories/flashcard_deck_repository.dart';
import '../datasources/flashcard_deck_remote_datasource.dart';
import '../models/flashcard_deck_new_model.dart';

/// Implementation of FlashcardDeckRepository
class FlashcardDeckRepositoryImpl implements FlashcardDeckRepository {
  final FlashcardDeckRemoteDataSource remoteDataSource;

  FlashcardDeckRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<FlashcardDeckNew>>> getAllDecks({
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await remoteDataSource.getAllDecks(
        search: search,
        limit: limit,
        offset: offset,
      );
      final decks = response.data
          .map((model) => _modelToEntity(model))
          .toList();
      return Right(decks);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeckNew>> getDeckById(int id) async {
    try {
      final model = await remoteDataSource.getDeckById(id);
      return Right(_modelToEntity(model));
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeckNew>> createDeck({
    required String name,
    String? description,
    List<int>? kanjiIds,
  }) async {
    try {
      final model = await remoteDataSource.createDeck(
        name: name,
        description: description,
        kanjiIds: kanjiIds,
      );
      return Right(_modelToEntity(model));
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeckNew>> updateDeck({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final model = await remoteDataSource.updateDeck(
        id: id,
        name: name,
        description: description,
        isPublic: isPublic,
      );
      return Right(_modelToEntity(model));
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDeck(int id) async {
    try {
      await remoteDataSource.deleteDeck(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeckNew>> addCardToDeck(
    int deckId,
    int kanjiId,
  ) async {
    try {
      final model = await remoteDataSource.addCardToDeck(deckId, kanjiId);
      return Right(_modelToEntity(model));
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeckNew>> removeCardFromDeck(
    int deckId,
    int kanjiId,
  ) async {
    try {
      final model = await remoteDataSource.removeCardFromDeck(deckId, kanjiId);
      return Right(_modelToEntity(model));
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Convert model to entity
  FlashcardDeckNew _modelToEntity(FlashcardDeckNewModel model) {
    return FlashcardDeckNew(
      id: model.id,
      name: model.name,
      description: model.description,
      userId: model.userId,
      isPublic: model.isPublic,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      cards: model.cards
          .map(
            (cardModel) => FlashcardCardNew(
              id: cardModel.id,
              deckId: cardModel.deckId,
              kanjiId: cardModel.kanjiId,
              front: cardModel.front,
              back: cardModel.back,
              kanji: cardModel.kanji.toEntity(),
            ),
          )
          .toList(),
      userName: model.user.account,
      userEmail: model.user.email,
    );
  }

  Failure _mapExceptionToFailure(Exception e) {
    final message = e.toString();

    if (message.contains('Unauthorized')) {
      return const UnauthorizedFailure();
    } else if (message.contains('not found')) {
      return const NotFoundFailure();
    } else if (message.contains('Bad request')) {
      return BadRequestFailure(message);
    } else if (message.contains('timeout') ||
        message.contains('Network error')) {
      return const NetworkFailure();
    } else if (message.contains('Server error')) {
      return const ServerFailure();
    }

    return UnknownFailure(message);
  }
}
