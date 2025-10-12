import 'package:flutter/material.dart';
import '../../domain/entities/kanji.dart';

class KanjiDetailPage extends StatelessWidget {
  final Kanji kanji;

  const KanjiDetailPage({super.key, required this.kanji});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kanji.character),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kanji Character Display
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.indigo.shade100, Colors.indigo.shade50],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      kanji.character,
                      style: const TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Info Cards
              _buildInfoCard('Thông tin cơ bản', [
                if (kanji.strokes > 0)
                  _buildInfoRow('Số nét', '${kanji.strokes} nét'),
                if (kanji.grade != null)
                  _buildInfoRow('Lớp', 'Lớp ${kanji.grade}'),
                if (kanji.jlptNew != null)
                  _buildInfoRow('JLPT', 'N${kanji.jlptNew}'),
                if (kanji.freq != null)
                  _buildInfoRow('Độ phổ biến', '#${kanji.freq}'),
              ]),
              const SizedBox(height: 16),

              _buildInfoCard('Nghĩa', [_buildListContent(kanji.meanings)]),
              const SizedBox(height: 16),

              _buildInfoCard('Âm On (音読み)', [
                _buildListContent(kanji.readingsOn),
              ]),
              const SizedBox(height: 16),

              _buildInfoCard('Âm Kun (訓読み)', [
                _buildListContent(kanji.readingsKun),
              ]),
              const SizedBox(height: 16),

              if (kanji.wkRadicals != null && kanji.wkRadicals!.isNotEmpty)
                _buildInfoCard('Bộ thủ (Radicals)', [
                  _buildListContent(kanji.wkRadicals!),
                ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildListContent(List<String> items) {
    if (items.isEmpty) {
      return const Text(
        'Không có dữ liệu',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.indigo.shade200),
          ),
          child: Text(
            item,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),
    );
  }
}
