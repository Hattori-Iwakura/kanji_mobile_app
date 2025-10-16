import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart' as di;
import '../../domain/entities/flashcard_stats.dart';
import '../bloc/flashcard_stats_cubit.dart';
import '../bloc/flashcard_stats_state.dart';

class FlashcardStatsPage extends StatelessWidget {
  final int? deckId;
  final String? deckName;

  const FlashcardStatsPage({super.key, this.deckId, this.deckName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<FlashcardStatsCubit>()..load(deckId: deckId),
      child: _FlashcardStatsView(deckId: deckId, deckName: deckName),
    );
  }
}

class _FlashcardStatsView extends StatelessWidget {
  final int? deckId;
  final String? deckName;

  const _FlashcardStatsView({this.deckId, this.deckName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(deckName == null ? 'Overall Stats' : '$deckName Stats'),
        backgroundColor: Colors.grey[900],
      ),
      body: BlocBuilder<FlashcardStatsCubit, FlashcardStatsState>(
        builder: (context, state) {
          if (state is FlashcardStatsLoading ||
              state is FlashcardStatsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (state is FlashcardStatsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<FlashcardStatsCubit>().load(
                      deckId: deckId,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stats = (state as FlashcardStatsLoaded).stats;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SummaryGrid(stats: stats),
                const SizedBox(height: 16),
                _AccuracyBreakdown(stats: stats),
                const SizedBox(height: 16),
                _StreakSection(stats: stats),
                const SizedBox(height: 24),
                _ActivityHeatmap(entries: stats.activityHeatmap),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final FlashcardStats stats;

  const _SummaryGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      children: [
        _StatTile(
          icon: Icons.style_outlined,
          label: 'Total cards',
          value: stats.totalCards.toString(),
          color: Colors.blue,
        ),
        _StatTile(
          icon: Icons.school_outlined,
          label: 'Reviewed',
          value: stats.cardsReviewed.toString(),
          color: Colors.purple,
        ),
        _StatTile(
          icon: Icons.thumb_up_alt_outlined,
          label: 'Accuracy',
          value: '${stats.accuracy}%',
          color: Colors.green,
        ),
        _StatTile(
          icon: Icons.flash_on_outlined,
          label: 'Current streak',
          value: stats.currentStreak.toString(),
          color: Colors.orange,
        ),
      ],
    );
  }
}

class _AccuracyBreakdown extends StatelessWidget {
  final FlashcardStats stats;

  const _AccuracyBreakdown({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.totalCorrect + stats.totalWrong;
    final correctPercent = total == 0 ? 0.0 : (stats.totalCorrect / total);
    final wrongPercent = total == 0 ? 0.0 : (stats.totalWrong / total);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Answer quality',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ProgressBar(
                  value: correctPercent,
                  color: Colors.green,
                  label: 'Correct (${stats.totalCorrect})',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProgressBar(
                  value: wrongPercent,
                  color: Colors.red,
                  label: 'Wrong (${stats.totalWrong})',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakSection extends StatelessWidget {
  final FlashcardStats stats;

  const _StreakSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current streak',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '${stats.currentStreak} days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 48, color: Colors.white10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Longest streak',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '${stats.longestStreak} days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
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
}

class _ActivityHeatmap extends StatelessWidget {
  final List<FlashcardActivityEntry> entries;

  const _ActivityHeatmap({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Study activity',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 12),
            Text(
              'No activity recorded yet',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    final maxValue = entries
        .map((e) => e.value)
        .fold<int>(0, (prev, value) => value > prev ? value : prev);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Study activity',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: entries
                .map(
                  (entry) => _HeatCell(
                    date: entry.date,
                    value: entry.value,
                    maxValue: maxValue,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  final DateTime date;
  final int value;
  final int maxValue;

  const _HeatCell({
    required this.date,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final color = value == 0
        ? Colors.blueGrey.withOpacity(0.2)
        : Colors.blueAccent.withOpacity(
            0.3 + (0.7 * (value / (maxValue == 0 ? 1 : maxValue))),
          );

    return Tooltip(
      message:
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}\n$value reviews',
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final String label;

  const _ProgressBar({
    required this.value,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            backgroundColor: Colors.white12,
            color: color,
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
