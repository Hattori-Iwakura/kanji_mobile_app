import 'package:equatable/equatable.dart';
import '../../domain/entities/kanji_entity.dart';

abstract class KanjiState extends Equatable {
  @override
  List<Object?> get props => [];
}

class KanjiInitial extends KanjiState {}

class KanjiLoading extends KanjiState {}

class KanjiListLoaded extends KanjiState {
  final List<KanjiEntity> kanjiList;
  final int currentPage;
  final bool hasMore;
  final String? appliedJlptFilter;
  final int? appliedGradeFilter;
  final String? appliedSearch;

  KanjiListLoaded({
    required this.kanjiList,
    required this.currentPage,
    required this.hasMore,
    this.appliedJlptFilter,
    this.appliedGradeFilter,
    this.appliedSearch,
  });

  @override
  List<Object?> get props => [
    kanjiList,
    currentPage,
    hasMore,
    appliedJlptFilter,
    appliedGradeFilter,
    appliedSearch,
  ];
}

class KanjiDetailLoaded extends KanjiState {
  final KanjiEntity kanji;

  KanjiDetailLoaded(this.kanji);

  @override
  List<Object?> get props => [kanji];
}

class KanjiCreated extends KanjiState {
  final KanjiEntity kanji;

  KanjiCreated(this.kanji);

  @override
  List<Object?> get props => [kanji];
}

class KanjiUpdated extends KanjiState {
  final KanjiEntity kanji;

  KanjiUpdated(this.kanji);

  @override
  List<Object?> get props => [kanji];
}

class KanjiDeleted extends KanjiState {}

class KanjiError extends KanjiState {
  final String message;

  KanjiError(this.message);

  @override
  List<Object?> get props => [message];
}
