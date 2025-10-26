import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/leaderboard.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_event.dart';
import '../bloc/progress_state.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  String _selectedPeriod = 'week';
  String _selectedType = 'xp';

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  void _loadLeaderboard() {
    context.read<ProgressBloc>().add(
      LoadLeaderboard(period: _selectedPeriod, type: _selectedType, limit: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaderboard,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Period selector
                Row(
                  children: [
                    Text('Period:', style: theme.textTheme.titleSmall),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'week', label: Text('Week')),
                          ButtonSegment(value: 'month', label: Text('Month')),
                          ButtonSegment(value: 'all', label: Text('All Time')),
                        ],
                        selected: {_selectedPeriod},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _selectedPeriod = newSelection.first;
                          });
                          _loadLeaderboard();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Type selector
                Row(
                  children: [
                    Text('Rank by:', style: theme.textTheme.titleSmall),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'xp',
                            label: Text('XP'),
                            icon: Icon(Icons.stars, size: 16),
                          ),
                          ButtonSegment(
                            value: 'streak',
                            label: Text('Streak'),
                            icon: Icon(Icons.local_fire_department, size: 16),
                          ),
                        ],
                        selected: {_selectedType},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _selectedType = newSelection.first;
                          });
                          _loadLeaderboard();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Leaderboard list
          Expanded(
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
                          onPressed: _loadLeaderboard,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is LeaderboardLoaded) {
                  final leaderboard = state.leaderboard;

                  if (leaderboard.entries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.leaderboard_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No leaderboard data yet',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: leaderboard.entries.length,
                    itemBuilder: (context, index) {
                      final entry = leaderboard.entries[index];
                      return _buildLeaderboardItem(entry, theme);
                    },
                  );
                }

                return const Center(child: Text('No data available'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, ThemeData theme) {
    final isTopThree = entry.rank <= 3;
    final isCurrentUser = entry.isCurrentUser;

    Color? rankColor;
    IconData? medalIcon;

    if (entry.rank == 1) {
      rankColor = Colors.amber;
      medalIcon = Icons.emoji_events;
    } else if (entry.rank == 2) {
      rankColor = Colors.grey[400];
      medalIcon = Icons.emoji_events;
    } else if (entry.rank == 3) {
      rankColor = Colors.brown[300];
      medalIcon = Icons.emoji_events;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: SizedBox(
          width: 48,
          child: isTopThree && medalIcon != null
              ? Icon(medalIcon, size: 32, color: rankColor)
              : Center(
                  child: Text(
                    '#${entry.rank}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.username,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isCurrentUser
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'YOU',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Icon(Icons.stars, size: 14, color: theme.colorScheme.secondary),
            const SizedBox(width: 4),
            Text('Level ${entry.level}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _selectedType == 'xp'
                      ? Icons.stars
                      : Icons.local_fire_department,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  _selectedType == 'xp'
                      ? entry.xp.toString()
                      : entry.streak.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            Text(
              _selectedType == 'xp' ? 'XP' : 'days',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
