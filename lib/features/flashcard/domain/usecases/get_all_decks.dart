import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck.dart';
import '../repositories/flashcard_repository.dart';

/// Use case for getting all flashcard decks
class GetAllDecks {
  final FlashcardRepository repository;

  GetAllDecks(this.repository);

  Future<Either<Failure, List<FlashcardDeck>>> call() async {
    return await repository.getAllDecks();
  }
}
