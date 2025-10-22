import 'package:dio/dio.dart';
import '../models/kanji_model.dart';

/// Remote data source for Kanji API
abstract class KanjiRemoteDataSource {
  Future<List<KanjiModel>> getAllKanji({
    int? jlpt,
    int? grade,
    String? search,
    int? limit,
    int? offset,
  });

  Future<KanjiModel> getKanjiById(int id);

  Future<KanjiModel> getKanjiByCharacter(String character);

  Future<List<KanjiModel>> searchKanji({
    String? query,
    List<int>? jlptLevels,
    List<int>? grades,
    int? minStrokes,
    int? maxStrokes,
    int page,
    int limit,
    String? sortBy,
  });
}

class KanjiRemoteDataSourceImpl implements KanjiRemoteDataSource {
  final Dio dio;

  KanjiRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<KanjiModel>> getAllKanji({
    int? jlpt,
    int? grade,
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (jlpt != null) queryParams['jlpt'] = jlpt;
      if (grade != null) queryParams['grade'] = grade;
      if (search != null) queryParams['search'] = search;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await dio.get('/kanji', queryParameters: queryParams);

      // Handle response structure: {statusCode, data: {data: [...], total, limit, offset}, timestamp}
      final responseData = response.data;
      final dataWrapper = responseData['data'] as Map<String, dynamic>;
      final kanjiList = dataWrapper['data'] as List;

      return kanjiList.map((json) => KanjiModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<KanjiModel> getKanjiById(int id) async {
    try {
      final response = await dio.get('/kanji/$id');

      final data = response.data;
      return KanjiModel.fromJson(data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<KanjiModel> getKanjiByCharacter(String character) async {
    try {
      final response = await dio.get('/kanji/character/$character');

      final data = response.data;
      return KanjiModel.fromJson(data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<KanjiModel>> searchKanji({
    String? query,
    List<int>? jlptLevels,
    List<int>? grades,
    int? minStrokes,
    int? maxStrokes,
    int page = 1,
    int limit = 20,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (query != null) queryParams['query'] = query;
      if (jlptLevels != null && jlptLevels.isNotEmpty) {
        queryParams['jlptLevels'] = jlptLevels.join(',');
      }
      if (grades != null && grades.isNotEmpty) {
        queryParams['grades'] = grades.join(',');
      }
      if (minStrokes != null) queryParams['minStrokes'] = minStrokes;
      if (maxStrokes != null) queryParams['maxStrokes'] = maxStrokes;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final response = await dio.get(
        '/kanji/search',
        queryParameters: queryParams,
      );

      final responseData = response.data;
      final dataWrapper = responseData['data'] as Map<String, dynamic>;
      final kanjiList = dataWrapper['data'] as List;

      return kanjiList.map((json) => KanjiModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return Exception('Unauthorized');
        } else if (statusCode == 404) {
          return Exception('Not found');
        } else if (statusCode == 400) {
          return Exception('Bad request');
        }
        return Exception('Server error: $statusCode');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error');
    }
  }
}
