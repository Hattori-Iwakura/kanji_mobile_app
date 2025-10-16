import 'package:equatable/equatable.dart';

abstract class KanjiListsEvent extends Equatable {
  const KanjiListsEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserLists extends KanjiListsEvent {
  const LoadUserLists();
}

class CreateList extends KanjiListsEvent {
  final String name;
  final String? description;

  const CreateList({required this.name, this.description});

  @override
  List<Object?> get props => [name, description];
}

class LoadListDetail extends KanjiListsEvent {
  final String listId;

  const LoadListDetail(this.listId);

  @override
  List<Object?> get props => [listId];
}

class AddKanjiToListEvent extends KanjiListsEvent {
  final String listId;
  final List<String> characters;

  const AddKanjiToListEvent({required this.listId, required this.characters});

  @override
  List<Object?> get props => [listId, characters];
}

class RemoveKanjiFromListEvent extends KanjiListsEvent {
  final String listId;
  final String kanjiId;

  const RemoveKanjiFromListEvent({required this.listId, required this.kanjiId});

  @override
  List<Object?> get props => [listId, kanjiId];
}

class DeleteListEvent extends KanjiListsEvent {
  final String listId;

  const DeleteListEvent(this.listId);

  @override
  List<Object?> get props => [listId];
}

class ReorderListEvent extends KanjiListsEvent {
  final String listId;
  final List<String> kanjiIds;

  const ReorderListEvent({required this.listId, required this.kanjiIds});

  @override
  List<Object?> get props => [listId, kanjiIds];
}
