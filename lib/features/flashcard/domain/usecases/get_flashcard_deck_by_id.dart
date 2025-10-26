import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_deck_new.dart';
import '../repositories/flashcard_deck_repository.dart';

/// UseCase for getting flashcard deck by ID
class GetFlashcardDeckById {
  final FlashcardDeckRepository repository;

  GetFlashcardDeckById(this.repository);

  Future<Either<Failure, FlashcardDeckNew>> call(int id) async {
    return await repository.getDeckById(id);
  }
}
