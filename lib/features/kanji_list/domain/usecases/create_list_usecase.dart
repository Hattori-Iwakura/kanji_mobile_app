import '../entities/kanji_list_entity.dart';
import '../repositories/kanji_list_repository.dart';

class CreateListUseCase {
  final KanjiListRepository repository;

  CreateListUseCase(this.repository);

  Future<KanjiListEntity> call({
    required String name,
    String? description,
    List<int>? kanjiIds,
  }) {
    return repository.createList(
      name: name,
      description: description,
      kanjiIds: kanjiIds,
    );
  }
}
