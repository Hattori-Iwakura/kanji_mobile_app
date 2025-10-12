import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kanji.dart';
import '../repositories/kanji_repository.dart';

class GetKanjiByGrade implements UseCase<List<Kanji>, GradeParams> {
  final KanjiRepository repository;

  GetKanjiByGrade(this.repository);

  @override
  Future<Either<Failure, List<Kanji>>> call(GradeParams params) async {
    return await repository.getKanjiByGrade(params.grade);
  }
}

class GradeParams {
  final int grade;

  GradeParams({required this.grade});
}
