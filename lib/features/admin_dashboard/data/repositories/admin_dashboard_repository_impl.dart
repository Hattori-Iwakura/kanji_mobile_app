import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/content_stats.dart';
import '../../domain/entities/activity_stats.dart';
import '../../domain/entities/chart_data.dart';
import '../../domain/entities/publish_statistics.dart';
import '../../domain/entities/system_health.dart';
import '../../domain/entities/system_metrics.dart';
import '../../domain/entities/review_publish_request_dto.dart';
import '../../domain/repositories/admin_dashboard_repository.dart';
import '../datasources/admin_dashboard_remote_datasource.dart';

/// Implementation of AdminDashboardRepository
class AdminDashboardRepositoryImpl implements AdminDashboardRepository {
  final AdminDashboardRemoteDataSource remoteDataSource;

  AdminDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ContentStats>> getContentStats() async {
    try {
      final result = await remoteDataSource.getContentStats();
      return Right(result);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(ServerFailure('Request timeout. Please try again.'));
      } else if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Unauthorized. Please login again.'));
      } else if (e.response?.statusCode == 403) {
        return Left(AuthFailure('Forbidden. Admin access required.'));
      } else if (e.response?.statusCode == 500) {
        return Left(ServerFailure('Server error. Please try again later.'));
      } else {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to get content stats',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ActivityStats>> getActivityStats() async {
    try {
      final result = await remoteDataSource.getActivityStats();
      return Right(result);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(ServerFailure('Request timeout. Please try again.'));
      } else if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Unauthorized. Please login again.'));
      } else if (e.response?.statusCode == 403) {
        return Left(AuthFailure('Forbidden. Admin access required.'));
      } else if (e.response?.statusCode == 500) {
        return Left(ServerFailure('Server error. Please try again later.'));
      } else {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to get activity stats',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ChartData>> getUsersChartData() async {
    try {
      final result = await remoteDataSource.getUsersChartData();
      return Right(result);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(ServerFailure('Request timeout. Please try again.'));
      } else if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Unauthorized. Please login again.'));
      } else if (e.response?.statusCode == 403) {
        return Left(AuthFailure('Forbidden. Admin access required.'));
      } else if (e.response?.statusCode == 500) {
        return Left(ServerFailure('Server error. Please try again later.'));
      } else {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to get users chart data',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ChartData>> getActivityChartData() async {
    try {
      final result = await remoteDataSource.getActivityChartData();
      return Right(result);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(ServerFailure('Request timeout. Please try again.'));
      } else if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Unauthorized. Please login again.'));
      } else if (e.response?.statusCode == 403) {
        return Left(AuthFailure('Forbidden. Admin access required.'));
      } else if (e.response?.statusCode == 500) {
        return Left(ServerFailure('Server error. Please try again later.'));
      } else {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to get activity chart data',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> reviewPublishRequest(
    int requestId,
    ReviewPublishRequestDto dto,
  ) async {
    try {
      await remoteDataSource.reviewPublishRequest(requestId, dto);
      return const Right(null);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(ServerFailure('Request timeout. Please try again.'));
      } else if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Unauthorized. Please login again.'));
      } else if (e.response?.statusCode == 403) {
        return Left(AuthFailure('Forbidden. Admin access required.'));
      } else if (e.response?.statusCode == 404) {
        return Left(ServerFailure('Publish request not found.'));
      } else if (e.response?.statusCode == 500) {
        return Left(ServerFailure('Server error. Please try again later.'));
      } else {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to review publish request',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PublishStatistics>> getPublishStatistics() async {
    try {
      final result = await remoteDataSource.getPublishStatistics();
      return Right(result);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(ServerFailure('Request timeout. Please try again.'));
      } else if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Unauthorized. Please login again.'));
      } else if (e.response?.statusCode == 403) {
        return Left(AuthFailure('Forbidden. Admin access required.'));
      } else if (e.response?.statusCode == 500) {
        return Left(ServerFailure('Server error. Please try again later.'));
      } else {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to get publish statistics',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SystemHealth>> getSystemHealth() async {
    try {
      final result = await remoteDataSource.getSystemHealth();
      return Right(result);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(ServerFailure('Request timeout. Please try again.'));
      } else if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Unauthorized. Please login again.'));
      } else if (e.response?.statusCode == 403) {
        return Left(AuthFailure('Forbidden. Admin access required.'));
      } else if (e.response?.statusCode == 500) {
        return Left(ServerFailure('Server error. Please try again later.'));
      } else {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to get system health',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SystemMetrics>> getSystemMetrics() async {
    try {
      final result = await remoteDataSource.getSystemMetrics();
      return Right(result);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(ServerFailure('Request timeout. Please try again.'));
      } else if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Unauthorized. Please login again.'));
      } else if (e.response?.statusCode == 403) {
        return Left(AuthFailure('Forbidden. Admin access required.'));
      } else if (e.response?.statusCode == 500) {
        return Left(ServerFailure('Server error. Please try again later.'));
      } else {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to get system metrics',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
