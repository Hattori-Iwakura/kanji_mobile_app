import 'package:equatable/equatable.dart';

abstract class DeckDetailEvent extends Equatable {
  const DeckDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeckDetailEvent extends DeckDetailEvent {
  final int deckId;

  const LoadDeckDetailEvent(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

class AddCardToDeckEvent extends DeckDetailEvent {
  final int deckId;
  final int kanjiId;

  const AddCardToDeckEvent({required this.deckId, required this.kanjiId});

  @override
  List<Object?> get props => [deckId, kanjiId];
}

class DeleteCardEvent extends DeckDetailEvent {
  final int cardId;

  const DeleteCardEvent(this.cardId);

  @override
  List<Object?> get props => [cardId];
}

class RefreshDeckDetailEvent extends DeckDetailEvent {
  final int deckId;

  const RefreshDeckDetailEvent(this.deckId);

  @override
  List<Object?> get props => [deckId];
}
