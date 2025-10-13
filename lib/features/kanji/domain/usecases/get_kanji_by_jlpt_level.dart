import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kanji.dart';
import '../repositories/kanji_repository.dart';

class GetKanjiByJlptLevel implements UseCase<List<Kanji>, JlptLevelParams> {
  final KanjiRepository repository;

  GetKanjiByJlptLevel(this.repository);

  @override
  Future<Either<Failure, List<Kanji>>> call(JlptLevelParams params) async {
    return await repository.getKanjiByJlptLevel(params.level);
  }
}

class JlptLevelParams {
  final int level;

  JlptLevelParams({required this.level});
}
