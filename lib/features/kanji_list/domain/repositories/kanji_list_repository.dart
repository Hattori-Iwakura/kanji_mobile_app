import '../entities/kanji_list_entity.dart';

abstract class KanjiListRepository {
  // List operations (dựa theo Backend API /kanji-lists)
  Future<List<KanjiListEntity>> getAllLists({
    String? search,
    String? type,
    int? limit,
    int? offset,
  });

  Future<KanjiListEntity> getListById(int id);

  Future<KanjiListEntity> createList({
    required String name,
    String? description,
    List<int>? kanjiIds,
  });

  Future<KanjiListEntity> updateList({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  });

  Future<void> deleteList(int id);

  // Kanji operations
  Future<void> addKanji({required int listId, required int kanjiId});

  Future<void> removeKanji({required int listId, required int kanjiId});

  // Publish operations
  Future<void> requestPublish(int listId);

  Future<List<dynamic>> getPublishRequests({String? status});

  Future<void> approvePublishRequest(int requestId);

  Future<void> rejectPublishRequest(int requestId, String? reason);
}
