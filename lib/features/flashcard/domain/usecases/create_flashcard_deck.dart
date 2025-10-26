import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck_new.dart';
import '../repositories/flashcard_deck_repository.dart';

/// UseCase for creating flashcard deck
class CreateFlashcardDeck {
  final FlashcardDeckRepository repository;

  CreateFlashcardDeck(this.repository);

  Future<Either<Failure, FlashcardDeckNew>> call({
    required String name,
    String? description,
    List<int>? kanjiIds,
  }) async {
    return await repository.createDeck(
      name: name,
      description: description,
      kanjiIds: kanjiIds,
    );
  }
}
