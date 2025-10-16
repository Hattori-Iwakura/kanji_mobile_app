import 'package:equatable/equatable.dart';

abstract class KanjiDetailEvent extends Equatable {
  const KanjiDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadKanjiDetail extends KanjiDetailEvent {
  final String character;

  const LoadKanjiDetail(this.character);

  @override
  List<Object?> get props => [character];
}

class LoadMoreExamples extends KanjiDetailEvent {
  final String character;
  final int currentCount;

  const LoadMoreExamples({required this.character, required this.currentCount});

  @override
  List<Object?> get props => [character, currentCount];
}

class RefreshKanjiDetail extends KanjiDetailEvent {
  final String character;

  const RefreshKanjiDetail(this.character);

  @override
  List<Object?> get props => [character];
}
