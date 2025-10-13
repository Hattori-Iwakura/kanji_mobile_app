import 'package:equatable/equatable.dart';
import '../../domain/entities/kanji_list.dart';

abstract class KanjiListEvent extends Equatable {
  const KanjiListEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllListsEvent extends KanjiListEvent {}

class CreateListEvent extends KanjiListEvent {
  final String name;
  final String? description;
  final ListFilterType filterType;
  final int? filterValue;
  final int? frequencyMin;
  final int? frequencyMax;

  const CreateListEvent({
    required this.name,
    this.description,
    required this.filterType,
    this.filterValue,
    this.frequencyMin,
    this.frequencyMax,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    filterType,
    filterValue,
    frequencyMin,
    frequencyMax,
  ];
}

class DeleteListEvent extends KanjiListEvent {
  final int listId;

  const DeleteListEvent(this.listId);

  @override
  List<Object> get props => [listId];
}

class LoadListDetailEvent extends KanjiListEvent {
  final int listId;

  const LoadListDetailEvent(this.listId);

  @override
  List<Object> get props => [listId];
}
