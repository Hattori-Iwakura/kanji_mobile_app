import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/progress/kanji_progress_bloc.dart';
import '../bloc/progress/kanji_progress_event.dart';
import '../bloc/progress/kanji_progress_state.dart';

class ProgressDashboardPage extends StatelessWidget {
  const ProgressDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<KanjiProgressBloc>()..add(const LoadProgressSummary()),
      child: const ProgressDashboardView(),
    );
  }
}

class ProgressDashboardView extends StatelessWidget {
  const ProgressDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<KanjiProgressBloc>().add(
                const LoadProgressSummary(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<KanjiProgressBloc, KanjiProgressState>(
        builder: (context, state) {
          if (state is ProgressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProgressError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<KanjiProgressBloc>().add(
                        const LoadProgressSummary(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProgressSummaryLoaded) {
            final summary = state.summary;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<KanjiProgressBloc>().add(
                  const LoadProgressSummary(),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Overall Stats Section
                    _buildOverallStats(context, summary),

                    // Progress Bar
                    _buildProgressBar(context, summary),

                    // Status Cards Grid
                    _buildStatusCards(context, summary),

                    // Action Buttons
                    _buildActionButtons(context),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildOverallStats(BuildContext context, summary) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Kanji Learned',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${summary.totalKanjiLearned}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'out of ${summary.totalKanji} total kanji',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, summary) {
    final percentage = summary.completionPercentage ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards(BuildContext context, summary) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'New',
                  summary.newKanjiCount.toString(),
                  Icons.fiber_new,
                  Colors.blue,
                  'Just started',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Learning',
                  summary.learningCount.toString(),
                  Icons.psychology,
                  Colors.orange,
                  'In progress',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Known',
                  summary.knownCount.toString(),
                  Icons.check_circle,
                  Colors.lightGreen,
                  'Familiar',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Mastered',
                  summary.masteredCount.toString(),
                  Icons.star,
                  Colors.green,
                  'Expert level',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String count,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                count,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to flashcard study
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Study session feature coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.school),
            label: const Text('Start Study Session'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              _showKanjiNeedingReview(context);
            },
            icon: const Icon(Icons.notification_important),
            label: const Text('Kanji Needing Review'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              _showProgressFilters(context);
            },
            icon: const Icon(Icons.filter_list),
            label: const Text('Filter by JLPT/Grade'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ],
      ),
    );
  }

  void _showKanjiNeedingReview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kanji Needing Review',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Review List Coming Soon',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This will show kanji that need review\nbased on your study history',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProgressFilters(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter by JLPT Level'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(5, (index) {
                final level = 5 - index;
                return FilterChip(
                  label: Text('N$level'),
                  selected: false,
                  onSelected: (selected) {
                    // Implement JLPT filter
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Filter by N$level coming soon')),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text('Filter by Grade'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(6, (index) {
                final grade = index + 1;
                return FilterChip(
                  label: Text('Grade $grade'),
                  selected: false,
                  onSelected: (selected) {
                    // Implement grade filter
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Filter by Grade $grade coming soon'),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
