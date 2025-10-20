import 'package:equatable/equatable.dart';

abstract class KanjiListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// List events
class LoadAllListsEvent extends KanjiListEvent {
  final String? search;
  final String? type;
  final int? limit;
  final int? offset;

  LoadAllListsEvent({this.search, this.type, this.limit, this.offset});

  @override
  List<Object?> get props => [search, type, limit, offset];
}

class LoadListByIdEvent extends KanjiListEvent {
  final int id;

  LoadListByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateListEvent extends KanjiListEvent {
  final String name;
  final String? description;
  final List<int>? kanjiIds;

  CreateListEvent({required this.name, this.description, this.kanjiIds});

  @override
  List<Object?> get props => [name, description, kanjiIds];
}

class UpdateListEvent extends KanjiListEvent {
  final int id;
  final String? name;
  final String? description;
  final bool? isPublic;

  UpdateListEvent({
    required this.id,
    this.name,
    this.description,
    this.isPublic,
  });

  @override
  List<Object?> get props => [id, name, description, isPublic];
}

class DeleteListEvent extends KanjiListEvent {
  final int id;

  DeleteListEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// Kanji events
class AddKanjiToListEvent extends KanjiListEvent {
  final int listId;
  final int kanjiId;

  AddKanjiToListEvent({required this.listId, required this.kanjiId});

  @override
  List<Object?> get props => [listId, kanjiId];
}

class RemoveKanjiFromListEvent extends KanjiListEvent {
  final int listId;
  final int kanjiId;

  RemoveKanjiFromListEvent({required this.listId, required this.kanjiId});

  @override
  List<Object?> get props => [listId, kanjiId];
}

// Publish events
class RequestPublishListEvent extends KanjiListEvent {
  final int listId;

  RequestPublishListEvent(this.listId);

  @override
  List<Object?> get props => [listId];
}

class LoadPublishRequestsEvent extends KanjiListEvent {
  final String? status;

  LoadPublishRequestsEvent({this.status});

  @override
  List<Object?> get props => [status];
}

class ApprovePublishRequestEvent extends KanjiListEvent {
  final int requestId;

  ApprovePublishRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class RejectPublishRequestEvent extends KanjiListEvent {
  final int requestId;
  final String? reason;

  RejectPublishRequestEvent(this.requestId, {this.reason});

  @override
  List<Object?> get props => [requestId, reason];
}

// Utility event
class RefreshListsEvent extends KanjiListEvent {}
