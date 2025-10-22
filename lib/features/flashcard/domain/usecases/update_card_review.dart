import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard.dart';
import '../repositories/flashcard_repository.dart';

/// Use case for updating card review (SM-2 algorithm)
class UpdateCardReview {
  final FlashcardRepository repository;

  UpdateCardReview(this.repository);

  /// Update card with quality rating (0-5)
  /// 0: Complete blackout
  /// 1: Incorrect, but familiar
  /// 2: Incorrect, but easy to recall
  /// 3: Correct, but difficult
  /// 4: Correct, with hesitation
  /// 5: Perfect response
  Future<Either<Failure, Flashcard>> call({
    required String cardId,
    required int quality,
  }) async {
    if (quality < 0 || quality > 5) {
      return Left(const BadRequestFailure());
    }

    return await repository.updateCardReview(cardId: cardId, quality: quality);
  }
}
