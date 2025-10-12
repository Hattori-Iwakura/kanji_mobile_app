import 'package:equatable/equatable.dart';
import '../../domain/entities/kanji.dart';

abstract class KanjiState extends Equatable {
  const KanjiState();

  @override
  List<Object> get props => [];
}

class KanjiInitial extends KanjiState {}

class KanjiLoading extends KanjiState {}

class KanjiLoaded extends KanjiState {
  final List<Kanji> kanjiList;

  const KanjiLoaded({required this.kanjiList});

  @override
  List<Object> get props => [kanjiList];
}

class KanjiError extends KanjiState {
  final String message;

  const KanjiError({required this.message});

  @override
  List<Object> get props => [message];
}
