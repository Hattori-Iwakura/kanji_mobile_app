import '../entities/kanji_list_entity.dart';
import '../repositories/kanji_list_repository.dart';

class UpdateListUseCase {
  final KanjiListRepository repository;

  UpdateListUseCase(this.repository);

  Future<KanjiListEntity> call({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  }) {
    return repository.updateList(
      id: id,
      name: name,
      description: description,
      isPublic: isPublic,
    );
  }
}
