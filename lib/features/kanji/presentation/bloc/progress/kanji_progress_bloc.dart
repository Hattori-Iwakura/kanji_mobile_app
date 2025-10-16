import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/kanji_progress_usecases.dart';
import 'kanji_progress_event.dart';
import 'kanji_progress_state.dart';

class KanjiProgressBloc extends Bloc<KanjiProgressEvent, KanjiProgressState> {
  final GetProgressSummaryUseCase getProgressSummary;
  final GetKanjiProgressUseCase getKanjiProgress;
  final UpdateKanjiProgressUseCase updateKanjiProgress;
  final RecordKanjiReviewUseCase recordKanjiReview;

  KanjiProgressBloc({
    required this.getProgressSummary,
    required this.getKanjiProgress,
    required this.updateKanjiProgress,
    required this.recordKanjiReview,
  }) : super(const ProgressInitial()) {
    on<LoadProgressSummary>(_onLoadProgressSummary);
    on<LoadKanjiProgress>(_onLoadKanjiProgress);
    on<UpdateProgressEvent>(_onUpdateProgress);
    on<RecordReviewEvent>(_onRecordReview);
  }

  Future<void> _onLoadProgressSummary(
    LoadProgressSummary event,
    Emitter<KanjiProgressState> emit,
  ) async {
    emit(const ProgressLoading());

    final result = await getProgressSummary();

    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (summary) => emit(ProgressSummaryLoaded(summary)),
    );
  }

  Future<void> _onLoadKanjiProgress(
    LoadKanjiProgress event,
    Emitter<KanjiProgressState> emit,
  ) async {
    emit(const ProgressLoading());

    final result = await getKanjiProgress(event.character);

    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (progress) => emit(KanjiProgressLoaded(progress)),
    );
  }

  Future<void> _onUpdateProgress(
    UpdateProgressEvent event,
    Emitter<KanjiProgressState> emit,
  ) async {
    final result = await updateKanjiProgress(
      UpdateKanjiProgressParams(
        character: event.character,
        status: event.status,
      ),
    );

    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (progress) => emit(ProgressUpdated(progress)),
    );
  }

  Future<void> _onRecordReview(
    RecordReviewEvent event,
    Emitter<KanjiProgressState> emit,
  ) async {
    final result = await recordKanjiReview(
      RecordKanjiReviewParams(
        character: event.character,
        correct: event.correct,
      ),
    );

    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (progress) => emit(ProgressUpdated(progress)),
    );
  }
}
