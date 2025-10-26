import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_dashboard_repository.dart';
import 'admin_dashboard_event.dart';
import 'admin_dashboard_state.dart';

/// BLoC for admin dashboard operations
class AdminDashboardBloc
    extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final AdminDashboardRepository repository;

  AdminDashboardBloc({required this.repository})
    : super(const AdminDashboardInitial()) {
    on<LoadContentStats>(_onLoadContentStats);
    on<LoadActivityStats>(_onLoadActivityStats);
    on<LoadUsersChartData>(_onLoadUsersChartData);
    on<LoadActivityChartData>(_onLoadActivityChartData);
    on<ReviewPublishRequest>(_onReviewPublishRequest);
    on<LoadPublishStatistics>(_onLoadPublishStatistics);
    on<LoadSystemHealth>(_onLoadSystemHealth);
    on<LoadSystemMetrics>(_onLoadSystemMetrics);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadContentStats(
    LoadContentStats event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());

    final result = await repository.getContentStats();

    result.fold(
      (failure) => emit(AdminDashboardError(failure.message)),
      (stats) => emit(ContentStatsLoaded(stats)),
    );
  }

  Future<void> _onLoadActivityStats(
    LoadActivityStats event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());

    final result = await repository.getActivityStats();

    result.fold(
      (failure) => emit(AdminDashboardError(failure.message)),
      (stats) => emit(ActivityStatsLoaded(stats)),
    );
  }

  Future<void> _onLoadUsersChartData(
    LoadUsersChartData event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());

    final result = await repository.getUsersChartData();

    result.fold(
      (failure) => emit(AdminDashboardError(failure.message)),
      (chartData) => emit(UsersChartDataLoaded(chartData)),
    );
  }

  Future<void> _onLoadActivityChartData(
    LoadActivityChartData event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());

    final result = await repository.getActivityChartData();

    result.fold(
      (failure) => emit(AdminDashboardError(failure.message)),
      (chartData) => emit(ActivityChartDataLoaded(chartData)),
    );
  }

  Future<void> _onReviewPublishRequest(
    ReviewPublishRequest event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());

    final result = await repository.reviewPublishRequest(
      event.requestId,
      event.dto,
    );

    result.fold(
      (failure) => emit(AdminDashboardError(failure.message)),
      (_) => emit(
        PublishRequestReviewed(
          requestId: event.requestId,
          message: 'Publish request reviewed successfully',
        ),
      ),
    );
  }

  Future<void> _onLoadPublishStatistics(
    LoadPublishStatistics event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());

    final result = await repository.getPublishStatistics();

    result.fold(
      (failure) => emit(AdminDashboardError(failure.message)),
      (statistics) => emit(PublishStatisticsLoaded(statistics)),
    );
  }

  Future<void> _onLoadSystemHealth(
    LoadSystemHealth event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());

    final result = await repository.getSystemHealth();

    result.fold(
      (failure) => emit(AdminDashboardError(failure.message)),
      (health) => emit(SystemHealthLoaded(health)),
    );
  }

  Future<void> _onLoadSystemMetrics(
    LoadSystemMetrics event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());

    final result = await repository.getSystemMetrics();

    result.fold(
      (failure) => emit(AdminDashboardError(failure.message)),
      (metrics) => emit(SystemMetricsLoaded(metrics)),
    );
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());

    // Load all data in parallel
    final results = await Future.wait([
      repository.getContentStats(),
      repository.getActivityStats(),
      repository.getUsersChartData(),
      repository.getActivityChartData(),
      repository.getPublishStatistics(),
      repository.getSystemHealth(),
      repository.getSystemMetrics(),
    ]);

    // Check if any failed
    bool hasError = false;
    String errorMessage = '';

    for (var result in results) {
      result.fold((failure) {
        hasError = true;
        errorMessage = failure.message;
      }, (_) {});
    }

    if (hasError) {
      emit(AdminDashboardError(errorMessage));
      return;
    }

    // Extract all data
    emit(
      DashboardDataLoaded(
        contentStats: results[0].fold((_) => null, (stats) => stats),
        activityStats: results[1].fold((_) => null, (stats) => stats),
        usersChartData: results[2].fold((_) => null, (data) => data),
        activityChartData: results[3].fold((_) => null, (data) => data),
        publishStatistics: results[4].fold((_) => null, (stats) => stats),
        systemHealth: results[5].fold((_) => null, (health) => health),
        systemMetrics: results[6].fold((_) => null, (metrics) => metrics),
      ),
    );
  }
}
