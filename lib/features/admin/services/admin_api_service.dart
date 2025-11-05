import 'package:kanji_mobile_app/features/admin/models/admin_models.dart';
import 'package:kanji_mobile_app/features/admin/models/user_management_models.dart';
import 'package:kanji_mobile_app/core/network/api_client.dart';
import 'package:dio/dio.dart';

class AdminApiService {
  final ApiClient _apiClient;

  AdminApiService(this._apiClient);

  // ==================== DASHBOARD ====================

  Future<DashboardOverview> getDashboardOverview() async {
    try {
      final response = await _apiClient.dio.get('/admin/dashboard/overview');
      return DashboardOverview.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Admin access required');
      }
      throw Exception('Failed to load dashboard: ${e.message}');
    }
  }

  Future<PublishStatistics> getPublishStatistics() async {
    try {
      final response = await _apiClient.dio.get('/admin/publish/statistics');
      return PublishStatistics.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to load statistics: ${e.message}');
    }
  }

  Future<SystemHealth> getSystemHealth() async {
    try {
      final response = await _apiClient.dio.get('/admin/system/health');
      return SystemHealth.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to load system health: ${e.message}');
    }
  }

  // ==================== PUBLISH REQUESTS ====================

  Future<PublishRequestsResponse> getPublishRequests({
    String? status,
    String? type,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit, 'offset': offset};

      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;

      final response = await _apiClient.dio.get(
        '/admin/publish/requests',
        queryParameters: queryParams,
      );

      return PublishRequestsResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to load publish requests: ${e.message}');
    }
  }

  Future<PublishRequest> getPublishRequestById(int id, String type) async {
    try {
      final response = await _apiClient.dio.get(
        '/admin/publish/requests/$id',
        queryParameters: {'type': type},
      );

      return PublishRequest.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Publish request not found');
      }
      throw Exception('Failed to load publish request: ${e.message}');
    }
  }

  Future<PublishRequest> reviewPublishRequest({
    required int id,
    required String type,
    required String status,
    String? reviewMessage,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        '/admin/publish/requests/$id/review',
        queryParameters: {'type': type},
        data: {
          'status': status,
          if (reviewMessage != null) 'reviewMessage': reviewMessage,
        },
      );

      return PublishRequest.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Publish request not found');
      }
      throw Exception('Failed to review request: ${e.message}');
    }
  }

  // Statistics endpoints
  Future<UserStatistics> getUserStatistics({String? period}) async {
    try {
      final queryParams = period != null ? {'period': period} : null;
      final response = await _apiClient.dio.get(
        '/admin/dashboard/stats/users',
        queryParameters: queryParams,
      );
      return UserStatistics.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to get user statistics: ${e.message}');
    }
  }

  Future<ContentStatistics> getContentStatistics({String? period}) async {
    try {
      final queryParams = period != null ? {'period': period} : null;
      final response = await _apiClient.dio.get(
        '/admin/dashboard/stats/content',
        queryParameters: queryParams,
      );
      return ContentStatistics.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to get content statistics: ${e.message}');
    }
  }

  Future<ActivityStatistics> getActivityStatistics({
    String? period,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (period != null) queryParams['period'] = period;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.dio.get(
        '/admin/dashboard/stats/activity',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return ActivityStatistics.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to get activity statistics: ${e.message}');
    }
  }

  // Chart endpoints
  Future<ChartData> getUserChartData({String? period}) async {
    try {
      final queryParams = period != null ? {'period': period} : null;
      final response = await _apiClient.dio.get(
        '/admin/dashboard/charts/users',
        queryParameters: queryParams,
      );
      return ChartData.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to get user chart data: ${e.message}');
    }
  }

  Future<ChartData> getActivityChartData({String? period}) async {
    try {
      final queryParams = period != null ? {'period': period} : null;
      final response = await _apiClient.dio.get(
        '/admin/dashboard/charts/activity',
        queryParameters: queryParams,
      );
      return ChartData.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to get activity chart data: ${e.message}');
    }
  }

  // System endpoints
  Future<SystemMetrics> getSystemMetrics({String? period}) async {
    try {
      final queryParams = period != null ? {'period': period} : null;
      final response = await _apiClient.dio.get(
        '/admin/system/metrics',
        queryParameters: queryParams,
      );
      return SystemMetrics.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to get system metrics: ${e.message}');
    }
  }

  // ==================== USER MANAGEMENT ====================

  Future<UserListResponse> getAllUsers() async {
    try {
      final response = await _apiClient.dio.get('/admin/users');

      // API returns array directly
      final data = response.data;

      if (data is List) {
        // Direct array response
        final usersList = data
            .where((u) => u is Map<String, dynamic>)
            .map((u) => UserInfo.fromJson(u as Map<String, dynamic>))
            .toList();

        return UserListResponse(users: usersList, total: usersList.length);
      } else if (data is Map<String, dynamic>) {
        // Wrapped response with 'data' field
        final usersData = data['data'];

        if (usersData is List) {
          final usersList = usersData
              .where((u) => u is Map<String, dynamic>)
              .map((u) => UserInfo.fromJson(u as Map<String, dynamic>))
              .toList();

          return UserListResponse(
            users: usersList,
            total: data['total'] ?? usersList.length,
          );
        } else if (usersData is Map<String, dynamic>) {
          return UserListResponse.fromJson(usersData);
        }
      }

      // Fallback for unexpected format
      return UserListResponse(users: [], total: 0);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Admin access required');
      }
      throw Exception('Failed to load users: ${e.message}');
    }
  }

  Future<UserInfo> getUserById(int id) async {
    try {
      final response = await _apiClient.dio.get('/admin/users/$id');
      return UserInfo.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      }
      throw Exception('Failed to load user: ${e.message}');
    }
  }

  Future<UserInfo> updateUser(int id, UpdateUserRequest request) async {
    try {
      final response = await _apiClient.dio.patch(
        '/admin/users/$id',
        data: request.toJson(),
      );
      return UserInfo.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      }
      if (e.response?.statusCode == 409) {
        throw Exception('Email already exists');
      }
      throw Exception('Failed to update user: ${e.message}');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _apiClient.dio.delete('/admin/users/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      }
      throw Exception('Failed to delete user: ${e.message}');
    }
  }
}
