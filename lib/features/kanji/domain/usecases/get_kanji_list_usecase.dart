import '../entities/kanji_entity.dart';
import '../repositories/kanji_repository.dart';

class GetKanjiListUseCase {
  final KanjiRepository repository;

  GetKanjiListUseCase(this.repository);

  Future<List<KanjiEntity>> call({
    int page = 1,
    int limit = 50,
    String? jlptLevel,
    int? grade,
    String? search,
  }) async {
    return await repository.getKanjiList(
      page: page,
      limit: limit,
      jlptLevel: jlptLevel,
      grade: grade,
      search: search,
    );
  }
}
