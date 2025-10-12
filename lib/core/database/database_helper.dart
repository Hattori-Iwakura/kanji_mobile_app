import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kanji.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE kanji (
        id $idType,
        character $textType,
        strokes $intType,
        grade INTEGER,
        freq INTEGER,
        jlpt_old INTEGER,
        jlpt_new INTEGER,
        meanings $textType,
        readings_on $textType,
        readings_kun $textType,
        wk_level INTEGER,
        wk_meanings TEXT,
        wk_readings_on TEXT,
        wk_readings_kun TEXT,
        wk_radicals TEXT
      )
    ''');

    // Seed data from JSON
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/kanji-merged.json',
      );
      final Map<String, dynamic> kanjiData = json.decode(jsonString);

      final batch = db.batch();

      kanjiData.forEach((character, data) {
        batch.insert('kanji', {
          'character': character,
          'strokes': data['strokes'] ?? 0,
          'grade': data['grade'],
          'freq': data['freq'],
          'jlpt_old': data['jlpt_old'],
          'jlpt_new': data['jlpt_new'],
          'meanings': json.encode(data['meanings'] ?? []),
          'readings_on': json.encode(data['readings_on'] ?? []),
          'readings_kun': json.encode(data['readings_kun'] ?? []),
          'wk_level': data['wk_level'],
          'wk_meanings': json.encode(data['wk_meanings'] ?? []),
          'wk_readings_on': json.encode(data['wk_readings_on'] ?? []),
          'wk_readings_kun': json.encode(data['wk_readings_kun'] ?? []),
          'wk_radicals': json.encode(data['wk_radicals'] ?? []),
        });
      });

      await batch.commit(noResult: true);
    } catch (e) {
      // Log error during seeding
      rethrow;
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
