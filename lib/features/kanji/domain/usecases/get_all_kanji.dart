import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji.dart';
import '../repositories/kanji_repository.dart';

class GetAllKanji {
  final KanjiRepository repository;

  GetAllKanji(this.repository);

  Future<Either<Failure, List<Kanji>>> call() async {
    return await repository.getAllKanji();
  }
}
