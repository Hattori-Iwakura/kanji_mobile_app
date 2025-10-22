import 'package:flutter/material.dart';
import '../../domain/entities/study_progress.dart';

/// Page displaying study session results
class SessionResultsPage extends StatelessWidget {
  final StudyProgress progress;

  const SessionResultsPage({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final totalCards = progress.cardsCorrect + progress.cardsIncorrect;
    final accuracy = totalCards > 0
        ? (progress.cardsCorrect / totalCards * 100).toStringAsFixed(1)
        : '0.0';
    final minutes = progress.studyDuration ~/ 60;
    final seconds = progress.studyDuration % 60;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Session Results',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success icon
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            // Congratulations text
            const Text(
              'Great Work!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'You studied $totalCards card${totalCards != 1 ? 's' : ''}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            // Stats cards
            _buildStatCard(
              icon: Icons.timer_outlined,
              label: 'Study Time',
              value: '$minutes:${seconds.toString().padLeft(2, '0')}',
              color: Colors.blue,
            ),

            const SizedBox(height: 16),

            _buildStatCard(
              icon: Icons.percent,
              label: 'Accuracy',
              value: '$accuracy%',
              color: _getAccuracyColor(double.parse(accuracy)),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.check_circle_outline,
                    label: 'Correct',
                    value: progress.cardsCorrect.toString(),
                    color: Colors.green,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.cancel_outlined,
                    label: 'Incorrect',
                    value: progress.cardsIncorrect.toString(),
                    color: Colors.red,
                    isCompact: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildStatCard(
              icon: Icons.style,
              label: 'Total Cards',
              value: progress.cardsStudied.toString(),
              color: Colors.purple,
            ),

            const SizedBox(height: 40),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Go back to deck list and reload
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Decks'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Share results (future feature)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon!')),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Results'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 8 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isCompact ? 24 : 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isCompact ? 12 : 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 20 : 28,
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

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 90) return Colors.green;
    if (accuracy >= 70) return Colors.yellow;
    if (accuracy >= 50) return Colors.orange;
    return Colors.red;
  }
}
