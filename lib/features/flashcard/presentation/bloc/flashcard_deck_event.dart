import 'package:equatable/equatable.dart';

/// Base event for FlashcardDeck BLoC
abstract class FlashcardDeckEvent extends Equatable {
  const FlashcardDeckEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all flashcard decks
class LoadFlashcardDecksEvent extends FlashcardDeckEvent {
  final String? search;
  final int? limit;
  final int? offset;

  const LoadFlashcardDecksEvent({this.search, this.limit, this.offset});

  @override
  List<Object?> get props => [search, limit, offset];
}

/// Event to load single flashcard deck
class LoadFlashcardDeckByIdEvent extends FlashcardDeckEvent {
  final int id;

  const LoadFlashcardDeckByIdEvent(this.id);

  @override
  List<Object> get props => [id];
}

/// Event to create flashcard deck
class CreateFlashcardDeckEvent extends FlashcardDeckEvent {
  final String name;
  final String? description;
  final List<int>? kanjiIds;

  const CreateFlashcardDeckEvent({
    required this.name,
    this.description,
    this.kanjiIds,
  });

  @override
  List<Object?> get props => [name, description, kanjiIds];
}

/// Event to update flashcard deck
class UpdateFlashcardDeckEvent extends FlashcardDeckEvent {
  final int id;
  final String? name;
  final String? description;
  final bool? isPublic;

  const UpdateFlashcardDeckEvent({
    required this.id,
    this.name,
    this.description,
    this.isPublic,
  });

  @override
  List<Object?> get props => [id, name, description, isPublic];
}

/// Event to delete flashcard deck
class DeleteFlashcardDeckEvent extends FlashcardDeckEvent {
  final int id;

  const DeleteFlashcardDeckEvent(this.id);

  @override
  List<Object> get props => [id];
}

/// Event to add card to deck
class AddCardToDeckEvent extends FlashcardDeckEvent {
  final int deckId;
  final int kanjiId;

  const AddCardToDeckEvent({required this.deckId, required this.kanjiId});

  @override
  List<Object> get props => [deckId, kanjiId];
}

/// Event to remove card from deck
class RemoveCardFromDeckEvent extends FlashcardDeckEvent {
  final int deckId;
  final int kanjiId;

  const RemoveCardFromDeckEvent({required this.deckId, required this.kanjiId});

  @override
  List<Object> get props => [deckId, kanjiId];
}
