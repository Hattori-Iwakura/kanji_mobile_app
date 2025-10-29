import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_detail.dart';
import '../repositories/kanji_repository.dart';

class GetKanjiDetail {
  final KanjiRepository repository;

  GetKanjiDetail(this.repository);

  Future<Either<Failure, KanjiDetail>> call(String character) async {
    return await repository.getKanjiDetail(character);
  }
}
