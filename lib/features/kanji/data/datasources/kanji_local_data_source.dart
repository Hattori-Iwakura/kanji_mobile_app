import '../../../../core/database/database_helper.dart';
import '../models/kanji_model.dart';

abstract class KanjiLocalDataSource {
  Future<List<KanjiModel>> getAllKanji();
  Future<KanjiModel> getKanjiById(int id);
  Future<List<KanjiModel>> getKanjiByGrade(int grade);
  Future<List<KanjiModel>> getKanjiByJlptLevel(int level);
  Future<List<KanjiModel>> searchKanji(String query);
  Future<List<KanjiModel>> getKanjiByFrequency(int minFreq, int maxFreq);
}

class KanjiLocalDataSourceImpl implements KanjiLocalDataSource {
  final DatabaseHelper databaseHelper;

  KanjiLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<KanjiModel>> getAllKanji() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('kanji');
    return List.generate(maps.length, (i) {
      return KanjiModel.fromJson(maps[i]);
    });
  }

  @override
  Future<KanjiModel> getKanjiById(int id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kanji',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      throw Exception('Kanji not found');
    }

    return KanjiModel.fromJson(maps.first);
  }

  @override
  Future<List<KanjiModel>> getKanjiByGrade(int grade) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kanji',
      where: 'grade = ?',
      whereArgs: [grade],
    );

    return List.generate(maps.length, (i) {
      return KanjiModel.fromJson(maps[i]);
    });
  }

  @override
  Future<List<KanjiModel>> getKanjiByJlptLevel(int level) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kanji',
      where: 'jlpt_new = ?',
      whereArgs: [level],
    );

    return List.generate(maps.length, (i) {
      return KanjiModel.fromJson(maps[i]);
    });
  }

  @override
  Future<List<KanjiModel>> searchKanji(String query) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kanji',
      where: 'character LIKE ? OR meanings LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return KanjiModel.fromJson(maps[i]);
    });
  }

  @override
  Future<List<KanjiModel>> getKanjiByFrequency(int minFreq, int maxFreq) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kanji',
      where: 'freq >= ? AND freq <= ?',
      whereArgs: [minFreq, maxFreq],
      orderBy: 'freq ASC',
    );

    return List.generate(maps.length, (i) {
      return KanjiModel.fromJson(maps[i]);
    });
  }
}
