import 'package:equatable/equatable.dart';
import 'flashcard_card.dart';
import 'flashcard_review.dart';

class FlashcardCardStats extends Equatable {
  final int totalReviews;
  final int correctReviews;
  final int accuracy;
  final DateTime? lastReviewedAt;

  const FlashcardCardStats({
    required this.totalReviews,
    required this.correctReviews,
    required this.accuracy,
    this.lastReviewedAt,
  });

  @override
  List<Object?> get props => [
    totalReviews,
    correctReviews,
    accuracy,
    lastReviewedAt,
  ];
}

class FlashcardCardDetail extends Equatable {
  final FlashcardCard card;
  final FlashcardCardStats stats;
  final List<FlashcardReview> reviews;

  const FlashcardCardDetail({
    required this.card,
    required this.stats,
    required this.reviews,
  });

  @override
  List<Object?> get props => [card, stats, reviews];
}
