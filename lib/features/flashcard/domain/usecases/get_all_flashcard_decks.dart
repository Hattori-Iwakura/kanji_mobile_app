import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck_new.dart';
import '../repositories/flashcard_deck_repository.dart';

/// UseCase for getting all flashcard decks
class GetAllFlashcardDecks {
  final FlashcardDeckRepository repository;

  GetAllFlashcardDecks(this.repository);

  Future<Either<Failure, List<FlashcardDeckNew>>> call({
    String? search,
    int? limit,
    int? offset,
  }) async {
    return await repository.getAllDecks(
      search: search,
      limit: limit,
      offset: offset,
    );
  }
}
