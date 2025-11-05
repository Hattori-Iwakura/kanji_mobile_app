import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kanji_mobile_app/core/network/api_client.dart';
import 'package:kanji_mobile_app/features/admin/services/admin_api_service.dart';
import 'package:kanji_mobile_app/features/admin/models/admin_models.dart';
import 'package:kanji_mobile_app/features/admin/presentation/pages/admin_publish_requests_page.dart';
import 'package:kanji_mobile_app/features/admin/presentation/pages/admin_user_management_page.dart';

class AdminDashboardPage extends StatefulWidget {
  final ApiClient apiClient;

  const AdminDashboardPage({super.key, required this.apiClient});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late final AdminApiService _adminApiService;
  bool _isLoading = true;
  String? _error;
  String _selectedPeriod = 'week'; // week, month, year

  DashboardOverview? _overview;
  PublishStatistics? _publishStats;
  SystemHealth? _systemHealth;
  UserStatistics? _userStats;
  ContentStatistics? _contentStats;
  ActivityStatistics? _activityStats;
  ChartData? _userChartData;
  ChartData? _activityChartData;
  SystemMetrics? _systemMetrics;

  @override
  void initState() {
    super.initState();
    _adminApiService = AdminApiService(widget.apiClient);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _adminApiService.getDashboardOverview(),
        _adminApiService.getPublishStatistics(),
        _adminApiService.getSystemHealth(),
        _adminApiService.getUserStatistics(period: _selectedPeriod),
        _adminApiService.getContentStatistics(period: _selectedPeriod),
        _adminApiService.getActivityStatistics(
          period: _selectedPeriod,
          limit: 10,
        ),
        _adminApiService.getUserChartData(period: _selectedPeriod),
        _adminApiService.getActivityChartData(period: _selectedPeriod),
        _adminApiService.getSystemMetrics(period: _selectedPeriod),
      ]);

      setState(() {
        _overview = results[0] as DashboardOverview;
        _publishStats = results[1] as PublishStatistics;
        _systemHealth = results[2] as SystemHealth;
        _userStats = results[3] as UserStatistics;
        _contentStats = results[4] as ContentStatistics;
        _activityStats = results[5] as ActivityStatistics;
        _userChartData = results[6] as ChartData;
        _activityChartData = results[7] as ChartData;
        _systemMetrics = results[8] as SystemMetrics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF071126), Color(0xFF0B0F14)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _error != null
                    ? _buildErrorState()
                    : _buildDashboardContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'System Management',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.tealAccent),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.tealAccent),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
          const SizedBox(height: 16),
          Text(
            'Error Loading Dashboard',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      color: Colors.tealAccent,
      backgroundColor: const Color(0xFF1A1F2E),
      onRefresh: _loadDashboardData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 16),
          _buildSystemHealthCard(),
          const SizedBox(height: 16),
          _buildSystemMetricsCard(),
          const SizedBox(height: 16),
          _buildStatsGrid(),
          const SizedBox(height: 16),
          _buildDetailedStatsSection(),
          const SizedBox(height: 16),
          _buildChartsSection(),
          const SizedBox(height: 16),
          _buildRecentActivitiesCard(),
          const SizedBox(height: 16),
          _buildPublishRequestsCard(),
          const SizedBox(height: 16),
          _buildUserManagementCard(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildPeriodButton('Today', 'day'),
          _buildPeriodButton('Week', 'week'),
          _buildPeriodButton('Month', 'month'),
          _buildPeriodButton('Year', 'year'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
          _loadDashboardData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)],
                  )
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemHealthCard() {
    final isHealthy = _systemHealth?.isHealthy ?? false;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHealthy
              ? [const Color(0xFF00BFA5), const Color(0xFF1DE9B6)]
              : [Colors.redAccent, Colors.red.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isHealthy ? Colors.tealAccent : Colors.redAccent)
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            isHealthy ? Icons.check_circle : Icons.error,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHealthy ? 'System Healthy' : 'System Issues',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Database: ${_systemHealth?.database ?? 'Unknown'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Overview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard(
              icon: Icons.people,
              title: 'Total Users',
              value: _overview?.users.total.toString() ?? '0',
              subtitle: '${_overview?.users.active ?? 0} active',
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
            ),
            _buildStatCard(
              icon: Icons.library_books,
              title: 'Content',
              value:
                  ((_overview?.content.quizzes ?? 0) +
                          (_overview?.content.lists ?? 0) +
                          (_overview?.content.decks ?? 0))
                      .toString(),
              subtitle:
                  'Q:${_overview?.content.quizzes ?? 0} L:${_overview?.content.lists ?? 0} D:${_overview?.content.decks ?? 0}',
              gradient: const LinearGradient(
                colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)],
              ),
            ),
            _buildStatCard(
              icon: Icons.trending_up,
              title: 'New Users',
              value: _overview?.users.newUsers.toString() ?? '0',
              subtitle: 'This week',
              gradient: const LinearGradient(
                colors: [Color(0xFFFA8BFF), Color(0xFF2BD2FF)],
              ),
            ),
            _buildStatCard(
              icon: Icons.pending_actions,
              title: 'Pending',
              value:
                  _overview?.activity.pendingPublishRequests.toString() ?? '0',
              subtitle: 'Publish requests',
              gradient: const LinearGradient(
                colors: [Color(0xFFFFBE0B), Color(0xFFFB5607)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPublishRequestsCard() {
    final pending = _publishStats?.pending ?? 0;
    final total = _publishStats?.total ?? 0;
    final approved = _publishStats?.approved ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.publish, color: Colors.tealAccent, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Publish Requests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (pending > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFBE0B), Color(0xFFFB5607)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$pending pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF2A2F3E), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPublishStat('Total', total, Colors.blueAccent),
                    _buildPublishStat('Approved', approved, Colors.tealAccent),
                    _buildPublishStat('Pending', pending, Colors.orangeAccent),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildTypeChip(
                      'Quiz',
                      _publishStats?.byType.quiz.pending ?? 0,
                    ),
                    const SizedBox(width: 8),
                    _buildTypeChip(
                      'List',
                      _publishStats?.byType.list.pending ?? 0,
                    ),
                    const SizedBox(width: 8),
                    _buildTypeChip(
                      'Deck',
                      _publishStats?.byType.deck.pending ?? 0,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AdminPublishRequestsPage(
                            apiClient: widget.apiClient,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Manage Requests'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.tealAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Colors.tealAccent,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type, int count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1419),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              type,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.tealAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserManagementCard() {
    final totalUsers = _userStats?.totalUsers ?? 0;
    final activeUsers = _userStats?.activeUsers ?? 0;
    final newUsers = _userStats?.newUsers ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.tealAccent, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'User Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalUsers users',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF2A2F3E), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildUserStat('Total', totalUsers, Colors.blueAccent),
                    _buildUserStat('Active', activeUsers, Colors.tealAccent),
                    _buildUserStat('New', newUsers, Colors.purpleAccent),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AdminUserManagementPage(
                            apiClient: widget.apiClient,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.manage_accounts),
                    label: const Text('Manage Users'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSystemMetricsCard() {
    if (_systemMetrics == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.speed, color: Colors.tealAccent, size: 24),
              SizedBox(width: 12),
              Text(
                'System Metrics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    SizedBox(
                      height: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPieMetric(
                            'CPU',
                            _systemMetrics!.performance.cpu,
                            Colors.blueAccent,
                            Icons.memory,
                          ),
                          _buildPieMetric(
                            'Memory',
                            _systemMetrics!.memory.percentage,
                            Colors.orangeAccent,
                            Icons.storage,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildMetricStat(
                      'DB Connections',
                      _systemMetrics!.database.connections.toString(),
                      Icons.cable,
                      Colors.purpleAccent,
                    ),
                    const SizedBox(height: 12),
                    _buildMetricStat(
                      'Query Time',
                      '${_systemMetrics!.database.queryTime.toStringAsFixed(0)}ms',
                      Icons.query_stats,
                      Colors.tealAccent,
                    ),
                    const SizedBox(height: 12),
                    _buildMetricStat(
                      'Requests/min',
                      _systemMetrics!.performance.requestsPerMinute.toString(),
                      Icons.trending_up,
                      Colors.greenAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieMetric(
    String label,
    double percentage,
    Color color,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 35,
                  sections: [
                    PieChartSectionData(
                      value: percentage,
                      color: color,
                      radius: 12,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: 100 - percentage,
                      color: Colors.white.withOpacity(0.1),
                      radius: 12,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white60, fontSize: 9),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatsSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Colors.tealAccent, size: 24),
              SizedBox(width: 12),
              Text(
                'Detailed Statistics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_userStats != null) ...[
            _buildStatRow(
              'Total Users',
              _userStats!.totalUsers.toString(),
              growth: _userStats!.growth,
            ),
            const SizedBox(height: 8),
            _buildStatRow('Active Users', _userStats!.activeUsers.toString()),
            const SizedBox(height: 8),
            _buildStatRow('New Users', _userStats!.newUsers.toString()),
            const Divider(color: Color(0xFF2A2F3E), height: 24),
          ],
          if (_contentStats != null) ...[
            _buildStatRow('Total Kanji', _contentStats!.totalKanji.toString()),
            const SizedBox(height: 8),
            _buildStatRow(
              'Total Quizzes',
              _contentStats!.totalQuizzes.toString(),
            ),
            const SizedBox(height: 8),
            _buildStatRow('Total Lists', _contentStats!.totalLists.toString()),
            const SizedBox(height: 8),
            _buildStatRow('Total Decks', _contentStats!.totalDecks.toString()),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {double? growth}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (growth != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: growth >= 0
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      growth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: growth >= 0 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${growth.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: growth >= 0 ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trends',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_userChartData != null)
          _buildChartCard('User Growth', _userChartData!),
        const SizedBox(height: 12),
        if (_activityChartData != null)
          _buildChartCard('Activity', _activityChartData!),
      ],
    );
  }

  Widget _buildChartCard(String title, ChartData chartData) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: _buildSimpleBarChart(chartData)),
        ],
      ),
    );
  }

  Widget _buildSimpleBarChart(ChartData chartData) {
    if (chartData.data.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    final maxValue = chartData.data
        .map((d) => d.value)
        .reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue > 0 ? maxValue * 1.2 : 10,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1A1F2E),
            tooltipBorder: const BorderSide(color: Colors.tealAccent, width: 1),
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${chartData.data[groupIndex].label}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: rod.toY.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 ||
                    value.toInt() >= chartData.data.length) {
                  return const SizedBox.shrink();
                }

                // Show fewer labels if too many data points
                final totalPoints = chartData.data.length;
                final showEvery = totalPoints > 15
                    ? (totalPoints / 6).ceil()
                    : totalPoints > 7
                    ? 2
                    : 1;

                if (value.toInt() % showEvery != 0 &&
                    value.toInt() != totalPoints - 1) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    chartData.data[value.toInt()].label,
                    style: const TextStyle(color: Colors.white60, fontSize: 9),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                );
              },
              reservedSize: 35,
              interval: maxValue > 0 ? maxValue / 4 : 1,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue > 0 ? maxValue / 4 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
            left: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
          ),
        ),
        barGroups: chartData.data.asMap().entries.map((entry) {
          final index = entry.key;
          final dataPoint = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: dataPoint.value.toDouble(),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)],
                ),
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxValue * 1.2,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentActivitiesCard() {
    if (_activityStats == null || _activityStats!.recentActivities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.tealAccent, size: 24),
                SizedBox(width: 12),
                Text(
                  'Recent Activities',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF2A2F3E), height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activityStats!.recentActivities.length,
            separatorBuilder: (_, __) =>
                const Divider(color: Color(0xFF2A2F3E), height: 1),
            itemBuilder: (context, index) {
              final activity = _activityStats!.recentActivities[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.tealAccent.withOpacity(0.2),
                  child: Icon(
                    _getActivityIcon(activity.type),
                    color: Colors.tealAccent,
                    size: 20,
                  ),
                ),
                title: Text(
                  activity.type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  _formatTimestamp(activity.timestamp),
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    activity.count.toString(),
                    style: const TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return Icons.quiz;
      case 'flashcard':
      case 'deck':
        return Icons.style;
      case 'study':
        return Icons.school;
      case 'list':
        return Icons.list;
      default:
        return Icons.play_circle;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
