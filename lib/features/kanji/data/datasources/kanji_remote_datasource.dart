import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoint.dart';
import '../../../../core/error/exceptions.dart';
import '../models/kanji_model.dart';
import '../../domain/usecases/create_kanji.dart';
import '../../domain/usecases/update_kanji.dart';

abstract class KanjiRemoteDataSource {
  Future<List<KanjiModel>> getAllKanji();
  Future<KanjiModel> getKanjiById(int id);
  Future<KanjiModel> getKanjiByCharacter(String character);
  
  // CRUD methods for Admin
  Future<KanjiModel> createKanji(CreateKanjiParams params);
  Future<KanjiModel> updateKanji(UpdateKanjiParams params);
  Future<KanjiModel> deleteKanji(int id);
}

class KanjiRemoteDataSourceImpl implements KanjiRemoteDataSource {
  final ApiClient apiClient;

  KanjiRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<KanjiModel>> getAllKanji() async {
    try {
      final response = await apiClient.get(ApiEndpoints.kanjiList);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Check if response is wrapped in a data field
        final data = responseData.containsKey('data')
            ? responseData['data']
            : responseData;

        // Data could be a list directly or an object with a list
        final List<dynamic> kanjiList = data is List
            ? data
            : (data['kanjis'] ?? data['data'] ?? data);

        return kanjiList
            .map((json) => KanjiModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          'Failed to load kanji list: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access');
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<KanjiModel> getKanjiById(int id) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.kanjiList}/$id');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Check if response is wrapped in a data field
        final data = responseData.containsKey('data')
            ? responseData['data'] as Map<String, dynamic>
            : responseData;

        return KanjiModel.fromJson(data);
      } else {
        throw ServerException('Kanji not found: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException('Kanji not found');
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<KanjiModel> getKanjiByCharacter(String character) async {
    try {
      final response = await apiClient.get(
        '${ApiEndpoints.kanjiList}/character/$character',
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Check if response is wrapped in a data field
        final data = responseData.containsKey('data')
            ? responseData['data'] as Map<String, dynamic>
            : responseData;

        return KanjiModel.fromJson(data);
      } else {
        throw ServerException('Kanji not found: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException('Kanji not found');
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<KanjiModel> createKanji(CreateKanjiParams params) async {
    try {
      final response = await apiClient.post(
        '${ApiEndpoints.kanjiList}/create',
        params.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;

        // Check if response is wrapped in a data field
        final data = responseData.containsKey('data')
            ? responseData['data'] as Map<String, dynamic>
            : responseData;

        return KanjiModel.fromJson(data);
      } else {
        throw ServerException('Failed to create kanji: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ServerException('Kanji already exists or invalid data');
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<KanjiModel> updateKanji(UpdateKanjiParams params) async {
    try {
      final response = await apiClient.put(
        '${ApiEndpoints.kanjiList}/update/${params.id}',
        params.toJson(),
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Check if response is wrapped in a data field
        final data = responseData.containsKey('data')
            ? responseData['data'] as Map<String, dynamic>
            : responseData;

        return KanjiModel.fromJson(data);
      } else {
        throw ServerException('Failed to update kanji: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException('Kanji not found');
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<KanjiModel> deleteKanji(int id) async {
    try {
      final response = await apiClient.delete(
        '${ApiEndpoints.kanjiList}/$id',
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Check if response is wrapped in a data field
        final data = responseData.containsKey('data')
            ? responseData['data'] as Map<String, dynamic>
            : responseData;

        return KanjiModel.fromJson(data);
      } else {
        throw ServerException('Failed to delete kanji: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException('Kanji not found');
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
