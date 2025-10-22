import 'package:flutter/material.dart';
import '../../domain/entities/kanji.dart';

/// Detail page for a single kanji showing full information
class KanjiDetailPage extends StatelessWidget {
  final Kanji kanji;

  const KanjiDetailPage({super.key, required this.kanji});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          kanji.character,
          style: const TextStyle(color: Colors.white, fontSize: 32),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              // TODO: Add to favorites
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main character display
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: Center(
                  child: Text(
                    kanji.character,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Noto Sans JP',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Badges (JLPT, Grade, Strokes)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (kanji.jlpt != null)
                  _buildBadge(
                    'JLPT',
                    'N${kanji.jlpt}',
                    _getJlptColor(kanji.jlpt!),
                  ),
                if (kanji.grade != null)
                  _buildBadge('Grade', '${kanji.grade}', Colors.blue[300]!),
                if (kanji.strokeCount != null)
                  _buildBadge(
                    'Strokes',
                    '${kanji.strokeCount}',
                    Colors.purple[300]!,
                  ),
                if (kanji.frequency != null)
                  _buildBadge(
                    'Frequency',
                    '#${kanji.frequency}',
                    Colors.orange[300]!,
                  ),
              ],
            ),
            const SizedBox(height: 32),

            // Readings
            _buildSection(
              'Readings',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (kanji.onyomi != null) ...[
                    _buildReadingRow('音読み (On-yomi)', kanji.onyomi!),
                    const SizedBox(height: 12),
                  ],
                  if (kanji.kunyomi != null) ...[
                    _buildReadingRow('訓読み (Kun-yomi)', kanji.kunyomi!),
                  ],
                  if (kanji.onyomi == null && kanji.kunyomi == null)
                    const Text(
                      'No readings available',
                      style: TextStyle(
                        color: Colors.white54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Meanings
            _buildSection(
              'Meanings',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kanji.meaningsList
                    .map(
                      (meaning) => Chip(
                        label: Text(meaning),
                        backgroundColor: const Color(0xFF2A2A2A),
                        labelStyle: const TextStyle(color: Colors.white),
                        side: const BorderSide(color: Colors.white24),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Stroke order (Placeholder - will integrate with Jisho API later)
            _buildSection(
              'Stroke Order',
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.draw, color: Colors.white54, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Stroke order animation',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coming soon via Jisho API',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Examples (Placeholder - will add later)
            _buildSection(
              'Examples',
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.library_books,
                      color: Colors.white54,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Example sentences',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coming soon via Kanji Alive API',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
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
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            reading,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getJlptColor(int jlpt) {
    switch (jlpt) {
      case 5:
        return Colors.green[300]!;
      case 4:
        return Colors.lightGreen[300]!;
      case 3:
        return Colors.yellow[300]!;
      case 2:
        return Colors.orange[300]!;
      case 1:
        return Colors.red[300]!;
      default:
        return Colors.grey[300]!;
    }
  }
}
