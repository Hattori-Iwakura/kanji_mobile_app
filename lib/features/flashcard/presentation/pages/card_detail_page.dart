import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart' as di;
import '../../domain/entities/flashcard_card_detail.dart';
import '../../domain/entities/flashcard_review.dart';
import '../bloc/card_detail_cubit.dart';
import '../bloc/card_detail_state.dart';

class CardDetailPage extends StatelessWidget {
  final int cardId;
  final String kanjiCharacter;

  const CardDetailPage({
    super.key,
    required this.cardId,
    required this.kanjiCharacter,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<CardDetailCubit>()..load(cardId),
      child: _CardDetailView(cardId: cardId, kanjiCharacter: kanjiCharacter),
    );
  }
}

class _CardDetailView extends StatelessWidget {
  final int cardId;
  final String kanjiCharacter;

  const _CardDetailView({required this.cardId, required this.kanjiCharacter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Card Detail'),
        backgroundColor: Colors.grey[900],
      ),
      body: BlocBuilder<CardDetailCubit, CardDetailState>(
        builder: (context, state) {
          if (state is CardDetailLoading || state is CardDetailInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (state is CardDetailError) {
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
                    onPressed: () =>
                        context.read<CardDetailCubit>().load(cardId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final detail = (state as CardDetailLoaded).detail;
          final reviews = detail.reviews;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _KanjiHeader(
                  kanjiCharacter: kanjiCharacter,
                  meanings: detail.card.backContent['meanings'],
                  onyomi: detail.card.backContent['onyomi'],
                  kunyomi: detail.card.backContent['kunyomi'],
                ),
                const SizedBox(height: 16),
                _StatsRow(stats: detail.stats),
                const SizedBox(height: 24),
                _ReviewChart(reviews: reviews),
                const SizedBox(height: 24),
                _ReviewHistory(reviews: reviews),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _KanjiHeader extends StatelessWidget {
  final String kanjiCharacter;
  final dynamic meanings;
  final dynamic onyomi;
  final dynamic kunyomi;

  const _KanjiHeader({
    required this.kanjiCharacter,
    this.meanings,
    this.onyomi,
    this.kunyomi,
  });

  @override
  Widget build(BuildContext context) {
    final meaningText = meanings is List
        ? meanings.join(', ')
        : meanings?.toString();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kanjiCharacter,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (meaningText != null && meaningText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              meaningText,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (onyomi != null && onyomi.toString().isNotEmpty)
                _InfoBadge(label: 'Onyomi', value: onyomi.toString()),
              if (kunyomi != null && kunyomi.toString().isNotEmpty)
                _InfoBadge(label: 'Kunyomi', value: kunyomi.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final FlashcardCardStats stats;

  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.fact_check,
            label: 'Reviews',
            value: stats.totalReviews.toString(),
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.thumb_up_alt_outlined,
            label: 'Accuracy',
            value: '${stats.accuracy}%',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.history,
            label: 'Last review',
            value: stats.lastReviewedAt != null
                ? _formatDate(stats.lastReviewedAt!)
                : 'Never',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
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

class _ReviewChart extends StatelessWidget {
  final List<FlashcardReview> reviews;

  const _ReviewChart({required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Review Progress',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 12),
            Text('No reviews yet', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    final sorted = reviews.reversed.toList();
    final spots = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), sorted[i].rating.toDouble()));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Progress',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 5,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: Colors.white12, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sorted.length) {
                          return const SizedBox.shrink();
                        }
                        final date = sorted[index].createdAt;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${date.month}/${date.day}',
                            style: const TextStyle(
                              color: Colors.white54,
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
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.blue,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewHistory extends StatelessWidget {
  final List<FlashcardReview> reviews;

  const _ReviewHistory({required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Review History',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          if (reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'No reviews yet',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            ...reviews.map(
              (review) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueGrey.withOpacity(0.2),
                  child: Text(
                    review.rating.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  _formatDateTime(review.createdAt),
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Time spent: ${review.timeSpent}s',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime date) {
  return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
