import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/flashcard_repository.dart';

class ReviewCard {
  final FlashcardRepository repository;

  ReviewCard(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required int sessionId,
    required int cardId,
    required int rating,
    required int timeSpent,
  }) async {
    return await repository.reviewCard(
      sessionId: sessionId,
      cardId: cardId,
      rating: rating,
      timeSpent: timeSpent,
    );
  }
}
