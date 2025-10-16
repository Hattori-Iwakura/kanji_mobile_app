import 'package:equatable/equatable.dart';
import '../../../domain/entities/kanji_list.dart';

abstract class KanjiListsState extends Equatable {
  const KanjiListsState();

  @override
  List<Object?> get props => [];
}

class ListsInitial extends KanjiListsState {
  const ListsInitial();
}

class ListsLoading extends KanjiListsState {
  const ListsLoading();
}

class ListsLoaded extends KanjiListsState {
  final List<KanjiList> lists;

  const ListsLoaded(this.lists);

  @override
  List<Object?> get props => [lists];

  ListsLoaded copyWith({List<KanjiList>? lists}) {
    return ListsLoaded(lists ?? this.lists);
  }
}

class ListDetailLoaded extends KanjiListsState {
  final KanjiList list;

  const ListDetailLoaded(this.list);

  @override
  List<Object?> get props => [list];

  ListDetailLoaded copyWith({KanjiList? list}) {
    return ListDetailLoaded(list ?? this.list);
  }
}

class ListOperationSuccess extends KanjiListsState {
  final String message;

  const ListOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ListsError extends KanjiListsState {
  final String message;

  const ListsError(this.message);

  @override
  List<Object?> get props => [message];
}
