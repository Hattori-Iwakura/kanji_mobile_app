import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck_new.dart';
import '../repositories/flashcard_deck_repository.dart';

/// UseCase for removing card from flashcard deck
class RemoveCardFromFlashcardDeck {
  final FlashcardDeckRepository repository;

  RemoveCardFromFlashcardDeck(this.repository);

  Future<Either<Failure, FlashcardDeckNew>> call(
    int deckId,
    int kanjiId,
  ) async {
    return await repository.removeCardFromDeck(deckId, kanjiId);
  }
}
