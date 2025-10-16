import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/study_session.dart';
import '../repositories/flashcard_repository.dart';

class GetActiveSessions {
  final FlashcardRepository repository;

  GetActiveSessions(this.repository);

  Future<Either<Failure, List<StudySession>>> call({int? deckId}) async {
    return repository.getActiveSessions(deckId: deckId);
  }
}
