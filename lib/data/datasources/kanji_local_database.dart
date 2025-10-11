import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'kanji_local_database.g.dart';

// Table definition for Kanji
class KanjiTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get character => text()();
  TextColumn get meanings => text()();
  TextColumn get onyomi => text().nullable()();
  TextColumn get kunyomi => text().nullable()();
  IntColumn get strokeCount => integer().nullable()();
  IntColumn get jlpt => integer().nullable()();
  IntColumn get grade => integer().nullable()();
  IntColumn get frequency => integer().nullable()();
  TextColumn get radicals => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [KanjiTable])
class KanjiLocalDatabase extends _$KanjiLocalDatabase {
  KanjiLocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Basic CRUD operations
  Future<List<KanjiTableData>> getAllKanjis() => select(kanjiTable).get();

  Future<KanjiTableData> insertKanji(KanjiTableCompanion kanji) =>
      into(kanjiTable).insertReturning(kanji);

  Future<bool> updateKanji(KanjiTableData kanji) =>
      update(kanjiTable).replace(kanji);

  Future<int> deleteKanji(int id) =>
      (delete(kanjiTable)..where((t) => t.id.equals(id))).go();

  // Search functionality
  Future<List<KanjiTableData>> searchKanjis(String query) {
    final lowercaseQuery = query.toLowerCase();
    return (select(kanjiTable)..where(
          (t) =>
              t.character.contains(query) |
              t.meanings.lower().contains(lowercaseQuery) |
              t.onyomi.lower().contains(lowercaseQuery) |
              t.kunyomi.lower().contains(lowercaseQuery),
        ))
        .get();
  }

  // Sync-related operations
  Future<List<KanjiTableData>> getUnsyncedKanjis() =>
      (select(kanjiTable)..where((t) => t.isSynced.equals(false))).get();

  Future<void> markAsSynced(int id) {
    return (update(kanjiTable)..where((t) => t.id.equals(id))).write(
      const KanjiTableCompanion(isSynced: Value(true)),
    );
  }

  Future<void> markAllAsSynced() {
    return update(
      kanjiTable,
    ).write(const KanjiTableCompanion(isSynced: Value(true)));
  }

  // Batch operations for sync
  Future<void> insertOrUpdateBatch(List<KanjiTableCompanion> kanjis) async {
    await batch((batch) {
      for (final kanji in kanjis) {
        batch.insert(
          kanjiTable,
          kanji.copyWith(isSynced: const Value(true)),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // Get kanji by character (for duplicate checking)
  Future<KanjiTableData?> getKanjiByCharacter(String character) {
    return (select(
      kanjiTable,
    )..where((t) => t.character.equals(character))).getSingleOrNull();
  }

  // Clear all data
  Future<void> clearAllKanjis() => delete(kanjiTable).go();

  // Get statistics
  Future<int> getKanjiCount() async {
    final count = await (selectOnly(
      kanjiTable,
    )..addColumns([kanjiTable.id.count()])).getSingle();
    return count.read(kanjiTable.id.count()) ?? 0;
  }

  Future<int> getUnsyncedCount() async {
    final count =
        await (selectOnly(kanjiTable)
              ..addColumns([kanjiTable.id.count()])
              ..where(kanjiTable.isSynced.equals(false)))
            .getSingle();
    return count.read(kanjiTable.id.count()) ?? 0;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'kanji_offline.db'));
    return NativeDatabase(file);
  });
}
