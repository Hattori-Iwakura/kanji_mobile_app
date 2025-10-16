import 'package:equatable/equatable.dart';
import '../../../domain/entities/kanji_progress.dart';
import '../../../domain/entities/progress_summary.dart';

abstract class KanjiProgressState extends Equatable {
  const KanjiProgressState();

  @override
  List<Object?> get props => [];
}

class ProgressInitial extends KanjiProgressState {
  const ProgressInitial();
}

class ProgressLoading extends KanjiProgressState {
  const ProgressLoading();
}

class ProgressSummaryLoaded extends KanjiProgressState {
  final ProgressSummary summary;

  const ProgressSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class KanjiProgressLoaded extends KanjiProgressState {
  final KanjiProgress? progress;

  const KanjiProgressLoaded(this.progress);

  @override
  List<Object?> get props => [progress];
}

class ProgressUpdated extends KanjiProgressState {
  final KanjiProgress progress;

  const ProgressUpdated(this.progress);

  @override
  List<Object?> get props => [progress];
}

class ProgressError extends KanjiProgressState {
  final String message;

  const ProgressError(this.message);

  @override
  List<Object?> get props => [message];
}
