import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck.dart';
import '../entities/flashcard_card.dart';
import '../entities/study_session.dart';
import '../entities/flashcard_card_detail.dart';
import '../entities/flashcard_stats.dart';

abstract class FlashcardRepository {
  // Deck operations
  Future<Either<Failure, FlashcardDeck>> createDeck({
    required String name,
    String? description,
    required String sourceType,
    int? sourceId,
    bool? isPublic,
  });

  Future<Either<Failure, List<FlashcardDeck>>> getUserDecks();

  Future<Either<Failure, FlashcardDeck>> getDeckById(int deckId);

  Future<Either<Failure, FlashcardCardDetail>> getCardDetail(int cardId);

  Future<Either<Failure, FlashcardDeck>> updateDeck({
    required int deckId,
    String? name,
    String? description,
    bool? isPublic,
  });

  Future<Either<Failure, void>> deleteDeck(int deckId);

  // Card operations
  Future<Either<Failure, FlashcardCard>> addCardToDeck({
    required int deckId,
    required int kanjiId,
  });

  Future<Either<Failure, void>> removeCardFromDeck(int cardId);

  Future<Either<Failure, void>> bulkAddCards({
    required int deckId,
    required List<int> kanjiIds,
  });

  Future<Either<Failure, void>> reorderCards({
    required int deckId,
    required List<int> cardIds,
  });

  // Study session operations
  Future<Either<Failure, StudySession>> startStudySession({
    required int deckId,
    int? maxCards,
    String? mode,
    bool? randomize,
    bool? includeNew,
    bool? includeDue,
    bool? includeHard,
    int? difficultyThreshold,
    bool? resumeExisting,
  });

  Future<Either<Failure, Map<String, dynamic>>> reviewCard({
    required int sessionId,
    required int cardId,
    required int rating,
    required int timeSpent,
  });

  Future<Either<Failure, StudySession>> completeSession(int sessionId);

  Future<Either<Failure, StudySession>> pauseSession(int sessionId);

  Future<Either<Failure, StudySession>> resumeSession(int sessionId);

  Future<Either<Failure, StudySession>> getSessionDetail(int sessionId);

  Future<Either<Failure, List<StudySession>>> getActiveSessions({int? deckId});

  Future<Either<Failure, List<StudySession>>> getStudyHistory({int? deckId});

  Future<Either<Failure, FlashcardStats>> getStats({int? deckId});
}
