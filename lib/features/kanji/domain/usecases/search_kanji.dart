import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/kanji_repository.dart';

class SearchKanji {
  final KanjiRepository repository;

  SearchKanji(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    String? query,
    List<int>? jlptLevels,
    List<int>? grades,
    int? minStrokes,
    int? maxStrokes,
    int page = 1,
    int limit = 20,
    String? sortBy,
  }) async {
    return await repository.searchKanji(
      query: query,
      jlptLevels: jlptLevels,
      grades: grades,
      minStrokes: minStrokes,
      maxStrokes: maxStrokes,
      page: page,
      limit: limit,
      sortBy: sortBy,
    );
  }
}
