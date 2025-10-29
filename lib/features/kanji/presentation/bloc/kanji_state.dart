import 'package:equatable/equatable.dart';
import '../../domain/entities/kanji.dart';
import '../../domain/entities/kanji_detail.dart';

abstract class KanjiState extends Equatable {
  const KanjiState();

  @override
  List<Object?> get props => [];
}

class KanjiInitial extends KanjiState {}

class KanjiLoading extends KanjiState {}

class KanjiListLoaded extends KanjiState {
  final List<Kanji> kanjiList;
  final bool hasMore;
  final bool isLoadingMore;

  const KanjiListLoaded(
    this.kanjiList, {
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  KanjiListLoaded copyWith({
    List<Kanji>? kanjiList,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return KanjiListLoaded(
      kanjiList ?? this.kanjiList,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [kanjiList, hasMore, isLoadingMore];
}

class KanjiSearchResult extends KanjiState {
  final List<Kanji> kanjiList;
  final int total;
  final int currentPage;
  final int totalPages;

  const KanjiSearchResult({
    required this.kanjiList,
    required this.total,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [kanjiList, total, currentPage, totalPages];
}

class KanjiDetailLoaded extends KanjiState {
  final KanjiDetail kanjiDetail;

  const KanjiDetailLoaded(this.kanjiDetail);

  @override
  List<Object?> get props => [kanjiDetail];
}

class KanjiCanvasSearchLoaded extends KanjiState {
  final List<Kanji> results;

  const KanjiCanvasSearchLoaded(this.results);

  @override
  List<Object?> get props => [results];
}

class KanjiUpdateSuccess extends KanjiState {}

class KanjiError extends KanjiState {
  final String message;

  const KanjiError(this.message);

  @override
  List<Object?> get props => [message];
}
