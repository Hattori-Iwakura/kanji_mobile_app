import '../../domain/entities/kanji_entity.dart';
import '../../domain/repositories/kanji_repository.dart';
import '../datasources/kanji_local_database.dart';
import '../remote/kanji_remote_data_source.dart';
import '../extensions/kanji_extensions.dart';

class KanjiRepositoryHybrid implements KanjiRepository {
  final KanjiRemoteDataSource remoteDataSource;
  final KanjiLocalDatabase localDatabase;

  KanjiRepositoryHybrid({
    required this.remoteDataSource,
    required this.localDatabase,
  });

  @override
  Future<List<Kanji>> getAll() async {
    try {
      // Try to fetch from remote first
      final remoteKanjis = await remoteDataSource.fetchAllKanjis();

      // Update local database with remote data
      await _syncLocalWithRemote(remoteKanjis);

      return remoteKanjis;
    } catch (e) {
      // If remote fails, fallback to local database
      print('Remote fetch failed, using local data: $e');
      final localData = await localDatabase.getAllKanjis();
      return localData.toEntityList();
    }
  }

  @override
  Future<Kanji> create(Map<String, dynamic> data) async {
    final kanji = Kanji.fromJson(data);

    try {
      // Try to create remotely first
      final createdKanji = await remoteDataSource.createKanji(data);

      // Add to local database
      await localDatabase.insertKanji(createdKanji.toInsertCompanion());

      return createdKanji;
    } catch (e) {
      // If remote fails, create locally with temporary negative ID
      print('Remote create failed, creating locally: $e');
      final localKanji = kanji.copyWith(
        id:
            DateTime.now().millisecondsSinceEpoch *
            -1, // Negative ID for local-only
      );
      await localDatabase.insertKanji(localKanji.toInsertCompanion());
      return localKanji;
    }
  }

  @override
  Future<Kanji> update(int id, Map<String, dynamic> data) async {
    try {
      // Try to update remotely first
      final updatedKanji = await remoteDataSource.updateKanji(id, data);

      // Update local database
      await localDatabase.updateKanji(updatedKanji.toTableData());

      return updatedKanji;
    } catch (e) {
      // If remote fails, update locally
      print('Remote update failed, updating locally: $e');
      final kanji = Kanji.fromJson({...data, 'id': id});
      await localDatabase.updateKanji(kanji.toTableData());
      return kanji;
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      // Try to delete remotely first
      await remoteDataSource.deleteKanji(id);

      // Delete from local database
      await localDatabase.deleteKanji(id);
    } catch (e) {
      // If remote fails, mark as deleted locally (soft delete)
      print('Remote delete failed, marking as deleted locally: $e');
      await localDatabase.deleteKanji(id);
    }
  }

  // Additional search method (not in base interface)
  Future<List<Kanji>> searchKanjis(String query) async {
    try {
      // Try to search remotely first
      final remoteResults = await remoteDataSource.fetchAllKanjis();
      final filteredResults = remoteResults
          .where(
            (kanji) =>
                kanji.character.contains(query) ||
                kanji.meaningsList.any(
                  (meaning) =>
                      meaning.toLowerCase().contains(query.toLowerCase()),
                ) ||
                kanji.onyomiList.any((reading) => reading.contains(query)) ||
                kanji.kunyomiList.any((reading) => reading.contains(query)),
          )
          .toList();

      return filteredResults;
    } catch (e) {
      // If remote fails, search locally
      print('Remote search failed, searching locally: $e');
      final localResults = await localDatabase.searchKanjis(query);
      return localResults.toEntityList();
    }
  }

  // Sync methods
  Future<void> syncToRemote() async {
    try {
      final localData = await localDatabase.getAllKanjis();
      final localKanjis = localData.toEntityList();

      for (final kanji in localKanjis) {
        if (kanji.id < 0) {
          // This is a local-only kanji, create it remotely
          try {
            final remoteKanji = await remoteDataSource.createKanji(
              kanji.toJson(),
            );
            // Update local with the remote ID
            await localDatabase.deleteKanji(kanji.id);
            await localDatabase.insertKanji(remoteKanji.toInsertCompanion());
          } catch (e) {
            print('Failed to sync kanji ${kanji.character} to remote: $e');
          }
        }
      }
    } catch (e) {
      print('Sync to remote failed: $e');
    }
  }

  Future<void> syncFromRemote() async {
    try {
      final remoteKanjis = await remoteDataSource.fetchAllKanjis();
      await _syncLocalWithRemote(remoteKanjis);
    } catch (e) {
      print('Sync from remote failed: $e');
    }
  }

  Future<void> _syncLocalWithRemote(List<Kanji> remoteKanjis) async {
    try {
      // Clear local database and insert all remote data
      // This is a simple approach - for production, you'd want incremental sync
      await localDatabase.clearAllKanjis();

      for (final kanji in remoteKanjis) {
        await localDatabase.insertKanji(kanji.toInsertCompanion());
      }
    } catch (e) {
      print('Failed to sync local with remote: $e');
    }
  }

  Future<bool> isOnline() async {
    try {
      await remoteDataSource.fetchAllKanjis();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> getLocalKanjiCount() async {
    final kanjis = await localDatabase.getAllKanjis();
    return kanjis.length;
  }

  Future<int> getPendingSyncCount() async {
    final localData = await localDatabase.getAllKanjis();
    final localKanjis = localData.toEntityList();
    return localKanjis.where((kanji) => kanji.id < 0).length;
  }
}
