import '../entities/kanji_list_entity.dart';
import '../repositories/kanji_list_repository.dart';

class GetListByIdUseCase {
  final KanjiListRepository repository;

  GetListByIdUseCase(this.repository);

  Future<KanjiListEntity> call(int id) {
    return repository.getListById(id);
  }
}
