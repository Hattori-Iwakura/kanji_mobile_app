import 'package:equatable/equatable.dart';
import '../../domain/entities/flashcard_stats.dart';

abstract class FlashcardStatsState extends Equatable {
  const FlashcardStatsState();

  @override
  List<Object?> get props => [];
}

class FlashcardStatsInitial extends FlashcardStatsState {
  const FlashcardStatsInitial();
}

class FlashcardStatsLoading extends FlashcardStatsState {
  const FlashcardStatsLoading();
}

class FlashcardStatsLoaded extends FlashcardStatsState {
  final FlashcardStats stats;

  const FlashcardStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class FlashcardStatsError extends FlashcardStatsState {
  final String message;

  const FlashcardStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
