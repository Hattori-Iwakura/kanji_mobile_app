import 'package:equatable/equatable.dart';

abstract class KanjiEvent extends Equatable {
  const KanjiEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllKanjiEvent extends KanjiEvent {
  const LoadAllKanjiEvent();
}

class LoadKanjiByIdEvent extends KanjiEvent {
  final int id;

  const LoadKanjiByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadKanjiByCharacterEvent extends KanjiEvent {
  final String character;

  const LoadKanjiByCharacterEvent(this.character);

  @override
  List<Object?> get props => [character];
}

class FilterKanjiByJlptEvent extends KanjiEvent {
  final int level;

  const FilterKanjiByJlptEvent(this.level);

  @override
  List<Object?> get props => [level];
}

class FilterKanjiByGradeEvent extends KanjiEvent {
  final int grade;

  const FilterKanjiByGradeEvent(this.grade);

  @override
  List<Object?> get props => [grade];
}

class SearchKanjiEvent extends KanjiEvent {
  final String query;

  const SearchKanjiEvent(this.query);

  @override
  List<Object?> get props => [query];
}
