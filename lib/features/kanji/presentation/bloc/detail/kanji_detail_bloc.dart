import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_kanji_detail.dart';
import '../../../domain/usecases/get_kanji_examples.dart';
import 'kanji_detail_event.dart';
import 'kanji_detail_state.dart';

class KanjiDetailBloc extends Bloc<KanjiDetailEvent, KanjiDetailState> {
  final GetKanjiDetailUseCase getKanjiDetail;
  final GetKanjiExamplesUseCase getKanjiExamples;

  KanjiDetailBloc({
    required this.getKanjiDetail,
    required this.getKanjiExamples,
  }) : super(const DetailInitial()) {
    on<LoadKanjiDetail>(_onLoadKanjiDetail);
    on<LoadMoreExamples>(_onLoadMoreExamples);
    on<RefreshKanjiDetail>(_onRefreshKanjiDetail);
  }

  Future<void> _onLoadKanjiDetail(
    LoadKanjiDetail event,
    Emitter<KanjiDetailState> emit,
  ) async {
    emit(const DetailLoading());

    final result = await getKanjiDetail(event.character);

    result.fold((failure) => emit(DetailError(failure.message)), (detail) {
      emit(DetailLoaded(detail: detail, allExamples: detail.examples));
    });
  }

  Future<void> _onLoadMoreExamples(
    LoadMoreExamples event,
    Emitter<KanjiDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DetailLoaded) return;

    emit(
      DetailLoadingMore(
        detail: currentState.detail,
        currentExamples: currentState.allExamples,
      ),
    );

    // Load more examples (next 10)
    final params = GetKanjiExamplesParams(
      character: event.character,
      limit: event.currentCount + 10,
    );

    final result = await getKanjiExamples(params);

    result.fold(
      (failure) {
        // On error, go back to previous state
        emit(currentState);
      },
      (newExamples) {
        emit(currentState.copyWith(allExamples: newExamples));
      },
    );
  }

  Future<void> _onRefreshKanjiDetail(
    RefreshKanjiDetail event,
    Emitter<KanjiDetailState> emit,
  ) async {
    // Refresh without showing loading state
    final result = await getKanjiDetail(event.character);

    result.fold((failure) => emit(DetailError(failure.message)), (detail) {
      emit(DetailLoaded(detail: detail, allExamples: detail.examples));
    });
  }
}
