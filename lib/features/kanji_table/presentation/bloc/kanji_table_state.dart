import 'package:equatable/equatable.dart';
import '../../domain/entities/kanji_table.dart';

abstract class KanjiTableState extends Equatable {
  const KanjiTableState();

  @override
  List<Object?> get props => [];
}

class KanjiTableInitial extends KanjiTableState {}

class KanjiTableLoading extends KanjiTableState {}

class KanjiTableListLoaded extends KanjiTableState {
  final List<KanjiTable> tables;

  const KanjiTableListLoaded(this.tables);

  @override
  List<Object?> get props => [tables];
}

class KanjiTableDetailLoaded extends KanjiTableState {
  final KanjiTable table;

  const KanjiTableDetailLoaded(this.table);

  @override
  List<Object?> get props => [table];
}

class KanjiTableOperationSuccess extends KanjiTableState {
  final String message;

  const KanjiTableOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class KanjiTableError extends KanjiTableState {
  final String message;

  const KanjiTableError(this.message);

  @override
  List<Object?> get props => [message];
}
