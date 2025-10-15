import 'package:equatable/equatable.dart';
import '../../domain/entities/flashcard_deck.dart';

abstract class DeckDetailState extends Equatable {
  const DeckDetailState();

  @override
  List<Object?> get props => [];
}

class DeckDetailInitial extends DeckDetailState {
  const DeckDetailInitial();
}

class DeckDetailLoading extends DeckDetailState {
  const DeckDetailLoading();
}

class DeckDetailLoaded extends DeckDetailState {
  final FlashcardDeck deck;

  const DeckDetailLoaded(this.deck);

  @override
  List<Object?> get props => [deck];
}

class DeckDetailError extends DeckDetailState {
  final String message;

  const DeckDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
