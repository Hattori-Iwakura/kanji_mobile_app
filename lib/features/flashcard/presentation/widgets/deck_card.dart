import 'package:flutter/material.dart';
import '../../domain/entities/flashcard_deck.dart';

/// Widget displaying a single flashcard deck with stats
class DeckCard extends StatelessWidget {
  final FlashcardDeck deck;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DeckCard({
    super.key,
    required this.deck,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = deck.progressPercentage;
    final hasDueCards = deck.dueCards > 0;

    return Card(
      color: const Color(0xFF1A1A1A),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasDueCards
            ? const BorderSide(color: Colors.orange, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and delete button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      deck.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              // Description
              if (deck.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(
                  deck.description!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 16),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatChip(
                    label: 'Total',
                    value: deck.totalCards,
                    icon: Icons.style,
                    color: Colors.blue,
                  ),
                  _buildStatChip(
                    label: 'Due',
                    value: deck.dueCards,
                    icon: Icons.alarm,
                    color: Colors.orange,
                  ),
                  _buildStatChip(
                    label: 'New',
                    value: deck.newCards,
                    icon: Icons.new_releases,
                    color: Colors.green,
                  ),
                  _buildStatChip(
                    label: 'Mastered',
                    value: deck.masteredCards,
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${progressPercent.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPercent / 100,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(progressPercent),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Study button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: deck.hasCardsToReview ? onTap : null,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    deck.hasCardsToReview ? 'Study Now' : 'No Cards to Review',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deck.hasCardsToReview
                        ? Colors.white
                        : Colors.grey,
                    foregroundColor: deck.hasCardsToReview
                        ? Colors.black
                        : Colors.white54,
                    disabledBackgroundColor: Colors.grey.shade800,
                    disabledForegroundColor: Colors.white38,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 25) return Colors.red;
    if (progress < 50) return Colors.orange;
    if (progress < 75) return Colors.yellow;
    return Colors.green;
  }
}
