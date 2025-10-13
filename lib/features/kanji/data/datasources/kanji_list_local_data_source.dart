import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/kanji_list_model.dart';

abstract class KanjiListLocalDataSource {
  Future<List<KanjiListModel>> getAllLists();
  Future<KanjiListModel> getListById(int id);
  Future<KanjiListModel> createList(KanjiListModel list);
  Future<void> updateList(KanjiListModel list);
  Future<void> deleteList(int id);
  Future<List<int>> getKanjiIdsInList(int listId);
  Future<void> addKanjiToList(int listId, List<int> kanjiIds);
  Future<void> removeKanjiFromList(int listId, int kanjiId);
}

class KanjiListLocalDataSourceImpl implements KanjiListLocalDataSource {
  final DatabaseHelper databaseHelper;

  KanjiListLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<KanjiListModel>> getAllLists() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kanji_lists',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return KanjiListModel.fromJson(maps[i]);
    });
  }

  @override
  Future<KanjiListModel> getListById(int id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kanji_lists',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      throw Exception('List not found');
    }

    return KanjiListModel.fromJson(maps.first);
  }

  @override
  Future<KanjiListModel> createList(KanjiListModel list) async {
    final db = await databaseHelper.database;
    final id = await db.insert('kanji_lists', list.toJson());

    final created = await getListById(id);
    return created;
  }

  @override
  Future<void> updateList(KanjiListModel list) async {
    final db = await databaseHelper.database;
    await db.update(
      'kanji_lists',
      list.toJson(),
      where: 'id = ?',
      whereArgs: [list.id],
    );
  }

  @override
  Future<void> deleteList(int id) async {
    final db = await databaseHelper.database;
    await db.delete('kanji_lists', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<int>> getKanjiIdsInList(int listId) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kanji_list_items',
      columns: ['kanji_id'],
      where: 'list_id = ?',
      whereArgs: [listId],
    );

    return maps.map((map) => map['kanji_id'] as int).toList();
  }

  @override
  Future<void> addKanjiToList(int listId, List<int> kanjiIds) async {
    final db = await databaseHelper.database;
    final batch = db.batch();

    for (var kanjiId in kanjiIds) {
      batch.insert('kanji_list_items', {
        'list_id': listId,
        'kanji_id': kanjiId,
        'added_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await batch.commit(noResult: true);

    // Update kanji_count
    final count = await db.rawQuery(
      'SELECT COUNT(*) as count FROM kanji_list_items WHERE list_id = ?',
      [listId],
    );
    final kanjiCount = count.first['count'] as int;

    await db.update(
      'kanji_lists',
      {'kanji_count': kanjiCount},
      where: 'id = ?',
      whereArgs: [listId],
    );
  }

  @override
  Future<void> removeKanjiFromList(int listId, int kanjiId) async {
    final db = await databaseHelper.database;
    await db.delete(
      'kanji_list_items',
      where: 'list_id = ? AND kanji_id = ?',
      whereArgs: [listId, kanjiId],
    );

    // Update kanji_count
    final count = await db.rawQuery(
      'SELECT COUNT(*) as count FROM kanji_list_items WHERE list_id = ?',
      [listId],
    );
    final kanjiCount = count.first['count'] as int;

    await db.update(
      'kanji_lists',
      {'kanji_count': kanjiCount},
      where: 'id = ?',
      whereArgs: [listId],
    );
  }
}
