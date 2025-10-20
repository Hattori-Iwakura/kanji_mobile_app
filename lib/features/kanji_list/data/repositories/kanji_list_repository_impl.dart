import '../../domain/entities/kanji_list_entity.dart';
import '../../domain/entities/kanji_list_exception.dart';
import '../../domain/repositories/kanji_list_repository.dart';
import '../datasources/kanji_list_remote_datasource.dart';

class KanjiListRepositoryImpl implements KanjiListRepository {
  final KanjiListRemoteDataSource remoteDataSource;

  KanjiListRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<KanjiListEntity>> getAllLists({
    String? search,
    String? type,
    int? limit,
    int? offset,
  }) async {
    try {
      final lists = await remoteDataSource.getAllLists(
        search: search,
        type: type,
        limit: limit,
        offset: offset,
      );
      return lists.map((list) => list.toEntity()).toList();
    } on KanjiListException {
      rethrow;
    } catch (e) {
      throw KanjiListException('Failed to get kanji lists: $e');
    }
  }

  @override
  Future<KanjiListEntity> getListById(int id) async {
    try {
      final list = await remoteDataSource.getListById(id);
      return list.toEntity();
    } on KanjiListException {
      rethrow;
    } catch (e) {
      throw KanjiListException('Failed to get list: $e');
    }
  }

  @override
  Future<KanjiListEntity> createList({
    required String name,
    String? description,
    List<int>? kanjiIds,
  }) async {
    try {
      final list = await remoteDataSource.createList(
        name: name,
        description: description,
        kanjiIds: kanjiIds,
      );
      return list.toEntity();
    } on KanjiListException {
      rethrow;
    } catch (e) {
      throw KanjiListException('Failed to create list: $e');
    }
  }

  @override
  Future<KanjiListEntity> updateList({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final list = await remoteDataSource.updateList(
        id: id,
        name: name,
        description: description,
        isPublic: isPublic,
      );
      return list.toEntity();
    } on KanjiListException {
      rethrow;
    } catch (e) {
      throw KanjiListException('Failed to update list: $e');
    }
  }

  @override
  Future<void> deleteList(int id) async {
    try {
      await remoteDataSource.deleteList(id);
    } on KanjiListException {
      rethrow;
    } catch (e) {
      throw KanjiListException('Failed to delete list: $e');
    }
  }

  @override
  Future<void> addKanji({required int listId, required int kanjiId}) async {
    try {
      await remoteDataSource.addKanji(listId: listId, kanjiId: kanjiId);
    } on KanjiListException {
      rethrow;
    } catch (e) {
      throw KanjiListException('Failed to add kanji: $e');
    }
  }

  @override
  Future<void> removeKanji({required int listId, required int kanjiId}) async {
    try {
      await remoteDataSource.removeKanji(listId: listId, kanjiId: kanjiId);
    } on KanjiListException {
      rethrow;
    } catch (e) {
      throw KanjiListException('Failed to remove kanji: $e');
    }
  }

  @override
  Future<void> requestPublish(int listId) async {
    try {
      await remoteDataSource.requestPublish(listId);
    } on KanjiListException {
      rethrow;
    } catch (e) {
      throw KanjiListException('Failed to request publish: $e');
    }
  }

  @override
  Future<List<dynamic>> getPublishRequests({String? status}) async {
    try {
      return await remoteDataSource.getPublishRequests(status: status);
    } on KanjiListException {
      rethrow;
    } catch (e) {
      throw KanjiListException('Failed to get publish requests: $e');
    }
  }

  @override
  Future<void> approvePublishRequest(int requestId) async {
    try {
      await remoteDataSource.approvePublishRequest(requestId);
    } on KanjiListException {
      rethrow;
    } catch (e) {
      throw KanjiListException('Failed to approve publish request: $e');
    }
  }

  @override
  Future<void> rejectPublishRequest(int requestId, String? reason) async {
    try {
      await remoteDataSource.rejectPublishRequest(requestId, reason);
    } on KanjiListException {
      rethrow;
    } catch (e) {
      throw KanjiListException('Failed to reject publish request: $e');
    }
  }
}
