import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/active_session.dart';
import '../repositories/flashcard_repository.dart';

class GetActiveSessionUseCase {
  final FlashcardRepository repository;

  GetActiveSessionUseCase(this.repository);

  Future<Either<Failure, ActiveSession?>> call(int deckId) async {
    return await repository.getActiveSession(deckId);
  }
}
