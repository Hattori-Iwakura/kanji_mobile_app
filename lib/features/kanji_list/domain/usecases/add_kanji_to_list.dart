import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_list.dart';
import '../repositories/kanji_list_repository.dart';

/// UseCase for adding a kanji to a list
class AddKanjiToList {
  final KanjiListRepository repository;

  AddKanjiToList(this.repository);

  Future<Either<Failure, KanjiList>> call({
    required int listId,
    required int kanjiId,
  }) async {
    return await repository.addKanjiToList(listId: listId, kanjiId: kanjiId);
  }
}
