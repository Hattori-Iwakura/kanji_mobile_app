import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/progress_bloc.dart';
import '../bloc/progress_event.dart';
import '../bloc/progress_state.dart';
import '../widgets/progress_stat_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/study_time_chart.dart';

class ProgressOverviewPage extends StatefulWidget {
  const ProgressOverviewPage({super.key});

  @override
  State<ProgressOverviewPage> createState() => _ProgressOverviewPageState();
}

class _ProgressOverviewPageState extends State<ProgressOverviewPage> {
  String _selectedPeriod = '7d';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<ProgressBloc>().add(const RefreshProgress());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.pushNamed(context, '/progress/leaderboard');
            },
            tooltip: 'Leaderboard',
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              Navigator.pushNamed(context, '/progress/achievements');
            },
            tooltip: 'Achievements',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
          // Wait for loading to complete
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: BlocBuilder<ProgressBloc, ProgressState>(
          builder: (context, state) {
            if (state is ProgressLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProgressError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is ProgressDataLoaded) {
              final overview = state.overview;
              final streak = state.streak;
              final flashcardProgress = state.flashcardProgress;
              final quizProgress = state.quizProgress;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // User info header
                  if (overview != null) ...[
                    _buildUserHeader(overview, theme),
                    const SizedBox(height: 24),
                  ],

                  // Streak card
                  if (streak != null) ...[
                    StreakCard(streak: streak),
                    const SizedBox(height: 16),
                  ],

                  // Stats grid
                  if (overview != null) ...[
                    Text(
                      'Overall Statistics',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatsGrid(overview),
                    const SizedBox(height: 24),
                  ],

                  // Period selector
                  _buildPeriodSelector(theme),
                  const SizedBox(height: 16),

                  // Flashcard progress
                  if (flashcardProgress != null) ...[
                    _buildProgressSection(
                      theme: theme,
                      title: 'Flashcard Progress',
                      icon: Icons.style,
                      sessions: flashcardProgress.totalSessions,
                      studyTime: flashcardProgress.totalStudyTime,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Quiz progress
                  if (quizProgress != null) ...[
                    _buildProgressSection(
                      theme: theme,
                      title: 'Quiz Progress',
                      icon: Icons.quiz,
                      sessions: quizProgress.totalAttempts,
                      bestScore: quizProgress.bestScore,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Study time chart
                  const StudyTimeChart(),
                  const SizedBox(height: 16),

                  // Action buttons
                  _buildActionButtons(context),
                ],
              );
            }

            return const Center(child: Text('No data available'));
          },
        ),
      ),
    );
  }

  Widget _buildUserHeader(dynamic overview, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                overview.username[0].toUpperCase(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    overview.username,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Level ${overview.level}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${overview.xp} XP',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(dynamic overview) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        ProgressStatCard(
          icon: Icons.style,
          label: 'Flashcards',
          value: overview.flashcardsStudied.toString(),
          color: Colors.blue,
        ),
        ProgressStatCard(
          icon: Icons.quiz,
          label: 'Quizzes',
          value: overview.quizzesCompleted.toString(),
          color: Colors.green,
        ),
        ProgressStatCard(
          icon: Icons.percent,
          label: 'Avg Score',
          value: '${overview.averageQuizScore.toStringAsFixed(1)}%',
          color: Colors.orange,
        ),
        ProgressStatCard(
          icon: Icons.emoji_events,
          label: 'Achievements',
          value: overview.achievementsUnlocked.toString(),
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(ThemeData theme) {
    return Row(
      children: [
        Text('Time Period:', style: theme.textTheme.titleMedium),
        const SizedBox(width: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '7d', label: Text('Week')),
                ButtonSegment(value: '30d', label: Text('Month')),
                ButtonSegment(value: '90d', label: Text('3 Months')),
                ButtonSegment(value: '1y', label: Text('Year')),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedPeriod = newSelection.first;
                });
                // Reload data with new period
                context.read<ProgressBloc>().add(
                  LoadFlashcardProgress(period: _selectedPeriod),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required int sessions,
    double? bestScore,
    int? studyTime,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  theme: theme,
                  label: 'Sessions',
                  value: sessions.toString(),
                ),
                if (studyTime != null)
                  _buildStatColumn(
                    theme: theme,
                    label: 'Study Time',
                    value: '${studyTime}m',
                  ),
                if (bestScore != null)
                  _buildStatColumn(
                    theme: theme,
                    label: 'Best Score',
                    value: '${bestScore.toStringAsFixed(1)}%',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required ThemeData theme,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/progress/statistics');
            },
            icon: const Icon(Icons.analytics),
            label: const Text('Detailed Stats'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/progress/leaderboard');
            },
            icon: const Icon(Icons.leaderboard),
            label: const Text('Leaderboard'),
          ),
        ),
      ],
    );
  }
}
