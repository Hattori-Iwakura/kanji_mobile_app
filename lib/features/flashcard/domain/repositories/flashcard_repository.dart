import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck.dart';
import '../entities/flashcard_card.dart';
import '../entities/study_session.dart';
import '../entities/next_card.dart';
import '../entities/deck_statistics.dart';

abstract class FlashcardRepository {
  // Deck Management
  Future<Either<Failure, List<FlashcardDeck>>> getDecks({String? search});
  Future<Either<Failure, FlashcardDeck>> getDeckById(int deckId);
  Future<Either<Failure, FlashcardDeck>> createDeck({
    required String name,
    String? description,
    List<int>? kanjiIds,
  });
  Future<Either<Failure, FlashcardDeck>> updateDeck({
    required int deckId,
    String? name,
    String? description,
    bool? isPublic,
  });
  Future<Either<Failure, void>> deleteDeck(int deckId);
  Future<Either<Failure, FlashcardDeck>> addCardToDeck({
    required int deckId,
    required int kanjiId,
  });
  Future<Either<Failure, FlashcardDeck>> removeCardFromDeck({
    required int deckId,
    required int kanjiId,
  });

  // Study Session Management
  Future<Either<Failure, StudySession>> startSession({
    required int deckId,
    int? maxNewCards,
    int? maxReviewCards,
  });
  Future<Either<Failure, StudySession>> getSessionProgress(int sessionId);
  Future<Either<Failure, NextCard?>> getNextCard(int sessionId);
  Future<Either<Failure, void>> reviewCard({
    required int sessionId,
    required int cardId,
    required int quality,
    double? timeSpent,
  });
  Future<Either<Failure, StudySession>> completeSession(int sessionId);

  // Statistics
  Future<Either<Failure, Map<String, dynamic>>> getDueCards(int deckId);
  Future<Either<Failure, DeckStatistics>> getDeckStatistics(int deckId);
}
