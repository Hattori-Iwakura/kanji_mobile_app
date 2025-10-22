import 'package:equatable/equatable.dart';

/// Entity representing a deck of flashcards
class FlashcardDeck extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final int totalCards;
  final int newCards;
  final int dueCards;
  final int masteredCards;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FlashcardDeck({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.totalCards = 0,
    this.newCards = 0,
    this.dueCards = 0,
    this.masteredCards = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    description,
    totalCards,
    newCards,
    dueCards,
    masteredCards,
    createdAt,
    updatedAt,
  ];

  /// Get progress percentage (0-100)
  double get progressPercentage {
    if (totalCards == 0) return 0.0;
    return (masteredCards / totalCards) * 100;
  }

  /// Check if deck has cards to review
  bool get hasCardsToReview => dueCards > 0 || newCards > 0;

  /// Get total cards to review today
  int get todayReviewCount => dueCards + newCards;
}
