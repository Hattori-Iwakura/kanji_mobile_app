import 'package:flutter/material.dart';
import '../../domain/usecases/get_kanji_stats.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart' as di;

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  KanjiStatsResult? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final getKanjiStats = di.sl<GetKanjiStats>();
    final result = await getKanjiStats(NoParams());

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
        });
      },
      (stats) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
          ? const Center(child: Text('Không thể tải thống kê'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalCard(),
                  const SizedBox(height: 16),
                  _buildGradeStats(),
                  const SizedBox(height: 16),
                  _buildJlptStats(),
                ],
              ),
            ),
    );
  }

  Widget _buildTotalCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo.shade600, Colors.indigo.shade400],
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.language, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Tổng số Kanji',
              style: TextStyle(fontSize: 20, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '${_stats!.totalKanji}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeStats() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theo lớp học',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...List.generate(6, (index) {
              final grade = index + 1;
              final count = _stats!.byGrade[grade] ?? 0;
              return _buildStatRow('Lớp $grade', count, Colors.blue);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildJlptStats() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theo cấp độ JLPT',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...List.generate(5, (index) {
              final level = 5 - index; // N5 to N1
              final count = _stats!.byJlpt[level] ?? 0;
              return _buildStatRow('N$level', count, Colors.orange);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    final percentage = (_stats!.totalKanji > 0)
        ? (count / _stats!.totalKanji * 100).toStringAsFixed(1)
        : '0.0';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$count ($percentage%)',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: count / _stats!.totalKanji,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}
