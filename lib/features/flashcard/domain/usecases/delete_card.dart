import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/flashcard_repository.dart';

class DeleteCard {
  final FlashcardRepository repository;

  DeleteCard(this.repository);

  Future<Either<Failure, void>> call(int cardId) async {
    return await repository.removeCardFromDeck(cardId);
  }
}
