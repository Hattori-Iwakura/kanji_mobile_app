import 'package:equatable/equatable.dart';
import '../../../domain/entities/kanji_progress.dart';

abstract class KanjiProgressEvent extends Equatable {
  const KanjiProgressEvent();

  @override
  List<Object?> get props => [];
}

class LoadProgressSummary extends KanjiProgressEvent {
  const LoadProgressSummary();
}

class LoadKanjiProgress extends KanjiProgressEvent {
  final String character;

  const LoadKanjiProgress(this.character);

  @override
  List<Object?> get props => [character];
}

class UpdateProgressEvent extends KanjiProgressEvent {
  final String character;
  final ProgressStatus status;

  const UpdateProgressEvent({required this.character, required this.status});

  @override
  List<Object?> get props => [character, status];
}

class RecordReviewEvent extends KanjiProgressEvent {
  final String character;
  final bool correct;

  const RecordReviewEvent({required this.character, required this.correct});

  @override
  List<Object?> get props => [character, correct];
}
