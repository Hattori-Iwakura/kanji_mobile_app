import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/content_stats.dart';
import '../entities/activity_stats.dart';
import '../entities/chart_data.dart';
import '../entities/publish_statistics.dart';
import '../entities/system_health.dart';
import '../entities/system_metrics.dart';
import '../entities/review_publish_request_dto.dart';

/// Repository interface for admin dashboard operations
abstract class AdminDashboardRepository {
  /// Get content statistics (kanji, lists, decks, quizzes, users)
  Future<Either<Failure, ContentStats>> getContentStats();

  /// Get activity statistics (sessions, attempts, reviews)
  Future<Either<Failure, ActivityStats>> getActivityStats();

  /// Get user growth chart data
  Future<Either<Failure, ChartData>> getUsersChartData();

  /// Get activity trend chart data
  Future<Either<Failure, ChartData>> getActivityChartData();

  /// Review a publish request (approve or reject)
  Future<Either<Failure, void>> reviewPublishRequest(
    int requestId,
    ReviewPublishRequestDto dto,
  );

  /// Get publish request statistics
  Future<Either<Failure, PublishStatistics>> getPublishStatistics();

  /// Get system health status
  Future<Either<Failure, SystemHealth>> getSystemHealth();

  /// Get system performance metrics
  Future<Either<Failure, SystemMetrics>> getSystemMetrics();
}
