import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck.dart';
import '../entities/study_session.dart';
import '../entities/next_card.dart';
import '../entities/deck_statistics.dart';
import '../repositories/flashcard_repository.dart';

// ==================== DECK MANAGEMENT ====================

class GetDecksUseCase {
  final FlashcardRepository repository;

  GetDecksUseCase(this.repository);

  Future<Either<Failure, List<FlashcardDeck>>> call({String? search}) {
    return repository.getDecks(search: search);
  }
}

class GetDeckByIdUseCase {
  final FlashcardRepository repository;

  GetDeckByIdUseCase(this.repository);

  Future<Either<Failure, FlashcardDeck>> call(int deckId) {
    return repository.getDeckById(deckId);
  }
}

class CreateDeckUseCase {
  final FlashcardRepository repository;

  CreateDeckUseCase(this.repository);

  Future<Either<Failure, FlashcardDeck>> call({
    required String name,
    String? description,
    List<int>? kanjiIds,
  }) {
    return repository.createDeck(
      name: name,
      description: description,
      kanjiIds: kanjiIds,
    );
  }
}

class UpdateDeckUseCase {
  final FlashcardRepository repository;

  UpdateDeckUseCase(this.repository);

  Future<Either<Failure, FlashcardDeck>> call({
    required int deckId,
    String? name,
    String? description,
    bool? isPublic,
  }) {
    return repository.updateDeck(
      deckId: deckId,
      name: name,
      description: description,
      isPublic: isPublic,
    );
  }
}

class DeleteDeckUseCase {
  final FlashcardRepository repository;

  DeleteDeckUseCase(this.repository);

  Future<Either<Failure, void>> call(int deckId) {
    return repository.deleteDeck(deckId);
  }
}

class AddCardToDeckUseCase {
  final FlashcardRepository repository;

  AddCardToDeckUseCase(this.repository);

  Future<Either<Failure, FlashcardDeck>> call({
    required int deckId,
    required int kanjiId,
  }) {
    return repository.addCardToDeck(deckId: deckId, kanjiId: kanjiId);
  }
}

class RemoveCardFromDeckUseCase {
  final FlashcardRepository repository;

  RemoveCardFromDeckUseCase(this.repository);

  Future<Either<Failure, FlashcardDeck>> call({
    required int deckId,
    required int kanjiId,
  }) {
    return repository.removeCardFromDeck(deckId: deckId, kanjiId: kanjiId);
  }
}

// ==================== STUDY SESSION ====================

class StartSessionUseCase {
  final FlashcardRepository repository;

  StartSessionUseCase(this.repository);

  Future<Either<Failure, StudySession>> call({
    required int deckId,
    int? maxNewCards,
    int? maxReviewCards,
  }) {
    return repository.startSession(
      deckId: deckId,
      maxNewCards: maxNewCards,
      maxReviewCards: maxReviewCards,
    );
  }
}

class GetSessionProgressUseCase {
  final FlashcardRepository repository;

  GetSessionProgressUseCase(this.repository);

  Future<Either<Failure, StudySession>> call(int sessionId) {
    return repository.getSessionProgress(sessionId);
  }
}

class GetNextCardUseCase {
  final FlashcardRepository repository;

  GetNextCardUseCase(this.repository);

  Future<Either<Failure, NextCard?>> call(int sessionId) {
    return repository.getNextCard(sessionId);
  }
}

class ReviewCardUseCase {
  final FlashcardRepository repository;

  ReviewCardUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required int sessionId,
    required int cardId,
    required int quality,
    double? timeSpent,
  }) {
    return repository.reviewCard(
      sessionId: sessionId,
      cardId: cardId,
      quality: quality,
      timeSpent: timeSpent,
    );
  }
}

class CompleteSessionUseCase {
  final FlashcardRepository repository;

  CompleteSessionUseCase(this.repository);

  Future<Either<Failure, StudySession>> call(int sessionId) {
    return repository.completeSession(sessionId);
  }
}

// ==================== STATISTICS ====================

class GetDueCardsUseCase {
  final FlashcardRepository repository;

  GetDueCardsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(int deckId) {
    return repository.getDueCards(deckId);
  }
}

class GetDeckStatisticsUseCase {
  final FlashcardRepository repository;

  GetDeckStatisticsUseCase(this.repository);

  Future<Either<Failure, DeckStatistics>> call(int deckId) {
    return repository.getDeckStatistics(deckId);
  }
}
