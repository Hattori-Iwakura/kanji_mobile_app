import 'package:equatable/equatable.dart';
import '../../domain/entities/kanji_list_entity.dart';

abstract class KanjiListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class KanjiListInitial extends KanjiListState {}

class KanjiListLoading extends KanjiListState {}

// List states
class ListsLoaded extends KanjiListState {
  final List<KanjiListEntity> lists;
  final String? appliedSearch;
  final String? appliedType;
  final int? appliedLimit;
  final int? appliedOffset;

  ListsLoaded({
    required this.lists,
    this.appliedSearch,
    this.appliedType,
    this.appliedLimit,
    this.appliedOffset,
  });

  @override
  List<Object?> get props => [
    lists,
    appliedSearch,
    appliedType,
    appliedLimit,
    appliedOffset,
  ];
}

class ListDetailLoaded extends KanjiListState {
  final KanjiListEntity list;

  ListDetailLoaded(this.list);

  @override
  List<Object?> get props => [list];
}

class ListCreated extends KanjiListState {
  final KanjiListEntity list;

  ListCreated(this.list);

  @override
  List<Object?> get props => [list];
}

class ListUpdated extends KanjiListState {
  final KanjiListEntity list;

  ListUpdated(this.list);

  @override
  List<Object?> get props => [list];
}

class ListDeleted extends KanjiListState {}

// Kanji states
class KanjiAddedToList extends KanjiListState {}

class KanjiRemovedFromList extends KanjiListState {}

// Publish states
class PublishRequested extends KanjiListState {}

class PublishRequestsLoaded extends KanjiListState {
  final List<dynamic> requests;

  PublishRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class PublishRequestApproved extends KanjiListState {}

class PublishRequestRejected extends KanjiListState {}

// Error state
class KanjiListError extends KanjiListState {
  final String message;

  KanjiListError(this.message);

  @override
  List<Object?> get props => [message];
}
