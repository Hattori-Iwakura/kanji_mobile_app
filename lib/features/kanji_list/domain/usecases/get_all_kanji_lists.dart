import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_list.dart';
import '../repositories/kanji_list_repository.dart';

/// UseCase for getting all kanji lists
class GetAllKanjiLists {
  final KanjiListRepository repository;

  GetAllKanjiLists(this.repository);

  Future<Either<Failure, List<KanjiList>>> call({
    String? search,
    int? limit,
    int? offset,
  }) async {
    return await repository.getAllLists(
      search: search,
      limit: limit,
      offset: offset,
    );
  }
}
