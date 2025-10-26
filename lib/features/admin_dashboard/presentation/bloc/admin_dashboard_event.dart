import 'package:equatable/equatable.dart';
import '../../domain/entities/review_publish_request_dto.dart';

/// Base class for all admin dashboard events
abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load content statistics
class LoadContentStats extends AdminDashboardEvent {
  const LoadContentStats();
}

/// Event to load activity statistics
class LoadActivityStats extends AdminDashboardEvent {
  const LoadActivityStats();
}

/// Event to load users chart data
class LoadUsersChartData extends AdminDashboardEvent {
  const LoadUsersChartData();
}

/// Event to load activity chart data
class LoadActivityChartData extends AdminDashboardEvent {
  const LoadActivityChartData();
}

/// Event to review a publish request
class ReviewPublishRequest extends AdminDashboardEvent {
  final int requestId;
  final ReviewPublishRequestDto dto;

  const ReviewPublishRequest({required this.requestId, required this.dto});

  @override
  List<Object?> get props => [requestId, dto];
}

/// Event to load publish statistics
class LoadPublishStatistics extends AdminDashboardEvent {
  const LoadPublishStatistics();
}

/// Event to load system health
class LoadSystemHealth extends AdminDashboardEvent {
  const LoadSystemHealth();
}

/// Event to load system metrics
class LoadSystemMetrics extends AdminDashboardEvent {
  const LoadSystemMetrics();
}

/// Event to refresh all dashboard data
class RefreshDashboard extends AdminDashboardEvent {
  const RefreshDashboard();
}
