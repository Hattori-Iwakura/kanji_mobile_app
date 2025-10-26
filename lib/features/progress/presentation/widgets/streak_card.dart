import 'package:flutter/material.dart';

import '../../domain/entities/streak.dart';

class StreakCard extends StatelessWidget {
  final Streak streak;

  const StreakCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStreakColumn(
              theme: theme,
              icon: Icons.local_fire_department,
              label: 'Current Streak',
              value: streak.currentStreak,
              color: Colors.orange,
            ),
            Container(
              width: 1,
              height: 60,
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.2),
            ),
            _buildStreakColumn(
              theme: theme,
              icon: Icons.emoji_events,
              label: 'Longest Streak',
              value: streak.longestStreak,
              color: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakColumn({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 36, color: color),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          value == 1 ? 'day' : 'days',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
