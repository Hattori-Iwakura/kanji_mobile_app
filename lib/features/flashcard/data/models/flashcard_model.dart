import '../../domain/entities/flashcard.dart';

/// Model for Flashcard with JSON serialization
class FlashcardModel extends Flashcard {
  const FlashcardModel({
    required super.id,
    required super.deckId,
    required super.kanjiId,
    required super.front,
    required super.back,
    super.hint,
    super.easeFactor,
    super.interval,
    super.repetitions,
    super.lastReviewedAt,
    super.nextReviewAt,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from JSON
  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] as String,
      deckId: json['deckId'] as String,
      kanjiId: json['kanjiId'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      hint: json['hint'] as String?,
      easeFactor: json['easeFactor'] as int? ?? 2500,
      interval: json['interval'] as int? ?? 0,
      repetitions: json['repetitions'] as int? ?? 0,
      lastReviewedAt: json['lastReviewedAt'] != null
          ? DateTime.parse(json['lastReviewedAt'] as String)
          : null,
      nextReviewAt: json['nextReviewAt'] != null
          ? DateTime.parse(json['nextReviewAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deckId': deckId,
      'kanjiId': kanjiId,
      'front': front,
      'back': back,
      'hint': hint,
      'easeFactor': easeFactor,
      'interval': interval,
      'repetitions': repetitions,
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'nextReviewAt': nextReviewAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert model to entity
  Flashcard toEntity() {
    return Flashcard(
      id: id,
      deckId: deckId,
      kanjiId: kanjiId,
      front: front,
      back: back,
      hint: hint,
      easeFactor: easeFactor,
      interval: interval,
      repetitions: repetitions,
      lastReviewedAt: lastReviewedAt,
      nextReviewAt: nextReviewAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
