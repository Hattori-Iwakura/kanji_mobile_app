import 'package:equatable/equatable.dart';
import '../../domain/entities/kanji.dart';
import '../../domain/entities/kanji_list.dart';

abstract class KanjiListState extends Equatable {
  const KanjiListState();

  @override
  List<Object?> get props => [];
}

class KanjiListInitial extends KanjiListState {}

class KanjiListLoading extends KanjiListState {}

class KanjiListsLoaded extends KanjiListState {
  final List<KanjiList> lists;

  const KanjiListsLoaded({required this.lists});

  @override
  List<Object> get props => [lists];
}

class KanjiListDetailLoaded extends KanjiListState {
  final KanjiList list;
  final List<Kanji> kanjiItems;

  const KanjiListDetailLoaded({required this.list, required this.kanjiItems});

  @override
  List<Object> get props => [list, kanjiItems];
}

class KanjiListCreated extends KanjiListState {
  final KanjiList list;

  const KanjiListCreated({required this.list});

  @override
  List<Object> get props => [list];
}

class KanjiListError extends KanjiListState {
  final String message;

  const KanjiListError({required this.message});

  @override
  List<Object> get props => [message];
}
