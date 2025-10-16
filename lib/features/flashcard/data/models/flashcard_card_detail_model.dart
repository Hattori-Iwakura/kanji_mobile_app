import '../../domain/entities/flashcard_card_detail.dart';
import 'flashcard_card_model.dart';
import 'flashcard_review_model.dart';

class FlashcardCardDetailModel extends FlashcardCardDetail {
  FlashcardCardDetailModel({
    required FlashcardCardModel card,
    required FlashcardCardStats stats,
    required List<FlashcardReviewModel> reviews,
  }) : super(card: card, stats: stats, reviews: reviews);

  factory FlashcardCardDetailModel.fromJson(Map<String, dynamic> json) {
    final cardJson = json['card'] as Map<String, dynamic>;
    final statsJson = json['stats'] as Map<String, dynamic>;

    final reviews = (cardJson['Reviews'] as List? ?? [])
        .map((review) => FlashcardReviewModel.fromJson(review))
        .toList();

    return FlashcardCardDetailModel(
      card: FlashcardCardModel.fromJson(cardJson),
      stats: FlashcardCardStats(
        totalReviews: statsJson['totalReviews'] as int,
        correctReviews: statsJson['correctReviews'] as int,
        accuracy: statsJson['accuracy'] as int,
        lastReviewedAt: statsJson['lastReviewedAt'] != null
            ? DateTime.parse(statsJson['lastReviewedAt'] as String)
            : null,
      ),
      reviews: reviews,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card': (card as FlashcardCardModel).toJson(),
      'stats': {
        'totalReviews': stats.totalReviews,
        'correctReviews': stats.correctReviews,
        'accuracy': stats.accuracy,
        'lastReviewedAt': stats.lastReviewedAt?.toIso8601String(),
      },
      'reviews': reviews
          .map((review) => (review as FlashcardReviewModel).toJson())
          .toList(),
    };
  }
}
