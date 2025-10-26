import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_list.dart';
import '../repositories/kanji_list_repository.dart';

/// UseCase for removing a kanji from a list
class RemoveKanjiFromList {
  final KanjiListRepository repository;

  RemoveKanjiFromList(this.repository);

  Future<Either<Failure, KanjiList>> call({
    required int listId,
    required int kanjiId,
  }) async {
    return await repository.removeKanjiFromList(
      listId: listId,
      kanjiId: kanjiId,
    );
  }
}
