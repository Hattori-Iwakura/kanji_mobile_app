import 'package:equatable/equatable.dart';

/// Base event for KanjiList BLoC
abstract class KanjiListEvent extends Equatable {
  const KanjiListEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all kanji lists
class LoadKanjiListsEvent extends KanjiListEvent {
  final String? search;
  final int? limit;
  final int? offset;

  const LoadKanjiListsEvent({this.search, this.limit, this.offset});

  @override
  List<Object?> get props => [search, limit, offset];
}

/// Event to load single kanji list
class LoadKanjiListByIdEvent extends KanjiListEvent {
  final int id;

  const LoadKanjiListByIdEvent(this.id);

  @override
  List<Object> get props => [id];
}

/// Event to create kanji list
class CreateKanjiListEvent extends KanjiListEvent {
  final String name;
  final String? description;
  final List<int>? kanjiIds;

  const CreateKanjiListEvent({
    required this.name,
    this.description,
    this.kanjiIds,
  });

  @override
  List<Object?> get props => [name, description, kanjiIds];
}

/// Event to update kanji list
class UpdateKanjiListEvent extends KanjiListEvent {
  final int id;
  final String? name;
  final String? description;
  final bool? isPublic;

  const UpdateKanjiListEvent({
    required this.id,
    this.name,
    this.description,
    this.isPublic,
  });

  @override
  List<Object?> get props => [id, name, description, isPublic];
}

/// Event to delete kanji list
class DeleteKanjiListEvent extends KanjiListEvent {
  final int id;

  const DeleteKanjiListEvent(this.id);

  @override
  List<Object> get props => [id];
}

/// Event to add kanji to list
class AddKanjiToListEvent extends KanjiListEvent {
  final int listId;
  final int kanjiId;

  const AddKanjiToListEvent({required this.listId, required this.kanjiId});

  @override
  List<Object> get props => [listId, kanjiId];
}

/// Event to remove kanji from list
class RemoveKanjiFromListEvent extends KanjiListEvent {
  final int listId;
  final int kanjiId;

  const RemoveKanjiFromListEvent({required this.listId, required this.kanjiId});

  @override
  List<Object> get props => [listId, kanjiId];
}

/// Event to filter lists by JLPT level
class FilterByJlptEvent extends KanjiListEvent {
  final String jlptLevel; // N5, N4, N3, N2, N1

  const FilterByJlptEvent(this.jlptLevel);

  @override
  List<Object> get props => [jlptLevel];
}
