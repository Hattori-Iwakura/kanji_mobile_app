import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/flashcard_deck_repository.dart';

/// UseCase for deleting flashcard deck
class DeleteFlashcardDeck {
  final FlashcardDeckRepository repository;

  DeleteFlashcardDeck(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteDeck(id);
  }
}
