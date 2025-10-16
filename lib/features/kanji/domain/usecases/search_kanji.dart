import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_search_result.dart';
import '../repositories/kanji_repository.dart';

class SearchKanjiUseCase {
  final KanjiRepository repository;

  SearchKanjiUseCase(this.repository);

  Future<Either<Failure, KanjiSearchResult>> call(
    SearchKanjiParams params,
  ) async {
    return await repository.searchKanji(
      query: params.query,
      jlptLevels: params.jlptLevels,
      grades: params.grades,
      minStrokes: params.minStrokes,
      maxStrokes: params.maxStrokes,
      radical: params.radical,
      page: params.page,
      limit: params.limit,
      sortBy: params.sortBy,
    );
  }
}

class SearchKanjiParams extends Equatable {
  final String? query;
  final List<int>? jlptLevels;
  final List<int>? grades;
  final int? minStrokes;
  final int? maxStrokes;
  final String? radical;
  final int? page;
  final int? limit;
  final String? sortBy;

  const SearchKanjiParams({
    this.query,
    this.jlptLevels,
    this.grades,
    this.minStrokes,
    this.maxStrokes,
    this.radical,
    this.page = 1,
    this.limit = 20,
    this.sortBy,
  });

  SearchKanjiParams copyWith({
    String? query,
    List<int>? jlptLevels,
    List<int>? grades,
    int? minStrokes,
    int? maxStrokes,
    String? radical,
    int? page,
    int? limit,
    String? sortBy,
  }) {
    return SearchKanjiParams(
      query: query ?? this.query,
      jlptLevels: jlptLevels ?? this.jlptLevels,
      grades: grades ?? this.grades,
      minStrokes: minStrokes ?? this.minStrokes,
      maxStrokes: maxStrokes ?? this.maxStrokes,
      radical: radical ?? this.radical,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [
    query,
    jlptLevels,
    grades,
    minStrokes,
    maxStrokes,
    radical,
    page,
    limit,
    sortBy,
  ];
}
