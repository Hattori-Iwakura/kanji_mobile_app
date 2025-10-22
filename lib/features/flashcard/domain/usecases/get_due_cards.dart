import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard.dart';
import '../repositories/flashcard_repository.dart';

/// Use case for getting due cards (cards to review)
class GetDueCards {
  final FlashcardRepository repository;

  GetDueCards(this.repository);

  Future<Either<Failure, List<Flashcard>>> call(String deckId) async {
    return await repository.getDueCards(deckId);
  }
}
