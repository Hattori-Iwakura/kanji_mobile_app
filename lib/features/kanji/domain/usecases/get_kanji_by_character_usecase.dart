import '../entities/kanji_entity.dart';
import '../repositories/kanji_repository.dart';

class GetKanjiByCharacterUseCase {
  final KanjiRepository repository;

  GetKanjiByCharacterUseCase(this.repository);

  Future<KanjiEntity> call(String character) async {
    return await repository.getKanjiByCharacter(character);
  }
}
