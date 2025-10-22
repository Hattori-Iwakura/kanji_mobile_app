import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji.dart';
import '../repositories/kanji_repository.dart';

/// Use case for getting all kanji
class GetAllKanji {
  final KanjiRepository repository;

  GetAllKanji(this.repository);

  Future<Either<Failure, List<Kanji>>> call({
    int? jlpt,
    int? grade,
    String? search,
    int? limit,
    int? offset,
  }) async {
    return await repository.getAllKanji(
      jlpt: jlpt,
      grade: grade,
      search: search,
      limit: limit,
      offset: offset,
    );
  }
}
