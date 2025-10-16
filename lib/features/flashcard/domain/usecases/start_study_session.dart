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
    String? mode,
    bool? randomize,
    bool? includeNew,
    bool? includeDue,
    bool? includeHard,
    int? difficultyThreshold,
    bool? resumeExisting,
  }) async {
    return await repository.startStudySession(
      deckId: deckId,
      maxCards: maxCards,
      mode: mode,
      randomize: randomize,
      includeNew: includeNew,
      includeDue: includeDue,
      includeHard: includeHard,
      difficultyThreshold: difficultyThreshold,
      resumeExisting: resumeExisting,
    );
  }
}
