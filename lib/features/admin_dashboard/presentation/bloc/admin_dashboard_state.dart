import 'package:equatable/equatable.dart';
import '../../domain/entities/content_stats.dart';
import '../../domain/entities/activity_stats.dart';
import '../../domain/entities/chart_data.dart';
import '../../domain/entities/publish_statistics.dart';
import '../../domain/entities/system_health.dart';
import '../../domain/entities/system_metrics.dart';

/// Base class for all admin dashboard states
abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AdminDashboardInitial extends AdminDashboardState {
  const AdminDashboardInitial();
}

/// Loading state
class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading();
}

/// Content stats loaded state
class ContentStatsLoaded extends AdminDashboardState {
  final ContentStats stats;

  const ContentStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Activity stats loaded state
class ActivityStatsLoaded extends AdminDashboardState {
  final ActivityStats stats;

  const ActivityStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Users chart data loaded state
class UsersChartDataLoaded extends AdminDashboardState {
  final ChartData chartData;

  const UsersChartDataLoaded(this.chartData);

  @override
  List<Object?> get props => [chartData];
}

/// Activity chart data loaded state
class ActivityChartDataLoaded extends AdminDashboardState {
  final ChartData chartData;

  const ActivityChartDataLoaded(this.chartData);

  @override
  List<Object?> get props => [chartData];
}

/// Publish request reviewed state
class PublishRequestReviewed extends AdminDashboardState {
  final int requestId;
  final String message;

  const PublishRequestReviewed({
    required this.requestId,
    required this.message,
  });

  @override
  List<Object?> get props => [requestId, message];
}

/// Publish statistics loaded state
class PublishStatisticsLoaded extends AdminDashboardState {
  final PublishStatistics statistics;

  const PublishStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

/// System health loaded state
class SystemHealthLoaded extends AdminDashboardState {
  final SystemHealth health;

  const SystemHealthLoaded(this.health);

  @override
  List<Object?> get props => [health];
}

/// System metrics loaded state
class SystemMetricsLoaded extends AdminDashboardState {
  final SystemMetrics metrics;

  const SystemMetricsLoaded(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

/// All dashboard data loaded state (for refresh)
class DashboardDataLoaded extends AdminDashboardState {
  final ContentStats? contentStats;
  final ActivityStats? activityStats;
  final ChartData? usersChartData;
  final ChartData? activityChartData;
  final PublishStatistics? publishStatistics;
  final SystemHealth? systemHealth;
  final SystemMetrics? systemMetrics;

  const DashboardDataLoaded({
    this.contentStats,
    this.activityStats,
    this.usersChartData,
    this.activityChartData,
    this.publishStatistics,
    this.systemHealth,
    this.systemMetrics,
  });

  @override
  List<Object?> get props => [
    contentStats,
    activityStats,
    usersChartData,
    activityChartData,
    publishStatistics,
    systemHealth,
    systemMetrics,
  ];
}

/// Error state
class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
