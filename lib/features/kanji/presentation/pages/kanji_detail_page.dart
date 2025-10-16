import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/kanji_progress.dart';
import '../bloc/detail/kanji_detail_bloc.dart';
import '../bloc/detail/kanji_detail_event.dart';
import '../bloc/detail/kanji_detail_state.dart';

class KanjiDetailPage extends StatelessWidget {
  final String character;

  const KanjiDetailPage({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<KanjiDetailBloc>()..add(LoadKanjiDetail(character)),
      child: KanjiDetailView(character: character),
    );
  }
}

class KanjiDetailView extends StatelessWidget {
  final String character;

  const KanjiDetailView({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kanji: $character'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<KanjiDetailBloc>().add(
                RefreshKanjiDetail(character),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<KanjiDetailBloc, KanjiDetailState>(
        builder: (context, state) {
          if (state is DetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DetailError) {
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
                      context.read<KanjiDetailBloc>().add(
                        LoadKanjiDetail(character),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DetailLoaded || state is DetailLoadingMore) {
            final detail = state is DetailLoaded
                ? state.detail
                : (state as DetailLoadingMore).detail;
            final examples = state is DetailLoaded
                ? state.allExamples
                : (state as DetailLoadingMore).currentExamples;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<KanjiDetailBloc>().add(
                  RefreshKanjiDetail(character),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero Section
                    _buildHeroSection(context, detail),

                    // Readings Section
                    _buildReadingsSection(context, detail),

                    // Progress Section (if available)
                    if (detail.hasProgress)
                      _buildProgressSection(context, detail.progress!),

                    // Examples Section
                    _buildExamplesSection(
                      context,
                      examples,
                      state is DetailLoadingMore,
                    ),

                    // Actions
                    _buildActionsSection(context),

                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddToListDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add to List'),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, detail) {
    final kanji = detail.kanji;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: <Widget>[
          // Large Kanji Character
          Text(
            kanji.character,
            style: const TextStyle(
              fontSize: 120,
              fontWeight: FontWeight.bold,
              fontFamily: 'Noto Sans JP',
            ),
          ),
          const SizedBox(height: 16),

          // Meanings
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: kanji.meaningsList.map<Widget>((meaning) {
              return Chip(
                label: Text(meaning),
                backgroundColor: Colors.blue.shade50,
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Badges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (kanji.jlpt != null)
                _buildBadge('JLPT N${kanji.jlpt}', _getJlptColor(kanji.jlpt!)),
              if (kanji.grade != null) ...<Widget>[
                const SizedBox(width: 8),
                _buildBadge('Grade ${kanji.grade}', Colors.purple.shade400),
              ],
              if (kanji.strokeCount != null) ...<Widget>[
                const SizedBox(width: 8),
                _buildBadge(
                  '${kanji.strokeCount} strokes',
                  Colors.orange.shade400,
                ),
              ],
              if (kanji.frequency != null) ...<Widget>[
                const SizedBox(width: 8),
                _buildBadge('Freq: ${kanji.frequency}', Colors.teal.shade400),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReadingsSection(BuildContext context, detail) {
    final kanji = detail.kanji;
    if (kanji.onyomi == null && kanji.kunyomi == null) {
      return const SizedBox();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Readings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (kanji.onyomi != null && kanji.onyomi!.isNotEmpty) ...<Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 80,
                    child: Text(
                      '音読み',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      kanji.onyomi!,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (kanji.kunyomi != null && kanji.kunyomi!.isNotEmpty) ...<Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 80,
                    child: Text(
                      '訓読み',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      kanji.kunyomi!,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, progress) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                _buildProgressStatusBadge(progress.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Reviews',
                    progress.timesReviewed.toString(),
                    Icons.refresh,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Correct',
                    progress.timesCorrect.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Accuracy',
                    '${progress.accuracy.toStringAsFixed(0)}%',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            if (progress.lastReviewed != null) ...[
              const SizedBox(height: 12),
              Text(
                'Last reviewed: ${_formatDate(progress.lastReviewed!)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStatusBadge(ProgressStatus status) {
    Color color;
    String text;

    switch (status) {
      case ProgressStatus.newKanji:
        color = Colors.blue.shade100;
        text = 'New';
        break;
      case ProgressStatus.learning:
        color = Colors.orange.shade100;
        text = 'Learning';
        break;
      case ProgressStatus.known:
        color = Colors.lightGreen.shade100;
        text = 'Known';
        break;
      case ProgressStatus.mastered:
        color = Colors.green.shade300;
        text = 'Mastered';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildExamplesSection(
    BuildContext context,
    examples,
    bool isLoadingMore,
  ) {
    if (examples.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No examples available',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Example Words (${examples.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...examples
                .map<Widget>((example) => _buildExampleCard(example))
                .toList(),
            if (isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!isLoadingMore && examples.length >= 5)
              TextButton(
                onPressed: () {
                  context.read<KanjiDetailBloc>().add(
                    LoadMoreExamples(
                      character: character,
                      currentCount: examples.length,
                    ),
                  );
                },
                child: const Text('Load More Examples'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(example) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                example.word,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (example.jlptLevel != null)
                _buildBadge(
                  'N${example.jlptLevel}',
                  _getJlptColor(example.jlptLevel!),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            example.reading,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(example.meaning, style: const TextStyle(fontSize: 14)),
          if (example.wordType != null) ...[
            const SizedBox(height: 4),
            Text(
              example.wordType!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              _showProgressUpdateDialog(context);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Update Progress'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              // Navigate to flashcard study with this kanji
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Study feature coming soon!')),
              );
            },
            icon: const Icon(Icons.school),
            label: const Text('Study Now'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }

  Color _getJlptColor(int jlpt) {
    switch (jlpt) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.deepOrange;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAddToListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add to List'),
        content: const Text('List selection feature coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showProgressUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Mark as New'),
              leading: const Icon(Icons.fiber_new, color: Colors.blue),
              onTap: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progress update coming soon!')),
                );
              },
            ),
            ListTile(
              title: const Text('Mark as Learning'),
              leading: const Icon(Icons.psychology, color: Colors.orange),
              onTap: () {
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              title: const Text('Mark as Known'),
              leading: const Icon(Icons.check, color: Colors.lightGreen),
              onTap: () {
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              title: const Text('Mark as Mastered'),
              leading: const Icon(Icons.star, color: Colors.green),
              onTap: () {
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }
}
