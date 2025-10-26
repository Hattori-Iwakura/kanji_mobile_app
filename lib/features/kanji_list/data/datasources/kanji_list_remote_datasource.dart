import 'package:dio/dio.dart';
import '../models/kanji_list_model.dart';

/// Remote data source for KanjiList API
abstract class KanjiListRemoteDataSource {
  Future<KanjiListsResponse> getAllLists({
    String? search,
    int? limit,
    int? offset,
  });
  Future<KanjiListModel> getListById(int id);
  Future<KanjiListModel> createList({
    required String name,
    String? description,
    List<int>? kanjiIds,
  });
  Future<KanjiListModel> updateList({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  });
  Future<void> deleteList(int id);
  Future<KanjiListModel> addKanjiToList(int listId, int kanjiId);
  Future<KanjiListModel> removeKanjiFromList(int listId, int kanjiId);
  Future<KanjiListsResponse> getListsByJlpt(String jlptLevel);
}

/// Implementation of KanjiListRemoteDataSource
class KanjiListRemoteDataSourceImpl implements KanjiListRemoteDataSource {
  final Dio dio;

  KanjiListRemoteDataSourceImpl({required this.dio});

  @override
  Future<KanjiListsResponse> getAllLists({
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await dio.get(
        '/kanji-lists',
        queryParameters: queryParams,
      );

      return KanjiListsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<KanjiListModel> getListById(int id) async {
    try {
      final response = await dio.get('/kanji-lists/$id');
      return KanjiListModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<KanjiListModel> createList({
    required String name,
    String? description,
    List<int>? kanjiIds,
  }) async {
    try {
      final response = await dio.post(
        '/kanji-lists',
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (kanjiIds != null) 'kanjiIds': kanjiIds,
        },
      );
      return KanjiListModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<KanjiListModel> updateList({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (isPublic != null) data['isPublic'] = isPublic;

      final response = await dio.put('/kanji-lists/$id', data: data);
      return KanjiListModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteList(int id) async {
    try {
      await dio.delete('/kanji-lists/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<KanjiListModel> addKanjiToList(int listId, int kanjiId) async {
    try {
      final response = await dio.post('/kanji-lists/$listId/kanji/$kanjiId');
      return KanjiListModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<KanjiListModel> removeKanjiFromList(int listId, int kanjiId) async {
    try {
      final response = await dio.delete('/kanji-lists/$listId/kanji/$kanjiId');
      return KanjiListModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<KanjiListsResponse> getListsByJlpt(String jlptLevel) async {
    try {
      final response = await dio.get('/kanji-lists/jlpt/$jlptLevel');
      return KanjiListsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to appropriate exceptions
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] as String?;

        if (statusCode == 401) {
          return Exception('Unauthorized. Please login again.');
        } else if (statusCode == 404) {
          return Exception('Kanji list not found.');
        } else if (statusCode == 400) {
          return Exception(message ?? 'Invalid request.');
        }
        return Exception(message ?? 'Server error occurred.');
      case DioExceptionType.cancel:
        return Exception('Request cancelled.');
      case DioExceptionType.unknown:
        return Exception('Network error. Please check your connection.');
      default:
        return Exception('Unexpected error occurred.');
    }
  }
}
