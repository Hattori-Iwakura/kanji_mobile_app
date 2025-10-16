import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_progress.dart';
import '../entities/progress_summary.dart';
import '../repositories/kanji_repository.dart';

// Get Progress Summary UseCase
class GetProgressSummaryUseCase {
  final KanjiRepository repository;

  GetProgressSummaryUseCase(this.repository);

  Future<Either<Failure, ProgressSummary>> call() async {
    return await repository.getProgressSummary();
  }
}

// Get Kanji Progress UseCase
class GetKanjiProgressUseCase {
  final KanjiRepository repository;

  GetKanjiProgressUseCase(this.repository);

  Future<Either<Failure, KanjiProgress?>> call(String character) async {
    return await repository.getKanjiProgress(character);
  }
}

// Update Progress UseCase
class UpdateKanjiProgressUseCase {
  final KanjiRepository repository;

  UpdateKanjiProgressUseCase(this.repository);

  Future<Either<Failure, KanjiProgress>> call(
    UpdateKanjiProgressParams params,
  ) async {
    return await repository.updateProgress(
      character: params.character,
      status: params.status,
    );
  }
}

class UpdateKanjiProgressParams extends Equatable {
  final String character;
  final ProgressStatus status;

  const UpdateKanjiProgressParams({
    required this.character,
    required this.status,
  });

  @override
  List<Object?> get props => [character, status];
}

// Record Review UseCase
class RecordKanjiReviewUseCase {
  final KanjiRepository repository;

  RecordKanjiReviewUseCase(this.repository);

  Future<Either<Failure, KanjiProgress>> call(
    RecordKanjiReviewParams params,
  ) async {
    return await repository.recordReview(
      character: params.character,
      correct: params.correct,
    );
  }
}

class RecordKanjiReviewParams extends Equatable {
  final String character;
  final bool correct;

  const RecordKanjiReviewParams({
    required this.character,
    required this.correct,
  });

  @override
  List<Object?> get props => [character, correct];
}
