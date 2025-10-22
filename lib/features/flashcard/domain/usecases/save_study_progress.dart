import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/study_progress.dart';
import '../repositories/flashcard_repository.dart';

/// Use case for saving study session progress
class SaveStudyProgress {
  final FlashcardRepository repository;

  SaveStudyProgress(this.repository);

  Future<Either<Failure, StudyProgress>> call({
    required String deckId,
    required int cardsStudied,
    required int cardsCorrect,
    required int cardsIncorrect,
    required int studyDuration,
  }) async {
    return await repository.saveProgress(
      deckId: deckId,
      cardsStudied: cardsStudied,
      cardsCorrect: cardsCorrect,
      cardsIncorrect: cardsIncorrect,
      studyDuration: studyDuration,
    );
  }
}
