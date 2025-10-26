import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../admin_dashboard/presentation/bloc/admin_dashboard_bloc.dart';
import '../../../admin_dashboard/presentation/bloc/admin_dashboard_event.dart';
import '../../../admin_dashboard/presentation/bloc/admin_dashboard_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Admin Dashboard Page with real data from backend
class AdminDashboardPageReal extends StatelessWidget {
  const AdminDashboardPageReal({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return _buildUnauthorized();
        }

        if (authState.user.role != 'ADMIN') {
          return _buildUnauthorized();
        }

        return BlocProvider(
          create: (context) => getIt<AdminDashboardBloc>()
            ..add(const LoadContentStats())
            ..add(const LoadActivityStats())
            ..add(const LoadUsersChartData())
            ..add(const LoadPublishStatistics())
            ..add(const LoadSystemHealth()),
          child: const _DashboardContent(),
        );
      },
    );
  }

  Widget _buildUnauthorized() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 100,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Access Denied',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Admin privileges required',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<AdminDashboardBloc>()
                ..add(const LoadContentStats())
                ..add(const LoadActivityStats())
                ..add(const LoadUsersChartData())
                ..add(const LoadPublishStatistics())
                ..add(const LoadSystemHealth());
            },
          ),
        ],
      ),
      body: BlocListener<AdminDashboardBloc, AdminDashboardState>(
        listener: (context, state) {
          if (state is AdminDashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<AdminDashboardBloc>()
              ..add(const LoadContentStats())
              ..add(const LoadActivityStats())
              ..add(const LoadUsersChartData())
              ..add(const LoadPublishStatistics())
              ..add(const LoadSystemHealth());
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Content Statistics
              const _ContentStatsSection(),

              const SizedBox(height: 24),

              // Activity Statistics
              const _ActivityStatsSection(),

              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(context),

              const SizedBox(height: 24),

              // User Growth Chart
              const _UserGrowthChartSection(),

              const SizedBox(height: 24),

              // Publish Statistics
              const _PublishStatisticsSection(),

              const SizedBox(height: 24),

              // System Health
              const _SystemHealthSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionButton(
              context: context,
              icon: Icons.people,
              title: 'Users',
              color: Colors.blue,
              onTap: () => context.go(AppRouter.userManagement),
            ),
            _buildActionButton(
              context: context,
              icon: Icons.auto_stories,
              title: 'Kanji',
              color: Colors.green,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kanji management coming soon')),
                );
              },
            ),
            _buildActionButton(
              context: context,
              icon: Icons.analytics,
              title: 'Analytics',
              color: Colors.orange,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analytics coming soon')),
                );
              },
            ),
            _buildActionButton(
              context: context,
              icon: Icons.settings,
              title: 'Settings',
              color: Colors.purple,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Content Statistics Section
class _ContentStatsSection extends StatelessWidget {
  const _ContentStatsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTENT STATISTICS',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
          buildWhen: (previous, current) =>
              current is ContentStatsLoaded ||
              current is AdminDashboardLoading ||
              current is AdminDashboardError,
          builder: (context, state) {
            if (state is AdminDashboardLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              );
            }

            if (state is ContentStatsLoaded) {
              final stats = state.stats;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.auto_stories,
                          title: 'Total Kanji',
                          value: stats.totalKanji.toString(),
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.list,
                          title: 'Kanji Lists',
                          value: stats.totalKanjiLists.toString(),
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.style,
                          title: 'Flashcard Decks',
                          value: stats.totalFlashcardDecks.toString(),
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.quiz,
                          title: 'Quizzes',
                          value: stats.totalQuizzes.toString(),
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.people,
                          title: 'Total Users',
                          value: stats.totalUsers.toString(),
                          color: Colors.cyan,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.person_outline,
                          title: 'Active Users',
                          value: stats.activeUsers.toString(),
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

/// Activity Statistics Section
class _ActivityStatsSection extends StatelessWidget {
  const _ActivityStatsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIVITY STATISTICS',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
          buildWhen: (previous, current) =>
              current is ActivityStatsLoaded ||
              current is AdminDashboardLoading ||
              current is AdminDashboardError,
          builder: (context, state) {
            if (state is AdminDashboardLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              );
            }

            if (state is ActivityStatsLoaded) {
              final stats = state.stats;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.style,
                          title: 'Flashcard Sessions',
                          value: stats.totalFlashcardSessions.toString(),
                          subtitle: 'Today: ${stats.todayFlashcardSessions}',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.quiz,
                          title: 'Quiz Attempts',
                          value: stats.totalQuizAttempts.toString(),
                          subtitle: 'Today: ${stats.todayQuizAttempts}',
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    icon: Icons.rate_review,
                    title: 'Total Reviews',
                    value: stats.totalReviews.toString(),
                    subtitle: 'Today: ${stats.todayReviews}',
                    color: Colors.pink,
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

/// User Growth Chart Section
class _UserGrowthChartSection extends StatelessWidget {
  const _UserGrowthChartSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'USER GROWTH',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
          buildWhen: (previous, current) =>
              current is UsersChartDataLoaded ||
              current is AdminDashboardLoading ||
              current is AdminDashboardError,
          builder: (context, state) {
            if (state is AdminDashboardLoading) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              );
            }

            if (state is UsersChartDataLoaded) {
              final chartData = state.chartData;
              return Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: chartData.dataPoints.isEmpty
                    ? Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.white.withOpacity(0.1),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >=
                                      chartData.dataPoints.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final date =
                                      chartData.dataPoints[value.toInt()].date;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      date.split('-').last, // Show day only
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: chartData.dataPoints
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => FlSpot(
                                      entry.key.toDouble(),
                                      entry.value.count.toDouble(),
                                    ),
                                  )
                                  .toList(),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

/// Publish Statistics Section
class _PublishStatisticsSection extends StatelessWidget {
  const _PublishStatisticsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PUBLISH REQUESTS',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
          buildWhen: (previous, current) =>
              current is PublishStatisticsLoaded ||
              current is AdminDashboardLoading ||
              current is AdminDashboardError,
          builder: (context, state) {
            if (state is AdminDashboardLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: Colors.amber),
                ),
              );
            }

            if (state is PublishStatisticsLoaded) {
              final stats = state.statistics;
              return Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.pending,
                      title: 'Pending',
                      value: stats.pendingRequests.toString(),
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle,
                      title: 'Approved',
                      value: stats.approvedRequests.toString(),
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.cancel,
                      title: 'Rejected',
                      value: stats.rejectedRequests.toString(),
                      color: Colors.red,
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

/// System Health Section
class _SystemHealthSection extends StatelessWidget {
  const _SystemHealthSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SYSTEM HEALTH',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
          buildWhen: (previous, current) =>
              current is SystemHealthLoaded ||
              current is AdminDashboardLoading ||
              current is AdminDashboardError,
          builder: (context, state) {
            if (state is AdminDashboardLoading) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              );
            }

            if (state is SystemHealthLoaded) {
              final health = state.health;
              final isHealthy = health.status.toLowerCase() == 'healthy';
              final statusColor = isHealthy ? Colors.green : Colors.red;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          isHealthy ? Icons.check_circle : Icons.error,
                          color: statusColor,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'System Status',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              health.status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Uptime',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatUptime(health.uptime),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _HealthIndicator(
                            label: 'Database',
                            status: health.database.status,
                            isHealthy: health.database.isConnected,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _HealthIndicator(
                            label: 'Memory',
                            status: _formatBytes(health.memory.heapUsed),
                            isHealthy: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  String _formatUptime(int seconds) {
    final duration = Duration(seconds: seconds);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatBytes(int bytes) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }
}

class _HealthIndicator extends StatelessWidget {
  final String label;
  final String status;
  final bool isHealthy;

  const _HealthIndicator({
    required this.label,
    required this.status,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isHealthy ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          status,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Reusable Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
