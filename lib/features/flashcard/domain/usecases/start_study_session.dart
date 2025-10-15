import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/study_session.dart';
import '../repositories/flashcard_repository.dart';

class StartStudySession {
  final FlashcardRepository repository;

  StartStudySession(this.repository);

  Future<Either<Failure, StudySession>> call({
    required int deckId,
    int? maxCards,
  }) async {
    return await repository.startStudySession(
      deckId: deckId,
      maxCards: maxCards,
    );
  }
}
