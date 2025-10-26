import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/content_stats_model.dart';
import '../models/activity_stats_model.dart';
import '../models/chart_data_model.dart';
import '../models/publish_statistics_model.dart';
import '../models/system_health_model.dart';
import '../models/system_metrics_model.dart';
import '../../domain/entities/review_publish_request_dto.dart';

/// Remote data source for admin dashboard operations
abstract class AdminDashboardRemoteDataSource {
  Future<ContentStatsModel> getContentStats();
  Future<ActivityStatsModel> getActivityStats();
  Future<ChartDataModel> getUsersChartData();
  Future<ChartDataModel> getActivityChartData();
  Future<void> reviewPublishRequest(int requestId, ReviewPublishRequestDto dto);
  Future<PublishStatisticsModel> getPublishStatistics();
  Future<SystemHealthModel> getSystemHealth();
  Future<SystemMetricsModel> getSystemMetrics();
}

/// Implementation of AdminDashboardRemoteDataSource
class AdminDashboardRemoteDataSourceImpl
    implements AdminDashboardRemoteDataSource {
  final DioClient dioClient;

  AdminDashboardRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<ContentStatsModel> getContentStats() async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.adminDashboardContentStats,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ContentStatsModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get content stats',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ActivityStatsModel> getActivityStats() async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.adminDashboardActivityStats,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ActivityStatsModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get activity stats',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ChartDataModel> getUsersChartData() async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.adminDashboardUsersChart,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return ChartDataModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get users chart data',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ChartDataModel> getActivityChartData() async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.adminDashboardActivityChart,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return ChartDataModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get activity chart data',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> reviewPublishRequest(
    int requestId,
    ReviewPublishRequestDto dto,
  ) async {
    try {
      final response = await dioClient.patch(
        ApiEndpoints.adminPublishRequestReview(requestId),
        data: dto.toJson(),
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to review publish request',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PublishStatisticsModel> getPublishStatistics() async {
    try {
      final response = await dioClient.get(ApiEndpoints.adminPublishStatistics);

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return PublishStatisticsModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get publish statistics',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SystemHealthModel> getSystemHealth() async {
    try {
      final response = await dioClient.get(ApiEndpoints.adminSystemHealth);

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SystemHealthModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get system health',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SystemMetricsModel> getSystemMetrics() async {
    try {
      final response = await dioClient.get(ApiEndpoints.adminSystemMetrics);

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SystemMetricsModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to get system metrics',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
