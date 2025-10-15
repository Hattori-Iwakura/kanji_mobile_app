import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_card.dart';
import '../repositories/flashcard_repository.dart';

class AddCardToDeck {
  final FlashcardRepository repository;

  AddCardToDeck(this.repository);

  Future<Either<Failure, FlashcardCard>> call({
    required int deckId,
    required int kanjiId,
  }) async {
    return await repository.addCardToDeck(deckId: deckId, kanjiId: kanjiId);
  }
}
