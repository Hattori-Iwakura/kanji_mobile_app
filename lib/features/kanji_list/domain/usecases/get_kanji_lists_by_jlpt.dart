import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_list.dart';
import '../repositories/kanji_list_repository.dart';

/// UseCase for getting kanji lists filtered by JLPT level
class GetKanjiListsByJlpt {
  final KanjiListRepository repository;

  GetKanjiListsByJlpt(this.repository);

  /// Get lists by JLPT level (N5, N4, N3, N2, N1)
  Future<Either<Failure, List<KanjiList>>> call({
    required String jlptLevel,
  }) async {
    return await repository.getListsByJlpt(jlptLevel: jlptLevel);
  }
}
