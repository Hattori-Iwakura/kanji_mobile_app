import 'package:equatable/equatable.dart';
import 'kanji.dart';

class KanjiSearchResult extends Equatable {
  final List<Kanji> data;
  final PaginationMeta meta;

  const KanjiSearchResult({required this.data, required this.meta});

  // Check if there are more pages
  bool get hasNextPage => meta.page < meta.totalPages;

  // Check if this is the first page
  bool get isFirstPage => meta.page == 1;

  // Check if this is the last page
  bool get isLastPage => meta.page >= meta.totalPages;

  @override
  List<Object?> get props => [data, meta];
}

class PaginationMeta extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [page, limit, total, totalPages];
}
