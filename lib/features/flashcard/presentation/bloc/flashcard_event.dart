import 'package:equatable/equatable.dart';

abstract class FlashcardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Deck events
class LoadAllDecksEvent extends FlashcardEvent {
  final String? search;
  final int? limit;
  final int? offset;

  LoadAllDecksEvent({this.search, this.limit, this.offset});

  @override
  List<Object?> get props => [search, limit, offset];
}

class LoadDeckByIdEvent extends FlashcardEvent {
  final int id;

  LoadDeckByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateDeckEvent extends FlashcardEvent {
  final String name;
  final String? description;
  final List<int>? kanjiIds;

  CreateDeckEvent({required this.name, this.description, this.kanjiIds});

  @override
  List<Object?> get props => [name, description, kanjiIds];
}

class UpdateDeckEvent extends FlashcardEvent {
  final int id;
  final String? name;
  final String? description;
  final bool? isPublic;

  UpdateDeckEvent({
    required this.id,
    this.name,
    this.description,
    this.isPublic,
  });

  @override
  List<Object?> get props => [id, name, description, isPublic];
}

class DeleteDeckEvent extends FlashcardEvent {
  final int id;

  DeleteDeckEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// Card events
class AddCardEvent extends FlashcardEvent {
  final int deckId;
  final int kanjiId;

  AddCardEvent({required this.deckId, required this.kanjiId});

  @override
  List<Object?> get props => [deckId, kanjiId];
}

class RemoveCardEvent extends FlashcardEvent {
  final int deckId;
  final int kanjiId;

  RemoveCardEvent({required this.deckId, required this.kanjiId});

  @override
  List<Object?> get props => [deckId, kanjiId];
}

// Publish events
class RequestPublishEvent extends FlashcardEvent {
  final int deckId;

  RequestPublishEvent(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

class LoadPublishRequestsEvent extends FlashcardEvent {
  final String? status;

  LoadPublishRequestsEvent({this.status});

  @override
  List<Object?> get props => [status];
}

class ApprovePublishRequestEvent extends FlashcardEvent {
  final int requestId;

  ApprovePublishRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class RejectPublishRequestEvent extends FlashcardEvent {
  final int requestId;
  final String? reason;

  RejectPublishRequestEvent(this.requestId, {this.reason});

  @override
  List<Object?> get props => [requestId, reason];
}

// Utility event
class RefreshDecksEvent extends FlashcardEvent {}
