import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_list.dart';
import '../repositories/kanji_list_repository.dart';

/// UseCase for getting kanji list by ID
class GetKanjiListById {
  final KanjiListRepository repository;

  GetKanjiListById(this.repository);

  Future<Either<Failure, KanjiList>> call(int id) async {
    return await repository.getListById(id);
  }
}
