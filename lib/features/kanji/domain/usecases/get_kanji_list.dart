import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji.dart';
import '../repositories/kanji_repository.dart';

class GetKanjiList {
  final KanjiRepository repository;

  GetKanjiList(this.repository);

  Future<Either<Failure, List<Kanji>>> call({
    int? jlpt,
    int? grade,
    String? search,
    int? limit,
    int? offset,
  }) async {
    return await repository.getKanjiList(
      jlpt: jlpt,
      grade: grade,
      search: search,
      limit: limit,
      offset: offset,
    );
  }
}
