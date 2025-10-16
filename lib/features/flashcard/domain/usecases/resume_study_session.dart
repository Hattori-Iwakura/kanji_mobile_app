import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/study_session.dart';
import '../repositories/flashcard_repository.dart';

class ResumeStudySession {
  final FlashcardRepository repository;

  ResumeStudySession(this.repository);

  Future<Either<Failure, StudySession>> call(int sessionId) async {
    return repository.resumeSession(sessionId);
  }
}
