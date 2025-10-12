import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kanji.dart';
import '../repositories/kanji_repository.dart';

class GetAllKanji implements UseCase<List<Kanji>, NoParams> {
  final KanjiRepository repository;

  GetAllKanji(this.repository);

  @override
  Future<Either<Failure, List<Kanji>>> call(NoParams params) async {
    return await repository.getAllKanji();
  }
}
