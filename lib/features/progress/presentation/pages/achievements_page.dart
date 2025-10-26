import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/achievement.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_event.dart';
import '../bloc/progress_state.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  String _filterCategory = 'all';

  @override
  void initState() {
    super.initState();
    context.read<ProgressBloc>().add(const LoadAchievements());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProgressBloc>().add(const LoadAchievements());
            },
          ),
        ],
      ),
      body: BlocBuilder<ProgressBloc, ProgressState>(
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
                    onPressed: () {
                      context.read<ProgressBloc>().add(
                        const LoadAchievements(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AchievementsLoaded) {
            final overview = state.achievements;
            final filteredAchievements = _filterCategory == 'all'
                ? overview.achievements
                : overview.achievements
                      .where((a) => a.category == _filterCategory)
                      .toList();

            return Column(
              children: [
                // Stats header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.primaryContainer,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            theme: theme,
                            label: 'Unlocked',
                            value: overview.totalUnlocked.toString(),
                            icon: Icons.emoji_events,
                          ),
                          _buildStatColumn(
                            theme: theme,
                            label: 'Total',
                            value: overview.totalAvailable.toString(),
                            icon: Icons.stars,
                          ),
                          _buildStatColumn(
                            theme: theme,
                            label: 'Completion',
                            value:
                                '${overview.completionPercentage.toStringAsFixed(0)}%',
                            icon: Icons.percent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: overview.completionPercentage / 100,
                          minHeight: 8,
                          backgroundColor: theme.colorScheme.onPrimaryContainer
                              .withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),

                // Category filter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(theme, 'all', 'All'),
                        const SizedBox(width: 8),
                        _buildFilterChip(theme, 'flashcard', 'Flashcards'),
                        const SizedBox(width: 8),
                        _buildFilterChip(theme, 'quiz', 'Quizzes'),
                        const SizedBox(width: 8),
                        _buildFilterChip(theme, 'streak', 'Streaks'),
                        const SizedBox(width: 8),
                        _buildFilterChip(theme, 'kanji', 'Kanji'),
                      ],
                    ),
                  ),
                ),

                // Recently unlocked
                if (overview.recentlyUnlocked.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.new_releases,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recently Unlocked',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: overview.recentlyUnlocked.length,
                      itemBuilder: (context, index) {
                        return _buildRecentAchievementCard(
                          overview.recentlyUnlocked[index],
                          theme,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                ],

                // All achievements grid
                Expanded(
                  child: filteredAchievements.isEmpty
                      ? Center(
                          child: Text(
                            'No achievements in this category',
                            style: theme.textTheme.bodyLarge,
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.85,
                              ),
                          itemCount: filteredAchievements.length,
                          itemBuilder: (context, index) {
                            return _buildAchievementCard(
                              filteredAchievements[index],
                              theme,
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildStatColumn({
    required ThemeData theme,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.onPrimaryContainer),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(ThemeData theme, String value, String label) {
    final isSelected = _filterCategory == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterCategory = value;
        });
      },
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildRecentAchievementCard(Achievement achievement, ThemeData theme) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 4,
        color: theme.colorScheme.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(achievement.icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(
                achievement.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stars, size: 12, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '+${achievement.xpReward} XP',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, ThemeData theme) {
    return Card(
      elevation: achievement.unlocked ? 3 : 1,
      color: achievement.unlocked
          ? null
          : theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: InkWell(
        onTap: () => _showAchievementDetail(achievement),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    achievement.icon,
                    style: TextStyle(
                      fontSize: 48,
                      color: achievement.unlocked
                          ? null
                          : theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                  if (achievement.unlocked)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                achievement.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: achievement.unlocked
                      ? null
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (!achievement.unlocked) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: achievement.progress / 100,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${achievement.currentValue}/${achievement.targetValue}',
                  style: theme.textTheme.bodySmall,
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stars, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '+${achievement.xpReward} XP',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAchievementDetail(Achievement achievement) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(achievement.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(child: Text(achievement.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 16),
            if (!achievement.unlocked) ...[
              Text(
                'Progress',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: achievement.progress / 100,
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${achievement.currentValue} / ${achievement.targetValue}',
                style: theme.textTheme.bodyMedium,
              ),
            ] else ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Unlocked!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (achievement.unlockedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Unlocked on ${achievement.unlockedAt!.day}/${achievement.unlockedAt!.month}/${achievement.unlockedAt!.year}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stars, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Reward: ${achievement.xpReward} XP',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
