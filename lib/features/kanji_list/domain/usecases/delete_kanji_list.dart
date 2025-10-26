import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/kanji_list_repository.dart';

/// UseCase for deleting a kanji list
class DeleteKanjiList {
  final KanjiListRepository repository;

  DeleteKanjiList(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteList(id);
  }
}
