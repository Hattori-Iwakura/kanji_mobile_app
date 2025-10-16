import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_flashcard_stats.dart';
import 'flashcard_stats_state.dart';

class FlashcardStatsCubit extends Cubit<FlashcardStatsState> {
  final GetFlashcardStats getFlashcardStats;

  FlashcardStatsCubit({required this.getFlashcardStats})
    : super(const FlashcardStatsInitial());

  Future<void> load({int? deckId}) async {
    emit(const FlashcardStatsLoading());
    final result = await getFlashcardStats(deckId: deckId);

    result.fold(
      (failure) => emit(FlashcardStatsError(failure.message)),
      (stats) => emit(FlashcardStatsLoaded(stats)),
    );
  }
}
