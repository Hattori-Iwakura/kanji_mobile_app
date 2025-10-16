import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoint.dart';
import '../../../../core/error/exceptions.dart';
import '../models/kanji_model.dart';
import '../models/kanji_detail_model.dart';
import '../models/kanji_example_model.dart';
import '../models/kanji_list_model.dart';
import '../models/kanji_progress_model.dart';
import '../models/kanji_search_result_model.dart';
import '../models/progress_summary_model.dart';
import '../../domain/usecases/create_kanji.dart';
import '../../domain/usecases/update_kanji.dart';
import '../../domain/entities/kanji_progress.dart';

abstract class KanjiRemoteDataSource {
  // Basic CRUD
  Future<List<KanjiModel>> getAllKanji();
  Future<KanjiModel> getKanjiById(int id);
  Future<KanjiModel> getKanjiByCharacter(String character);
  Future<KanjiModel> createKanji(CreateKanjiParams params);
  Future<KanjiModel> updateKanji(UpdateKanjiParams params);
  Future<KanjiModel> deleteKanji(int id);

  // Search & Filter
  Future<KanjiSearchResultModel> searchKanji({
    String? query,
    List<int>? jlptLevels,
    List<int>? grades,
    int? minStrokes,
    int? maxStrokes,
    String? radical,
    int? page,
    int? limit,
    String? sortBy,
  });

  // Kanji Detail & Examples
  Future<KanjiDetailModel> getKanjiDetail(String character);
  Future<List<KanjiExampleModel>> getKanjiExamples(
    String character, {
    int? limit,
  });

  // Kanji Lists
  Future<KanjiListModel> createList({
    required String name,
    String? description,
    bool? isPublic,
  });
  Future<List<KanjiListModel>> getUserLists();
  Future<KanjiListModel> getListDetail(int listId);
  Future<Map<String, dynamic>> addKanjiToList({
    required int listId,
    required List<String> kanjiCharacters,
    String? notes,
  });
  Future<void> removeKanjiFromList({required int listId, required int kanjiId});
  Future<void> deleteList(int listId);
  Future<void> reorderList({required int listId, required List<int> kanjiIds});

  // Progress Tracking
  Future<ProgressSummaryModel> getProgressSummary();
  Future<KanjiProgressModel?> getKanjiProgress(String character);
  Future<KanjiProgressModel> updateProgress({
    required String character,
    required ProgressStatus status,
  });
  Future<KanjiProgressModel> recordReview({
    required String character,
    required bool correct,
  });
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
      final response = await apiClient.delete('${ApiEndpoints.kanjiList}/$id');

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

  // ==================== Search & Filter ====================
  @override
  Future<KanjiSearchResultModel> searchKanji({
    String? query,
    List<int>? jlptLevels,
    List<int>? grades,
    int? minStrokes,
    int? maxStrokes,
    String? radical,
    int? page,
    int? limit,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query != null) queryParams['query'] = query;
      if (jlptLevels != null) queryParams['jlptLevels'] = jlptLevels.join(',');
      if (grades != null) queryParams['grades'] = grades.join(',');
      if (minStrokes != null) queryParams['minStrokes'] = minStrokes;
      if (maxStrokes != null) queryParams['maxStrokes'] = maxStrokes;
      if (radical != null) queryParams['radical'] = radical;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final response = await apiClient.get(
        '${ApiEndpoints.kanjiList}/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] ?? responseData;
        return KanjiSearchResultModel.fromJson(data);
      } else {
        throw ServerException('Failed to search kanji: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  // ==================== Kanji Detail & Examples ====================
  @override
  Future<KanjiDetailModel> getKanjiDetail(String character) async {
    try {
      final response = await apiClient.get(
        '${ApiEndpoints.kanjiList}/character/$character',
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] ?? responseData;
        return KanjiDetailModel.fromJson(data);
      } else {
        throw ServerException(
          'Failed to get kanji detail: ${response.statusCode}',
        );
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
  Future<List<KanjiExampleModel>> getKanjiExamples(
    String character, {
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.get(
        '${ApiEndpoints.kanjiList}/character/$character/examples',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        return data.map((e) => KanjiExampleModel.fromJson(e)).toList();
      } else {
        throw ServerException('Failed to get examples: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  // ==================== Kanji Lists ====================
  @override
  Future<KanjiListModel> createList({
    required String name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final response = await apiClient.post('${ApiEndpoints.kanjiList}/lists', {
        'name': name,
        if (description != null) 'description': description,
        if (isPublic != null) 'isPublic': isPublic,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] ?? responseData;
        return KanjiListModel.fromJson(data);
      } else {
        throw ServerException('Failed to create list: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<KanjiListModel>> getUserLists() async {
    try {
      final response = await apiClient.get('${ApiEndpoints.kanjiList}/lists');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        return data.map((e) => KanjiListModel.fromJson(e)).toList();
      } else {
        throw ServerException('Failed to get lists: ${response.statusCode}');
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
  Future<KanjiListModel> getListDetail(int listId) async {
    try {
      final response = await apiClient.get(
        '${ApiEndpoints.kanjiList}/lists/$listId',
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] ?? responseData;
        return KanjiListModel.fromJson(data);
      } else {
        throw ServerException(
          'Failed to get list detail: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException('List not found');
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> addKanjiToList({
    required int listId,
    required List<String> kanjiCharacters,
    String? notes,
  }) async {
    try {
      final response = await apiClient
          .post('${ApiEndpoints.kanjiList}/lists/add', {
            'listId': listId,
            'kanjiCharacters': kanjiCharacters,
            if (notes != null) 'notes': notes,
          });

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'Failed to add kanji to list: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> removeKanjiFromList({
    required int listId,
    required int kanjiId,
  }) async {
    try {
      final response = await apiClient.delete(
        '${ApiEndpoints.kanjiList}/lists/$listId/kanji/$kanjiId',
      );

      if (response.statusCode != 200) {
        throw ServerException('Failed to remove kanji: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> deleteList(int listId) async {
    try {
      final response = await apiClient.delete(
        '${ApiEndpoints.kanjiList}/lists/$listId',
      );

      if (response.statusCode != 200) {
        throw ServerException('Failed to delete list: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> reorderList({
    required int listId,
    required List<int> kanjiIds,
  }) async {
    try {
      final response = await apiClient.put(
        '${ApiEndpoints.kanjiList}/lists/$listId/reorder',
        {'kanjiIds': kanjiIds},
      );

      if (response.statusCode != 200) {
        throw ServerException('Failed to reorder list: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  // ==================== Progress Tracking ====================
  @override
  Future<ProgressSummaryModel> getProgressSummary() async {
    try {
      final response = await apiClient.get(
        '${ApiEndpoints.kanjiList}/progress',
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] ?? responseData;
        return ProgressSummaryModel.fromJson(data);
      } else {
        throw ServerException('Failed to get progress: ${response.statusCode}');
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
  Future<KanjiProgressModel?> getKanjiProgress(String character) async {
    try {
      final response = await apiClient.get(
        '${ApiEndpoints.kanjiList}/progress/$character',
      );

      if (response.statusCode == 200) {
        // Return null if progress doesn't exist yet
        if (response.data == null) return null;
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] ?? responseData;
        return KanjiProgressModel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // No progress yet for this kanji
      } else {
        throw ServerException('Failed to get progress: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<KanjiProgressModel> updateProgress({
    required String character,
    required ProgressStatus status,
  }) async {
    try {
      final response = await apiClient.put(
        '${ApiEndpoints.kanjiList}/progress',
        {'character': character, 'status': status.value},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] ?? responseData;
        return KanjiProgressModel.fromJson(data);
      } else {
        throw ServerException(
          'Failed to update progress: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<KanjiProgressModel> recordReview({
    required String character,
    required bool correct,
  }) async {
    try {
      final response = await apiClient.post(
        '${ApiEndpoints.kanjiList}/progress/review',
        {'character': character, 'correct': correct ? 1 : 0},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] ?? responseData;
        return KanjiProgressModel.fromJson(data);
      } else {
        throw ServerException(
          'Failed to record review: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
