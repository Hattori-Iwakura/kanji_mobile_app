import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_stats.dart';
import '../repositories/flashcard_repository.dart';

class GetFlashcardStats {
  final FlashcardRepository repository;

  GetFlashcardStats(this.repository);

  Future<Either<Failure, FlashcardStats>> call({int? deckId}) {
    return repository.getStats(deckId: deckId);
  }
}
