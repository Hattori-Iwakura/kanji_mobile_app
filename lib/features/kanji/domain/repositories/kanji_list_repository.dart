import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_list.dart';

abstract class KanjiListRepository {
  Future<Either<Failure, List<KanjiList>>> getAllLists();
  Future<Either<Failure, KanjiList>> getListById(int id);
  Future<Either<Failure, KanjiList>> createList(KanjiList kanjiList);
  Future<Either<Failure, void>> updateList(KanjiList kanjiList);
  Future<Either<Failure, void>> deleteList(int id);
  Future<Either<Failure, List<int>>> getKanjiIdsInList(int listId);
  Future<Either<Failure, void>> addKanjiToList(int listId, List<int> kanjiIds);
  Future<Either<Failure, void>> removeKanjiFromList(int listId, int kanjiId);
}
