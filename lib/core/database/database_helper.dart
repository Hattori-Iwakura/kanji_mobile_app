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

    return await openDatabase(
      path,
      version: 4, // Bumped version to seed frequency lists
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
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

    // Create kanji_lists table
    await db.execute('''
      CREATE TABLE kanji_lists (
        id $idType,
        name $textType,
        description TEXT,
        filter_type $textType,
        filter_value INTEGER,
        frequency_min INTEGER,
        frequency_max INTEGER,
        created_at $textType,
        updated_at $textType,
        kanji_count INTEGER DEFAULT 0
      )
    ''');

    // Create kanji_list_items table (junction table)
    await db.execute('''
      CREATE TABLE kanji_list_items (
        id $idType,
        list_id $intType,
        kanji_id $intType,
        added_at $textType,
        FOREIGN KEY (list_id) REFERENCES kanji_lists (id) ON DELETE CASCADE,
        FOREIGN KEY (kanji_id) REFERENCES kanji (id) ON DELETE CASCADE,
        UNIQUE(list_id, kanji_id)
      )
    ''');

    // Seed data from JSON
    await _seedData(db);

    // Seed default kanji lists
    await _seedDefaultLists(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const intType = 'INTEGER NOT NULL';

      // Create kanji_lists table
      await db.execute('''
        CREATE TABLE kanji_lists (
          id $idType,
          name $textType,
          description TEXT,
          filter_type $textType,
          filter_value INTEGER,
          frequency_min INTEGER,
          frequency_max INTEGER,
          created_at $textType,
          updated_at $textType,
          kanji_count INTEGER DEFAULT 0
        )
      ''');

      // Create kanji_list_items table
      await db.execute('''
        CREATE TABLE kanji_list_items (
          id $idType,
          list_id $intType,
          kanji_id $intType,
          added_at $textType,
          FOREIGN KEY (list_id) REFERENCES kanji_lists (id) ON DELETE CASCADE,
          FOREIGN KEY (kanji_id) REFERENCES kanji (id) ON DELETE CASCADE,
          UNIQUE(list_id, kanji_id)
        )
      ''');
    }

    // Seed default lists for version 3
    if (oldVersion < 3) {
      await _seedDefaultLists(db);
    }

    // Add frequency lists for version 4
    if (oldVersion < 4) {
      // Clear existing lists and reseed all (including frequency)
      await db.delete('kanji_list_items');
      await db.delete('kanji_lists');
      await _seedDefaultLists(db);
    }
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

  Future<void> _seedDefaultLists(Database db) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Check if default lists already exist
      final existingLists = await db.query('kanji_lists');
      if (existingLists.isNotEmpty) {
        return; // Lists already seeded
      }

      final batch = db.batch();

      // Create JLPT lists (N5 to N1)
      final jlptLists = [
        {
          'name': 'JLPT N5',
          'description': 'Kanji cơ bản nhất cho người mới bắt đầu (80 kanji)',
          'filter_type': 'jlptLevel',
          'filter_value': 5,
        },
        {
          'name': 'JLPT N4',
          'description': 'Kanji cấp độ sơ cấp (103 kanji)',
          'filter_type': 'jlptLevel',
          'filter_value': 4,
        },
        {
          'name': 'JLPT N3',
          'description': 'Kanji cấp độ trung cấp (181 kanji)',
          'filter_type': 'jlptLevel',
          'filter_value': 3,
        },
        {
          'name': 'JLPT N2',
          'description': 'Kanji cấp độ trung cao (367 kanji)',
          'filter_type': 'jlptLevel',
          'filter_value': 2,
        },
        {
          'name': 'JLPT N1',
          'description': 'Kanji cấp độ cao nhất (1235 kanji)',
          'filter_type': 'jlptLevel',
          'filter_value': 1,
        },
      ];

      // Create Grade lists (1 to 6)
      final gradeLists = [
        {
          'name': 'Kyōiku Kanji - Lớp 1',
          'description': '80 kanji cơ bản nhất được dạy ở lớp 1',
          'filter_type': 'grade',
          'filter_value': 1,
        },
        {
          'name': 'Kyōiku Kanji - Lớp 2',
          'description': '160 kanji được dạy ở lớp 2',
          'filter_type': 'grade',
          'filter_value': 2,
        },
        {
          'name': 'Kyōiku Kanji - Lớp 3',
          'description': '200 kanji được dạy ở lớp 3',
          'filter_type': 'grade',
          'filter_value': 3,
        },
        {
          'name': 'Kyōiku Kanji - Lớp 4',
          'description': '202 kanji được dạy ở lớp 4',
          'filter_type': 'grade',
          'filter_value': 4,
        },
        {
          'name': 'Kyōiku Kanji - Lớp 5',
          'description': '193 kanji được dạy ở lớp 5',
          'filter_type': 'grade',
          'filter_value': 5,
        },
        {
          'name': 'Kyōiku Kanji - Lớp 6',
          'description': '191 kanji được dạy ở lớp 6',
          'filter_type': 'grade',
          'filter_value': 6,
        },
      ];

      // Create Frequency lists (Most common kanji)
      final frequencyLists = [
        {
          'name': 'Top 100 Kanji Phổ Biến',
          'description': '100 kanji thường gặp nhất - Phủ ~40% văn bản',
          'filter_type': 'frequency',
          'frequency_min': 1,
          'frequency_max': 100,
        },
        {
          'name': 'Top 250 Kanji Phổ Biến',
          'description': '250 kanji thường gặp - Phủ ~55% văn bản',
          'filter_type': 'frequency',
          'frequency_min': 1,
          'frequency_max': 250,
        },
        {
          'name': 'Top 500 Kanji Phổ Biến',
          'description': '500 kanji thường gặp - Phủ ~75% văn bản',
          'filter_type': 'frequency',
          'frequency_min': 1,
          'frequency_max': 500,
        },
        {
          'name': 'Top 1000 Kanji Phổ Biến',
          'description': '1000 kanji thường gặp - Phủ ~90% văn bản',
          'filter_type': 'frequency',
          'frequency_min': 1,
          'frequency_max': 1000,
        },
        {
          'name': 'Top 1500 Kanji Phổ Biến',
          'description': '1500 kanji thường gặp - Phủ ~95% văn bản',
          'filter_type': 'frequency',
          'frequency_min': 1,
          'frequency_max': 1500,
        },
      ];

      // Insert all lists
      final allLists = [...jlptLists, ...gradeLists, ...frequencyLists];
      for (var listData in allLists) {
        batch.insert('kanji_lists', {
          'name': listData['name'],
          'description': listData['description'],
          'filter_type': listData['filter_type'],
          'filter_value': listData['filter_value'],
          'frequency_min': listData['frequency_min'],
          'frequency_max': listData['frequency_max'],
          'created_at': now,
          'updated_at': now,
          'kanji_count': 0,
        });
      }

      await batch.commit(noResult: false);

      // Now populate the lists with actual kanji
      await _populateDefaultLists(db);
    } catch (e) {
      // Log error during list seeding
      rethrow;
    }
  }

  Future<void> _populateDefaultLists(Database db) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Get all lists
      final lists = await db.query('kanji_lists');

      for (var list in lists) {
        final listId = list['id'] as int;
        final filterType = list['filter_type'] as String;
        final filterValue = list['filter_value'] as int?;
        final frequencyMin = list['frequency_min'] as int?;
        final frequencyMax = list['frequency_max'] as int?;

        List<Map<String, dynamic>> kanjiToAdd = [];

        if (filterType == 'jlptLevel') {
          // Get kanji by JLPT level
          kanjiToAdd = await db.query(
            'kanji',
            where: 'jlpt_new = ?',
            whereArgs: [filterValue],
          );
        } else if (filterType == 'grade') {
          // Get kanji by grade
          kanjiToAdd = await db.query(
            'kanji',
            where: 'grade = ?',
            whereArgs: [filterValue],
          );
        } else if (filterType == 'frequency') {
          // Get kanji by frequency range
          kanjiToAdd = await db.query(
            'kanji',
            where: 'freq >= ? AND freq <= ? AND freq IS NOT NULL',
            whereArgs: [frequencyMin, frequencyMax],
            orderBy: 'freq ASC',
          );
        }

        if (kanjiToAdd.isNotEmpty) {
          final batch = db.batch();

          // Add kanji to list
          for (var kanji in kanjiToAdd) {
            batch.insert('kanji_list_items', {
              'list_id': listId,
              'kanji_id': kanji['id'],
              'added_at': now,
            });
          }

          // Update kanji count
          batch.update(
            'kanji_lists',
            {'kanji_count': kanjiToAdd.length, 'updated_at': now},
            where: 'id = ?',
            whereArgs: [listId],
          );

          await batch.commit(noResult: true);
        }
      }
    } catch (e) {
      // Log error during population
      rethrow;
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
