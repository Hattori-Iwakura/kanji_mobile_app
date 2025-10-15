import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck.dart';
import '../repositories/flashcard_repository.dart';

class GetUserDecks {
  final FlashcardRepository repository;

  GetUserDecks(this.repository);

  Future<Either<Failure, List<FlashcardDeck>>> call() async {
    return await repository.getUserDecks();
  }
}
