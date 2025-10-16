import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/flashcard_repository.dart';

class ReorderCards {
  final FlashcardRepository repository;

  ReorderCards(this.repository);

  Future<Either<Failure, void>> call({
    required int deckId,
    required List<int> cardIds,
  }) {
    return repository.reorderCards(deckId: deckId, cardIds: cardIds);
  }
}
