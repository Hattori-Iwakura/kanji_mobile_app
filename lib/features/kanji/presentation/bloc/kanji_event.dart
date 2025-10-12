import 'package:equatable/equatable.dart';

abstract class KanjiEvent extends Equatable {
  const KanjiEvent();

  @override
  List<Object> get props => [];
}

class LoadAllKanjiEvent extends KanjiEvent {}

class LoadKanjiByGradeEvent extends KanjiEvent {
  final int grade;

  const LoadKanjiByGradeEvent(this.grade);

  @override
  List<Object> get props => [grade];
}

class SearchKanjiEvent extends KanjiEvent {
  final String query;

  const SearchKanjiEvent(this.query);

  @override
  List<Object> get props => [query];
}
