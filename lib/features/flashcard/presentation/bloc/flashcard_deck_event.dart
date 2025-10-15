import 'package:equatable/equatable.dart';
import '../../domain/entities/flashcard_deck.dart';

abstract class FlashcardDeckEvent extends Equatable {
  const FlashcardDeckEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserDecksEvent extends FlashcardDeckEvent {
  const LoadUserDecksEvent();
}

class CreateDeckEvent extends FlashcardDeckEvent {
  final String name;
  final String? description;
  final String sourceType;
  final int? sourceId;
  final bool? isPublic;

  const CreateDeckEvent({
    required this.name,
    this.description,
    required this.sourceType,
    this.sourceId,
    this.isPublic,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    sourceType,
    sourceId,
    isPublic,
  ];
}

class DeleteDeckEvent extends FlashcardDeckEvent {
  final int deckId;

  const DeleteDeckEvent(this.deckId);

  @override
  List<Object> get props => [deckId];
}

class RefreshDecksEvent extends FlashcardDeckEvent {
  const RefreshDecksEvent();
}
