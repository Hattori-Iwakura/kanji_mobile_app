import 'package:flutter/material.dart';
import '../../domain/entities/quiz_result.dart';
import '../../domain/entities/quiz_answer.dart';
import 'quiz_list_page.dart';

/// Page for displaying quiz results
class QuizResultPage extends StatelessWidget {
  final QuizResult result;

  const QuizResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Quiz Result', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score card
            _buildScoreCard(),

            const SizedBox(height: 24),

            // Stats grid
            _buildStatsGrid(),

            const SizedBox(height: 24),

            // Performance message
            _buildPerformanceMessage(),

            const SizedBox(height: 32),

            // Detailed answers section
            _buildDetailedAnswers(),

            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getGradeColors(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getGradeColors().first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pass/Fail status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  result.isPassed ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  result.isPassed ? 'PASSED' : 'FAILED',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Score percentage
          Text(
            '${result.scorePercentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),

          const SizedBox(height: 8),

          // Grade
          Text(
            'Grade: ${result.grade}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          // Accuracy
          Text(
            'Accuracy: ${result.accuracy.toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            label: 'Correct',
            value: result.correctAnswers.toString(),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.cancel,
            label: 'Incorrect',
            value: result.incorrectAnswers.toString(),
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.skip_next,
            label: 'Skipped',
            value: result.skippedQuestions.toString(),
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getPerformanceIcon(),
                color: _getGradeColors().first,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Performance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.performanceMessage,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.blue, size: 18),
              const SizedBox(width: 8),
              Text(
                'Time spent: ${result.formattedTimeSpent}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnswers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Review',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...result.answers.asMap().entries.map((entry) {
          final index = entry.key;
          final answer = entry.value;
          return _buildAnswerReviewCard(index + 1, answer);
        }).toList(),
      ],
    );
  }

  Widget _buildAnswerReviewCard(int questionNumber, QuizAnswer answer) {
    final color = answer.isCorrect
        ? Colors.green
        : answer.userAnswer.isEmpty
        ? Colors.orange
        : Colors.red;

    final statusText = answer.isCorrect
        ? 'Correct'
        : answer.userAnswer.isEmpty
        ? 'Skipped'
        : 'Incorrect';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: color),
                    ),
                    child: Center(
                      child: Text(
                        questionNumber.toString(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '${answer.pointsEarned.toStringAsFixed(0)} pts',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          if (answer.userAnswer.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Your answer: ${answer.userAnswer}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],

          if (answer.userAnswer.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'No answer provided',
              style: TextStyle(
                color: Colors.orange.withOpacity(0.7),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Back to Quiz List
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const QuizListPage()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.list),
          label: const Text('Back to Quiz List'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size.fromHeight(50),
          ),
        ),

        const SizedBox(height: 12),

        // Share Results (placeholder)
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Share feature coming soon!'),
                backgroundColor: Colors.blue,
              ),
            );
          },
          icon: const Icon(Icons.share),
          label: const Text('Share Results'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white24),
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size.fromHeight(50),
          ),
        ),
      ],
    );
  }

  List<Color> _getGradeColors() {
    if (result.scorePercentage >= 90) {
      return [Colors.green.shade600, Colors.green.shade400];
    } else if (result.scorePercentage >= 80) {
      return [Colors.blue.shade600, Colors.blue.shade400];
    } else if (result.scorePercentage >= 70) {
      return [Colors.orange.shade600, Colors.orange.shade400];
    } else if (result.scorePercentage >= 60) {
      return [Colors.deepOrange.shade600, Colors.deepOrange.shade400];
    } else {
      return [Colors.red.shade600, Colors.red.shade400];
    }
  }

  IconData _getPerformanceIcon() {
    if (result.scorePercentage >= 90) {
      return Icons.emoji_events;
    } else if (result.scorePercentage >= 70) {
      return Icons.thumb_up;
    } else if (result.scorePercentage >= 50) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_dissatisfied;
    }
  }
}
