import 'package:equatable/equatable.dart';
import '../../domain/entities/kanji_list.dart';

/// Base state for KanjiList BLoC
abstract class KanjiListState extends Equatable {
  const KanjiListState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class KanjiListInitial extends KanjiListState {}

/// Loading state
class KanjiListLoading extends KanjiListState {}

/// State when list of kanji lists is loaded
class KanjiListsLoaded extends KanjiListState {
  final List<KanjiList> lists;

  const KanjiListsLoaded(this.lists);

  @override
  List<Object> get props => [lists];
}

/// State when single kanji list is loaded
class KanjiListLoaded extends KanjiListState {
  final KanjiList list;

  const KanjiListLoaded(this.list);

  @override
  List<Object> get props => [list];
}

/// State when kanji list is created successfully
class KanjiListCreated extends KanjiListState {
  final KanjiList list;

  const KanjiListCreated(this.list);

  @override
  List<Object> get props => [list];
}

/// State when kanji list is updated successfully
class KanjiListUpdated extends KanjiListState {
  final KanjiList list;

  const KanjiListUpdated(this.list);

  @override
  List<Object> get props => [list];
}

/// State when kanji list is deleted successfully
class KanjiListDeleted extends KanjiListState {
  final int listId;

  const KanjiListDeleted(this.listId);

  @override
  List<Object> get props => [listId];
}

/// State when kanji is added successfully
class KanjiAddedToList extends KanjiListState {
  final KanjiList list;

  const KanjiAddedToList(this.list);

  @override
  List<Object> get props => [list];
}

/// State when kanji is removed successfully
class KanjiRemovedFromList extends KanjiListState {
  final KanjiList list;

  const KanjiRemovedFromList(this.list);

  @override
  List<Object> get props => [list];
}

/// Error state
class KanjiListError extends KanjiListState {
  final String message;

  const KanjiListError(this.message);

  @override
  List<Object> get props => [message];
}
