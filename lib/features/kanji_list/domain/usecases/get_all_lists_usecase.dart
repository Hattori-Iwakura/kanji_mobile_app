import '../entities/kanji_list_entity.dart';
import '../repositories/kanji_list_repository.dart';

class GetAllListsUseCase {
  final KanjiListRepository repository;

  GetAllListsUseCase(this.repository);

  Future<List<KanjiListEntity>> call({
    String? search,
    String? type,
    int? limit,
    int? offset,
  }) {
    return repository.getAllLists(
      search: search,
      type: type,
      limit: limit,
      offset: offset,
    );
  }
}
