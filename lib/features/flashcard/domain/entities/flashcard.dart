import 'package:equatable/equatable.dart';

/// Entity representing a single flashcard
class Flashcard extends Equatable {
  final String id;
  final String deckId;
  final String kanjiId;
  final String front; // Kanji character
  final String back; // Meaning or reading
  final String? hint;
  final int easeFactor; // SM-2 algorithm: 1.3 - 2.5+
  final int interval; // Days until next review
  final int repetitions; // Number of successful reviews
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Flashcard({
    required this.id,
    required this.deckId,
    required this.kanjiId,
    required this.front,
    required this.back,
    this.hint,
    this.easeFactor = 2500, // Default 2.5 * 1000 (stored as int)
    this.interval = 0,
    this.repetitions = 0,
    this.lastReviewedAt,
    this.nextReviewAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    deckId,
    kanjiId,
    front,
    back,
    hint,
    easeFactor,
    interval,
    repetitions,
    lastReviewedAt,
    nextReviewAt,
    createdAt,
    updatedAt,
  ];

  /// Get ease factor as double (2.5 from 2500)
  double get easeFactorDouble => easeFactor / 1000.0;

  /// Check if card is due for review
  bool get isDue {
    if (nextReviewAt == null) return true;
    return DateTime.now().isAfter(nextReviewAt!);
  }

  /// Check if card is new (never reviewed)
  bool get isNew => repetitions == 0;

  /// Calculate next review date based on quality (0-5)
  /// SM-2 Algorithm implementation
  Flashcard calculateNextReview(int quality) {
    assert(quality >= 0 && quality <= 5, 'Quality must be between 0 and 5');

    int newEaseFactor = easeFactor;
    int newInterval = interval;
    int newRepetitions = repetitions;

    if (quality < 3) {
      // Failed - reset to beginning
      newRepetitions = 0;
      newInterval = 1;
    } else {
      // Successful review
      if (repetitions == 0) {
        newInterval = 1;
      } else if (repetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (interval * (easeFactorDouble)).round();
      }
      newRepetitions = repetitions + 1;

      // Update ease factor: EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
      final double efChange =
          0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02);
      newEaseFactor = ((easeFactorDouble + efChange) * 1000).round().clamp(
        1300,
        2500,
      );
    }

    final now = DateTime.now();
    final nextReview = now.add(Duration(days: newInterval));

    return Flashcard(
      id: id,
      deckId: deckId,
      kanjiId: kanjiId,
      front: front,
      back: back,
      hint: hint,
      easeFactor: newEaseFactor,
      interval: newInterval,
      repetitions: newRepetitions,
      lastReviewedAt: now,
      nextReviewAt: nextReview,
      createdAt: createdAt,
      updatedAt: now,
    );
  }
}
