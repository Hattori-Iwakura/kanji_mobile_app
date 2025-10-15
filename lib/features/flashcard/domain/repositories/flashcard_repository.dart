import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck.dart';
import '../entities/flashcard_card.dart';
import '../entities/study_session.dart';

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

  // Study session operations
  Future<Either<Failure, StudySession>> startStudySession({
    required int deckId,
    int? maxCards,
  });

  Future<Either<Failure, Map<String, dynamic>>> reviewCard({
    required int sessionId,
    required int cardId,
    required int rating,
    required int timeSpent,
  });

  Future<Either<Failure, StudySession>> completeSession(int sessionId);

  Future<Either<Failure, List<StudySession>>> getStudyHistory({int? deckId});
}
