import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck.dart';
import '../repositories/flashcard_repository.dart';

class CreateDeck {
  final FlashcardRepository repository;

  CreateDeck(this.repository);

  Future<Either<Failure, FlashcardDeck>> call({
    required String name,
    String? description,
    required String sourceType,
    int? sourceId,
    bool? isPublic,
  }) async {
    return await repository.createDeck(
      name: name,
      description: description,
      sourceType: sourceType,
      sourceId: sourceId,
      isPublic: isPublic,
    );
  }
}
