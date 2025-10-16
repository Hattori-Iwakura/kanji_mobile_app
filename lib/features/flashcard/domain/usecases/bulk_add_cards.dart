import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/flashcard_repository.dart';

class BulkAddCards {
  final FlashcardRepository repository;

  BulkAddCards(this.repository);

  Future<Either<Failure, void>> call({
    required int deckId,
    required List<int> kanjiIds,
  }) {
    return repository.bulkAddCards(deckId: deckId, kanjiIds: kanjiIds);
  }
}
