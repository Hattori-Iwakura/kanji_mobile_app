import '../entities/kanji_entity.dart';

abstract class KanjiRepository {
  Future<List<KanjiEntity>> getKanjiList({
    int page = 1,
    int limit = 50,
    String? jlptLevel,
    int? grade,
    String? search,
  });

  Future<KanjiEntity> getKanjiById(int id);

  Future<KanjiEntity> getKanjiByCharacter(String character);

  Future<KanjiEntity> createKanji(Map<String, dynamic> kanjiData);

  Future<KanjiEntity> updateKanji(int id, Map<String, dynamic> kanjiData);

  Future<void> deleteKanji(int id);
}
