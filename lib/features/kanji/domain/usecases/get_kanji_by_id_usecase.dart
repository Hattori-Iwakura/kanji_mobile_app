import '../entities/kanji_entity.dart';
import '../repositories/kanji_repository.dart';

class GetKanjiByIdUseCase {
  final KanjiRepository repository;

  GetKanjiByIdUseCase(this.repository);

  Future<KanjiEntity> call(int id) async {
    return await repository.getKanjiById(id);
  }
}
