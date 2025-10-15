import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji.dart';
import '../repositories/kanji_repository.dart';

class GetKanjiById {
  final KanjiRepository repository;

  GetKanjiById(this.repository);

  Future<Either<Failure, Kanji>> call(int id) async {
    return await repository.getKanjiById(id);
  }
}
