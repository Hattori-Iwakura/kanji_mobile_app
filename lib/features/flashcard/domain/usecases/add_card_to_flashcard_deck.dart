import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck_new.dart';
import '../repositories/flashcard_deck_repository.dart';

/// UseCase for adding card to flashcard deck
class AddCardToFlashcardDeck {
  final FlashcardDeckRepository repository;

  AddCardToFlashcardDeck(this.repository);

  Future<Either<Failure, FlashcardDeckNew>> call(
    int deckId,
    int kanjiId,
  ) async {
    return await repository.addCardToDeck(deckId, kanjiId);
  }
}
