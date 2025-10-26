import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck_new.dart';

/// Repository interface for Flashcard Deck operations
abstract class FlashcardDeckRepository {
  /// Get all flashcard decks (public + user's own)
  Future<Either<Failure, List<FlashcardDeckNew>>> getAllDecks({
    String? search,
    int? limit,
    int? offset,
  });

  /// Get single deck by ID
  Future<Either<Failure, FlashcardDeckNew>> getDeckById(int id);

  /// Create new flashcard deck
  Future<Either<Failure, FlashcardDeckNew>> createDeck({
    required String name,
    String? description,
    List<int>? kanjiIds,
  });

  /// Update flashcard deck
  Future<Either<Failure, FlashcardDeckNew>> updateDeck({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  });

  /// Delete flashcard deck
  Future<Either<Failure, void>> deleteDeck(int id);

  /// Add kanji card to deck
  Future<Either<Failure, FlashcardDeckNew>> addCardToDeck(
    int deckId,
    int kanjiId,
  );

  /// Remove kanji card from deck
  Future<Either<Failure, FlashcardDeckNew>> removeCardFromDeck(
    int deckId,
    int kanjiId,
  );
}
