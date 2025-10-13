import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kanji_list.dart';
import '../repositories/kanji_list_repository.dart';

class GetAllKanjiLists implements UseCase<List<KanjiList>, NoParams> {
  final KanjiListRepository repository;

  GetAllKanjiLists(this.repository);

  @override
  Future<Either<Failure, List<KanjiList>>> call(NoParams params) async {
    return await repository.getAllLists();
  }
}
