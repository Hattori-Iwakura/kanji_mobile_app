import 'package:equatable/equatable.dart';
import '../../domain/entities/kanji.dart';

abstract class KanjiState extends Equatable {
  const KanjiState();

  @override
  List<Object?> get props => [];
}

class KanjiInitial extends KanjiState {
  const KanjiInitial();
}

class KanjiLoading extends KanjiState {
  const KanjiLoading();
}

class KanjiListLoaded extends KanjiState {
  final List<Kanji> kanjiList;
  final List<Kanji> filteredList;
  final String? filterType; // 'jlpt', 'grade', 'search', null

  const KanjiListLoaded({
    required this.kanjiList,
    required this.filteredList,
    this.filterType,
  });

  @override
  List<Object?> get props => [kanjiList, filteredList, filterType];

  KanjiListLoaded copyWith({
    List<Kanji>? kanjiList,
    List<Kanji>? filteredList,
    String? filterType,
  }) {
    return KanjiListLoaded(
      kanjiList: kanjiList ?? this.kanjiList,
      filteredList: filteredList ?? this.filteredList,
      filterType: filterType ?? this.filterType,
    );
  }
}

class KanjiDetailLoaded extends KanjiState {
  final Kanji kanji;

  const KanjiDetailLoaded(this.kanji);

  @override
  List<Object?> get props => [kanji];
}

class KanjiError extends KanjiState {
  final String message;

  const KanjiError(this.message);

  @override
  List<Object?> get props => [message];
}
