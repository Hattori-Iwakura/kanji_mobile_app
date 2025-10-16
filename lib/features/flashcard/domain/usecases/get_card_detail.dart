import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/flashcard_card_detail.dart';
import '../repositories/flashcard_repository.dart';

class GetCardDetail {
  final FlashcardRepository repository;

  GetCardDetail(this.repository);

  Future<Either<Failure, FlashcardCardDetail>> call(int cardId) {
    return repository.getCardDetail(cardId);
  }
}
