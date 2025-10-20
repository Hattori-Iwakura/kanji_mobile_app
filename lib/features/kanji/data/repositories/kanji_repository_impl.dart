import '../../domain/entities/kanji_entity.dart';
import '../../domain/entities/kanji_exception.dart';
import '../../domain/repositories/kanji_repository.dart';
import '../datasources/kanji_remote_datasource.dart';

class KanjiRepositoryImpl implements KanjiRepository {
  final KanjiRemoteDataSource remoteDataSource;

  KanjiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<KanjiEntity>> getKanjiList({
    int page = 1,
    int limit = 50,
    String? jlptLevel,
    int? grade,
    String? search,
  }) async {
    try {
      final models = await remoteDataSource.getKanjiList(
        page: page,
        limit: limit,
        jlptLevel: jlptLevel,
        grade: grade,
        search: search,
      );
      return models.map((model) => model.toEntity()).toList();
    } on KanjiException {
      rethrow;
    } catch (e) {
      throw KanjiException('Failed to get kanji list: $e');
    }
  }

  @override
  Future<KanjiEntity> getKanjiById(int id) async {
    try {
      final model = await remoteDataSource.getKanjiById(id);
      return model.toEntity();
    } on KanjiException {
      rethrow;
    } catch (e) {
      throw KanjiException('Failed to get kanji by id: $e');
    }
  }

  @override
  Future<KanjiEntity> getKanjiByCharacter(String character) async {
    try {
      final model = await remoteDataSource.getKanjiByCharacter(character);
      return model.toEntity();
    } on KanjiException {
      rethrow;
    } catch (e) {
      throw KanjiException('Failed to get kanji by character: $e');
    }
  }

  @override
  Future<KanjiEntity> createKanji(Map<String, dynamic> kanjiData) async {
    try {
      final model = await remoteDataSource.createKanji(kanjiData);
      return model.toEntity();
    } on KanjiException {
      rethrow;
    } catch (e) {
      throw KanjiException('Failed to create kanji: $e');
    }
  }

  @override
  Future<KanjiEntity> updateKanji(
    int id,
    Map<String, dynamic> kanjiData,
  ) async {
    try {
      final model = await remoteDataSource.updateKanji(id, kanjiData);
      return model.toEntity();
    } on KanjiException {
      rethrow;
    } catch (e) {
      throw KanjiException('Failed to update kanji: $e');
    }
  }

  @override
  Future<void> deleteKanji(int id) async {
    try {
      await remoteDataSource.deleteKanji(id);
    } on KanjiException {
      rethrow;
    } catch (e) {
      throw KanjiException('Failed to delete kanji: $e');
    }
  }
}
