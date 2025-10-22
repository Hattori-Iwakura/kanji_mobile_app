import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard.dart';
import '../entities/flashcard_deck.dart';
import '../entities/study_progress.dart';

/// Repository interface for Flashcard operations
abstract class FlashcardRepository {
  // ========== DECK OPERATIONS ==========
  /// Get all decks for current user
  Future<Either<Failure, List<FlashcardDeck>>> getAllDecks();

  /// Get deck by ID
  Future<Either<Failure, FlashcardDeck>> getDeckById(String deckId);

  /// Create new deck
  Future<Either<Failure, FlashcardDeck>> createDeck({
    required String name,
    String? description,
  });

  /// Update deck
  Future<Either<Failure, FlashcardDeck>> updateDeck({
    required String deckId,
    String? name,
    String? description,
  });

  /// Delete deck
  Future<Either<Failure, void>> deleteDeck(String deckId);

  // ========== FLASHCARD OPERATIONS ==========
  /// Get all cards in a deck
  Future<Either<Failure, List<Flashcard>>> getCardsByDeck(String deckId);

  /// Get due cards (cards that need review today)
  Future<Either<Failure, List<Flashcard>>> getDueCards(String deckId);

  /// Get new cards (never reviewed)
  Future<Either<Failure, List<Flashcard>>> getNewCards(
    String deckId, {
    int limit = 20,
  });

  /// Get card by ID
  Future<Either<Failure, Flashcard>> getCardById(String cardId);

  /// Create new flashcard
  Future<Either<Failure, Flashcard>> createCard({
    required String deckId,
    required String kanjiId,
    required String front,
    required String back,
    String? hint,
  });

  /// Update flashcard review (after user answers)
  Future<Either<Failure, Flashcard>> updateCardReview({
    required String cardId,
    required int quality, // 0-5 (SM-2 algorithm)
  });

  /// Delete flashcard
  Future<Either<Failure, void>> deleteCard(String cardId);

  // ========== PROGRESS OPERATIONS ==========
  /// Save study session progress
  Future<Either<Failure, StudyProgress>> saveProgress({
    required String deckId,
    required int cardsStudied,
    required int cardsCorrect,
    required int cardsIncorrect,
    required int studyDuration,
  });

  /// Get progress history
  Future<Either<Failure, List<StudyProgress>>> getProgressHistory({
    String? deckId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get study statistics (total cards studied, accuracy, etc.)
  Future<Either<Failure, Map<String, dynamic>>> getStudyStatistics();
}
