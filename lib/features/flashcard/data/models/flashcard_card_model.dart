import '../../domain/entities/flashcard_card.dart';

class FlashcardCardModel extends FlashcardCard {
  const FlashcardCardModel({
    required super.id,
    required super.deckId,
    required super.kanjiId,
    required super.character,
    super.onyomi,
    super.kunyomi,
    required super.meanings,
    required super.easinessFactor,
    required super.repetitions,
    required super.interval,
    required super.nextReviewAt,
    super.lastReviewedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FlashcardCardModel.fromJson(Map<String, dynamic> json) {
    final kanji = json['kanji'] as Map<String, dynamic>?;

    return FlashcardCardModel(
      id: json['id'] as int,
      deckId: json['deckId'] as int,
      kanjiId: json['kanjiId'] as int,
      character: kanji?['character'] as String? ?? '',
      onyomi: kanji?['onyomi'] as String?,
      kunyomi: kanji?['kunyomi'] as String?,
      meanings: kanji?['meanings'] as String? ?? '',
      easinessFactor: (json['easinessFactor'] as num?)?.toDouble() ?? 2.5,
      repetitions: json['repetitions'] as int? ?? 0,
      interval: json['interval'] as int? ?? 0,
      nextReviewAt: DateTime.parse(json['nextReviewAt'] as String),
      lastReviewedAt: json['lastReviewedAt'] != null
          ? DateTime.parse(json['lastReviewedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deckId': deckId,
      'kanjiId': kanjiId,
      'character': character,
      'onyomi': onyomi,
      'kunyomi': kunyomi,
      'meanings': meanings,
      'easinessFactor': easinessFactor,
      'repetitions': repetitions,
      'interval': interval,
      'nextReviewAt': nextReviewAt.toIso8601String(),
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
