import 'package:equatable/equatable.dart';
import '../../domain/entities/flashcard_card_detail.dart';

abstract class CardDetailState extends Equatable {
  const CardDetailState();

  @override
  List<Object?> get props => [];
}

class CardDetailInitial extends CardDetailState {
  const CardDetailInitial();
}

class CardDetailLoading extends CardDetailState {
  const CardDetailLoading();
}

class CardDetailLoaded extends CardDetailState {
  final FlashcardCardDetail detail;

  const CardDetailLoaded(this.detail);

  @override
  List<Object?> get props => [detail];
}

class CardDetailError extends CardDetailState {
  final String message;

  const CardDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
