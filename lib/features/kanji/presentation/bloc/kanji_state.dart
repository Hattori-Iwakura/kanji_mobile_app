import 'package:equatable/equatable.dart';
import '../../domain/entities/kanji.dart';

/// Base state for Kanji BLoC
abstract class KanjiState extends Equatable {
  const KanjiState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class KanjiInitial extends KanjiState {}

/// Loading state
class KanjiLoading extends KanjiState {}

/// State when kanji list is loaded successfully
class KanjiListLoaded extends KanjiState {
  final List<Kanji> kanjiList;

  const KanjiListLoaded(this.kanjiList);

  @override
  List<Object> get props => [kanjiList];
}

/// State when a single kanji is loaded successfully
class KanjiDetailLoaded extends KanjiState {
  final Kanji kanji;

  const KanjiDetailLoaded(this.kanji);

  @override
  List<Object> get props => [kanji];
}

/// State when search results are loaded
class KanjiSearchLoaded extends KanjiState {
  final List<Kanji> results;
  final int page;
  final bool hasMore;

  const KanjiSearchLoaded({
    required this.results,
    required this.page,
    this.hasMore = true,
  });

  @override
  List<Object> get props => [results, page, hasMore];

  KanjiSearchLoaded copyWith({List<Kanji>? results, int? page, bool? hasMore}) {
    return KanjiSearchLoaded(
      results: results ?? this.results,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Error state
class KanjiError extends KanjiState {
  final String message;

  const KanjiError(this.message);

  @override
  List<Object> get props => [message];
}
