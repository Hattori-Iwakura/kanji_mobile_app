import '../entities/kanji_entity.dart';
import '../repositories/kanji_repository.dart';

class UpdateKanjiUseCase {
  final KanjiRepository repository;

  UpdateKanjiUseCase(this.repository);

  Future<KanjiEntity> call(int id, Map<String, dynamic> kanjiData) async {
    return await repository.updateKanji(id, kanjiData);
  }
}
