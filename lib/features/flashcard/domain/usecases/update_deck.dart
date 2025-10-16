import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck.dart';
import '../repositories/flashcard_repository.dart';

class UpdateDeck {
  final FlashcardRepository repository;

  UpdateDeck(this.repository);

  Future<Either<Failure, FlashcardDeck>> call({
    required int deckId,
    String? name,
    String? description,
    bool? isPublic,
  }) {
    return repository.updateDeck(
      deckId: deckId,
      name: name,
      description: description,
      isPublic: isPublic,
    );
  }
}
