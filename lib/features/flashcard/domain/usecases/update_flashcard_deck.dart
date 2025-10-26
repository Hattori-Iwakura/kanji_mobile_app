import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck_new.dart';
import '../repositories/flashcard_deck_repository.dart';

/// UseCase for updating flashcard deck
class UpdateFlashcardDeck {
  final FlashcardDeckRepository repository;

  UpdateFlashcardDeck(this.repository);

  Future<Either<Failure, FlashcardDeckNew>> call({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    return await repository.updateDeck(
      id: id,
      name: name,
      description: description,
      isPublic: isPublic,
    );
  }
}
