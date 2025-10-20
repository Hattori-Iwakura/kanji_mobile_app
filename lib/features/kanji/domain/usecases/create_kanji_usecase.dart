import '../entities/kanji_entity.dart';
import '../repositories/kanji_repository.dart';

class CreateKanjiUseCase {
  final KanjiRepository repository;

  CreateKanjiUseCase(this.repository);

  Future<KanjiEntity> call(Map<String, dynamic> kanjiData) async {
    return await repository.createKanji(kanjiData);
  }
}
