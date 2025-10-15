import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/flashcard_repository.dart';

class DeleteDeck {
  final FlashcardRepository repository;

  DeleteDeck(this.repository);

  Future<Either<Failure, void>> call(int deckId) async {
    return await repository.deleteDeck(deckId);
  }
}
