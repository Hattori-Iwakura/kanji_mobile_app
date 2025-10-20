import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/network/api_client.dart';
import '../../../../injection_container.dart' as di;

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final ApiClient _apiClient = di.sl<ApiClient>();

  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual admin stats endpoint
      // For now, using mock data
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _stats = {
          'totalUsers': 1250,
          'totalKanji': 2136,
          'totalQuizzes': 45,
          'totalFlashcards': 320,
          'activeUsers': 856,
          'newUsersToday': 23,
          'quizzesCompletedToday': 145,
          'avgSessionTime': '12.5 min',
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load stats: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardStats,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadDashboardStats,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            _buildWelcomeBanner(),
            const SizedBox(height: 24),

            // Quick Stats
            _buildQuickStats(),
            const SizedBox(height: 24),

            // Admin Actions
            Text(
              'Management',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAdminActions(),
            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade700, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage your Kanji learning platform',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
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

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Users',
              _stats['totalUsers']?.toString() ?? '0',
              Icons.people,
              Colors.blue,
            ),
            _buildStatCard(
              'Active Users',
              _stats['activeUsers']?.toString() ?? '0',
              Icons.trending_up,
              Colors.green,
            ),
            _buildStatCard(
              'Total Kanji',
              _stats['totalKanji']?.toString() ?? '0',
              Icons.book,
              Colors.orange,
            ),
            _buildStatCard(
              'Total Quizzes',
              _stats['totalQuizzes']?.toString() ?? '0',
              Icons.quiz,
              Colors.purple,
            ),
            _buildStatCard(
              'Flashcards',
              _stats['totalFlashcards']?.toString() ?? '0',
              Icons.style,
              Colors.pink,
            ),
            _buildStatCard(
              'New Today',
              _stats['newUsersToday']?.toString() ?? '0',
              Icons.person_add,
              Colors.teal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActions() {
    return Column(
      children: [
        _buildActionCard(
          'User Management',
          'Manage user accounts and permissions',
          Icons.people_outline,
          Colors.blue,
          () => Navigator.pushNamed(context, AppRoutes.adminUsers),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Kanji Management',
          'Add, edit, or remove kanji characters',
          Icons.book_outlined,
          Colors.orange,
          () => Navigator.pushNamed(context, AppRoutes.adminKanji),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Quiz Management',
          'Manage quizzes and questions',
          Icons.quiz_outlined,
          Colors.purple,
          () => Navigator.pushNamed(context, AppRoutes.adminQuizzes),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Content Moderation',
          'Review and moderate user-generated content',
          Icons.flag_outlined,
          Colors.red,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Content moderation - Coming soon')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Analytics & Reports',
          'View detailed analytics and generate reports',
          Icons.analytics_outlined,
          Colors.green,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Analytics - Coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {
        'action': 'New user registered',
        'user': 'user@example.com',
        'time': '5 minutes ago',
        'icon': Icons.person_add,
        'color': Colors.green,
      },
      {
        'action': 'Quiz published',
        'user': 'JLPT N5 Grammar Quiz',
        'time': '1 hour ago',
        'icon': Icons.quiz,
        'color': Colors.purple,
      },
      {
        'action': 'Kanji updated',
        'user': '日 (Sun/Day)',
        'time': '3 hours ago',
        'icon': Icons.edit,
        'color': Colors.orange,
      },
      {
        'action': 'User reported content',
        'user': 'Inappropriate comment',
        'time': '5 hours ago',
        'icon': Icons.flag,
        'color': Colors.red,
      },
      {
        'action': 'Flashcard deck created',
        'user': 'Basic Kanji - 100 cards',
        'time': '1 day ago',
        'icon': Icons.style,
        'color': Colors.blue,
      },
    ];

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (activity['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                activity['icon'] as IconData,
                color: activity['color'] as Color,
                size: 20,
              ),
            ),
            title: Text(
              activity['action'] as String,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(activity['user'] as String),
            trailing: Text(
              activity['time'] as String,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          );
        },
      ),
    );
  }
}
