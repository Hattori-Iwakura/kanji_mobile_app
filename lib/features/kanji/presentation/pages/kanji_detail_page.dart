import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/kanji.dart';
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_state.dart';

class KanjiDetailPage extends StatelessWidget {
  const KanjiDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KanjiBloc, KanjiState>(
      builder: (context, state) {
        if (state is KanjiLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is KanjiError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is KanjiDetailLoaded) {
          final kanji = state.kanji;
          return _buildDetailContent(context, kanji);
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Kanji Detail')),
          body: const Center(child: Text('No data')),
        );
      },
    );
  }

  Widget _buildDetailContent(BuildContext context, Kanji kanji) {
    return Scaffold(
      appBar: AppBar(title: Text('Kanji: ${kanji.character}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Kanji Character
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  kanji.character,
                  style: const TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Meanings
            _buildSection(
              context,
              'Meanings',
              Icons.translate,
              Text(
                kanji.meaningsList.join(', '),
                style: const TextStyle(fontSize: 16),
              ),
            ),

            // Readings
            if (kanji.onyomi != null || kanji.kunyomi != null) ...[
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Readings',
                Icons.record_voice_over,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (kanji.onyomi != null)
                      _buildReadingRow('On\'yomi (音読み)', kanji.onyomi!),
                    if (kanji.onyomi != null && kanji.kunyomi != null)
                      const SizedBox(height: 8),
                    if (kanji.kunyomi != null)
                      _buildReadingRow('Kun\'yomi (訓読み)', kanji.kunyomi!),
                  ],
                ),
              ),
            ],

            // Basic Information
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Basic Information',
              Icons.info,
              Column(
                children: [
                  if (kanji.strokeCount != null)
                    _buildInfoRow('Stroke Count', '${kanji.strokeCount}'),
                  if (kanji.jlptLevel != null)
                    _buildInfoRow('JLPT Level', kanji.jlptLevel!),
                  if (kanji.grade != null)
                    _buildInfoRow('Grade', 'Grade ${kanji.grade}'),
                  if (kanji.frequency != null)
                    _buildInfoRow('Frequency', '#${kanji.frequency}'),
                ],
              ),
            ),

            // Radicals
            if (kanji.radicalsList.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Radicals',
                Icons.grid_view,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kanji.radicalsList
                      .map(
                        (radical) => Chip(
                          label: Text(radical),
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Widget content,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildReadingRow(String type, String reading) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            type,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(child: Text(reading, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
