import 'package:equatable/equatable.dart';

abstract class KanjiTableEvent extends Equatable {
  const KanjiTableEvent();

  @override
  List<Object?> get props => [];
}

// Load tables by JLPT level
class LoadTablesByJlptEvent extends KanjiTableEvent {
  final String jlptLevel;

  const LoadTablesByJlptEvent(this.jlptLevel);

  @override
  List<Object?> get props => [jlptLevel];
}

// Load all tables
class LoadAllTablesEvent extends KanjiTableEvent {
  final String? search;
  final String? type;
  final int? limit;
  final int? offset;

  const LoadAllTablesEvent({this.search, this.type, this.limit, this.offset});

  @override
  List<Object?> get props => [search, type, limit, offset];
}

// Load table detail
class LoadTableDetailEvent extends KanjiTableEvent {
  final int tableId;

  const LoadTableDetailEvent(this.tableId);

  @override
  List<Object?> get props => [tableId];
}

// Create table
class CreateTableEvent extends KanjiTableEvent {
  final String name;
  final String? description;
  final int? categoryId;
  final List<int>? kanjiIds;

  const CreateTableEvent({
    required this.name,
    this.description,
    this.categoryId,
    this.kanjiIds,
  });

  @override
  List<Object?> get props => [name, description, categoryId, kanjiIds];
}

// Update table
class UpdateTableEvent extends KanjiTableEvent {
  final int id;
  final String? name;
  final String? description;
  final bool? isPublic;
  final int? categoryId;

  const UpdateTableEvent({
    required this.id,
    this.name,
    this.description,
    this.isPublic,
    this.categoryId,
  });

  @override
  List<Object?> get props => [id, name, description, isPublic, categoryId];
}

// Delete table
class DeleteTableEvent extends KanjiTableEvent {
  final int id;

  const DeleteTableEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// Add kanji to table
class AddKanjiToTableEvent extends KanjiTableEvent {
  final int tableId;
  final int kanjiId;

  const AddKanjiToTableEvent({required this.tableId, required this.kanjiId});

  @override
  List<Object?> get props => [tableId, kanjiId];
}

// Remove kanji from table
class RemoveKanjiFromTableEvent extends KanjiTableEvent {
  final int tableId;
  final int kanjiId;

  const RemoveKanjiFromTableEvent({
    required this.tableId,
    required this.kanjiId,
  });

  @override
  List<Object?> get props => [tableId, kanjiId];
}

// Request publish
class RequestPublishEvent extends KanjiTableEvent {
  final int tableId;

  const RequestPublishEvent(this.tableId);

  @override
  List<Object?> get props => [tableId];
}
