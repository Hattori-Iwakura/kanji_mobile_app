import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoint.dart';
import '../../domain/entities/kanji_list_exception.dart';
import '../models/kanji_list.dart';

abstract class KanjiListRemoteDataSource {
  Future<List<KanjiList>> getAllLists({
    String? search,
    String? type,
    int? limit,
    int? offset,
  });
  Future<KanjiList> getListById(int id);
  Future<KanjiList> createList({
    required String name,
    String? description,
    List<int>? kanjiIds,
    int? categoryId,
  });
  Future<KanjiList> updateList({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
    int? categoryId,
  });
  Future<void> deleteList(int id);
  Future<void> addKanji({required int listId, required int kanjiId});
  Future<void> removeKanji({required int listId, required int kanjiId});
  Future<void> requestPublish(int listId);
  Future<List<dynamic>> getPublishRequests({String? status});
  Future<void> approvePublishRequest(int requestId);
  Future<void> rejectPublishRequest(int requestId, String? reason);
}

class KanjiListRemoteDataSourceImpl implements KanjiListRemoteDataSource {
  final ApiClient _apiClient;

  KanjiListRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<KanjiList>> getAllLists({
    String? search,
    String? type,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (type != null) queryParams['type'] = type;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiClient.get(
        ApiEndpoints.kanjiLists,
        queryParameters: queryParams,
      );

      final responseData = response.data;
      final data =
          responseData is Map<String, dynamic> &&
              responseData.containsKey('data')
          ? responseData['data'] as List<dynamic>
          : responseData as List<dynamic>;

      return data
          .map((json) => KanjiList.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw KanjiListException(
        e.response?.data['message'] ?? 'Failed to load kanji lists',
      );
    }
  }

  @override
  Future<KanjiList> getListById(int id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.kanjiLists}/$id');
      return KanjiList.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw KanjiListException(
        e.response?.data['message'] ?? 'Failed to load list',
      );
    }
  }

  @override
  Future<KanjiList> createList({
    required String name,
    String? description,
    List<int>? kanjiIds,
    int? categoryId,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        if (description != null) 'description': description,
        if (kanjiIds != null) 'kanjiIds': kanjiIds,
        if (categoryId != null) 'categoryId': categoryId,
      };

      final response = await _apiClient.post(
        ApiEndpoints.kanjiLists,
        data: data,
      );
      return KanjiList.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw KanjiListException(
        e.response?.data['message'] ?? 'Failed to create list',
      );
    }
  }

  @override
  Future<KanjiList> updateList({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
    int? categoryId,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (isPublic != null) data['isPublic'] = isPublic;
      if (categoryId != null) data['categoryId'] = categoryId;

      final response = await _apiClient.put(
        '${ApiEndpoints.kanjiLists}/$id',
        data: data,
      );
      return KanjiList.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw KanjiListException(
        e.response?.data['message'] ?? 'Failed to update list',
      );
    }
  }

  @override
  Future<void> deleteList(int id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.kanjiLists}/$id');
    } on DioException catch (e) {
      throw KanjiListException(
        e.response?.data['message'] ?? 'Failed to delete list',
      );
    }
  }

  @override
  Future<void> addKanji({required int listId, required int kanjiId}) async {
    try {
      await _apiClient.post(
        '${ApiEndpoints.kanjiLists}/$listId/kanji/$kanjiId',
      );
    } on DioException catch (e) {
      throw KanjiListException(
        e.response?.data['message'] ?? 'Failed to add kanji',
      );
    }
  }

  @override
  Future<void> removeKanji({required int listId, required int kanjiId}) async {
    try {
      await _apiClient.delete(
        '${ApiEndpoints.kanjiLists}/$listId/kanji/$kanjiId',
      );
    } on DioException catch (e) {
      throw KanjiListException(
        e.response?.data['message'] ?? 'Failed to remove kanji',
      );
    }
  }

  @override
  Future<void> requestPublish(int listId) async {
    try {
      await _apiClient.post('${ApiEndpoints.kanjiLists}/$listId/publish');
    } on DioException catch (e) {
      throw KanjiListException(
        e.response?.data['message'] ?? 'Failed to request publish',
      );
    }
  }

  @override
  Future<List<dynamic>> getPublishRequests({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.get(
        '${ApiEndpoints.kanjiLists}/admin/publish-requests',
        queryParameters: queryParams,
      );

      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw KanjiListException(
        e.response?.data['message'] ?? 'Failed to get publish requests',
      );
    }
  }

  @override
  Future<void> approvePublishRequest(int requestId) async {
    try {
      await _apiClient.post(
        '${ApiEndpoints.kanjiLists}/admin/publish-requests/$requestId/approve',
      );
    } on DioException catch (e) {
      throw KanjiListException(
        e.response?.data['message'] ?? 'Failed to approve publish request',
      );
    }
  }

  @override
  Future<void> rejectPublishRequest(int requestId, String? reason) async {
    try {
      final data = <String, dynamic>{};
      if (reason != null) data['reason'] = reason;

      await _apiClient.post(
        '${ApiEndpoints.kanjiLists}/admin/publish-requests/$requestId/reject',
        data: data,
      );
    } on DioException catch (e) {
      throw KanjiListException(
        e.response?.data['message'] ?? 'Failed to reject publish request',
      );
    }
  }
}
