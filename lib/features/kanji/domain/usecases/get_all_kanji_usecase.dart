import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji.dart';
import '../repositories/kanji_repository.dart';

class GetAllKanjiUseCase {
  final KanjiRepository repository;

  GetAllKanjiUseCase(this.repository);

  Future<Either<Failure, List<Kanji>>> call() async {
    return await repository.getAllKanji();
  }
}
