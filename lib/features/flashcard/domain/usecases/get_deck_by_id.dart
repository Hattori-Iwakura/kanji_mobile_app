import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck.dart';
import '../repositories/flashcard_repository.dart';

class GetDeckById {
  final FlashcardRepository repository;

  GetDeckById(this.repository);

  Future<Either<Failure, FlashcardDeck>> call(int deckId) async {
    return await repository.getDeckById(deckId);
  }
}
