import 'package:dio/dio.dart';
import '../models/kanji_table_model.dart';

abstract class KanjiTableRemoteDataSource {
  Future<List<KanjiTableModel>> getTablesByJlpt(String jlptLevel);
  Future<List<KanjiTableModel>> getAllTables({
    String? search,
    String? type,
    int? limit,
    int? offset,
  });
  Future<KanjiTableModel> getTableById(int id);
  Future<KanjiTableModel> createTable({
    required String name,
    String? description,
    int? categoryId,
    List<int>? kanjiIds,
  });
  Future<KanjiTableModel> updateTable({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
    int? categoryId,
  });
  Future<void> deleteTable(int id);
  Future<void> addKanjiToTable({required int tableId, required int kanjiId});
  Future<KanjiTableModel> removeKanjiFromTable({
    required int tableId,
    required int kanjiId,
  });
  Future<PublishRequestModel> requestPublish(int tableId);
  Future<List<PublishRequestModel>> getPublishRequests({String? status});
  Future<PublishRequestModel> approvePublishRequest(int requestId);
  Future<PublishRequestModel> rejectPublishRequest({
    required int requestId,
    String? reason,
  });
}

class KanjiTableRemoteDataSourceImpl implements KanjiTableRemoteDataSource {
  final Dio dio;

  KanjiTableRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<KanjiTableModel>> getTablesByJlpt(String jlptLevel) async {
    final response = await dio.get('/kanji-lists/jlpt/$jlptLevel');
    final data = response.data['data'] as List;
    return data.map((json) => KanjiTableModel.fromJson(json)).toList();
  }

  @override
  Future<List<KanjiTableModel>> getAllTables({
    String? search,
    String? type,
    int? limit,
    int? offset,
  }) async {
    final response = await dio.get(
      '/kanji-lists',
      queryParameters: {
        if (search != null) 'search': search,
        if (type != null) 'type': type,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      },
    );
    final data = response.data['data']['data'] as List;
    return data.map((json) => KanjiTableModel.fromJson(json)).toList();
  }

  @override
  Future<KanjiTableModel> getTableById(int id) async {
    final response = await dio.get('/kanji-lists/$id');
    return KanjiTableModel.fromJson(response.data['data']);
  }

  @override
  Future<KanjiTableModel> createTable({
    required String name,
    String? description,
    int? categoryId,
    List<int>? kanjiIds,
  }) async {
    final response = await dio.post(
      '/kanji-lists',
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (categoryId != null) 'categoryId': categoryId,
        if (kanjiIds != null) 'kanjiIds': kanjiIds,
      },
    );
    return KanjiTableModel.fromJson(response.data['data']);
  }

  @override
  Future<KanjiTableModel> updateTable({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
    int? categoryId,
  }) async {
    final response = await dio.put(
      '/kanji-lists/$id',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (isPublic != null) 'isPublic': isPublic,
        if (categoryId != null) 'categoryId': categoryId,
      },
    );
    return KanjiTableModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteTable(int id) async {
    await dio.delete('/kanji-lists/$id');
  }

  @override
  Future<void> addKanjiToTable({
    required int tableId,
    required int kanjiId,
  }) async {
    await dio.post('/kanji-lists/$tableId/kanji/$kanjiId');
  }

  @override
  Future<KanjiTableModel> removeKanjiFromTable({
    required int tableId,
    required int kanjiId,
  }) async {
    final response = await dio.delete('/kanji-lists/$tableId/kanji/$kanjiId');
    return KanjiTableModel.fromJson(response.data['data']);
  }

  @override
  Future<PublishRequestModel> requestPublish(int tableId) async {
    final response = await dio.post('/kanji-lists/$tableId/publish');
    return PublishRequestModel.fromJson(response.data['data']);
  }

  @override
  Future<List<PublishRequestModel>> getPublishRequests({String? status}) async {
    final response = await dio.get(
      '/kanji-lists/admin/publish-requests',
      queryParameters: {if (status != null) 'status': status},
    );
    final data = response.data['data'] as List;
    return data.map((json) => PublishRequestModel.fromJson(json)).toList();
  }

  @override
  Future<PublishRequestModel> approvePublishRequest(int requestId) async {
    final response = await dio.post(
      '/kanji-lists/admin/publish-requests/$requestId/approve',
    );
    return PublishRequestModel.fromJson(response.data['data']);
  }

  @override
  Future<PublishRequestModel> rejectPublishRequest({
    required int requestId,
    String? reason,
  }) async {
    final response = await dio.post(
      '/kanji-lists/admin/publish-requests/$requestId/reject',
      data: {if (reason != null) 'reason': reason},
    );
    return PublishRequestModel.fromJson(response.data['data']);
  }
}
