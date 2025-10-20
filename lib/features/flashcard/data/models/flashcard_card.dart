import '../../domain/entities/flashcard_card_entity.dart';

class FlashcardCard extends FlashcardCardEntity {
  const FlashcardCard({
    required super.id,
    required super.deckId,
    required super.kanjiId,
    required super.frontContent,
    required super.backContent,
    required super.difficulty,
    required super.orderIndex,
    required super.nextReviewAt,
    required super.intervalDays,
    required super.easeFactor,
    required super.repetitions,
    super.lastReviewedAt,
    required super.isNew,
    required super.createAt,
    required super.updateAt,
  });

  factory FlashcardCard.fromJson(Map<String, dynamic> json) {
    return FlashcardCard(
      id: json['id'] as int,
      deckId: json['deckId'] as int,
      kanjiId: json['kanjiId'] as int,
      frontContent: json['frontContent'] as String,
      backContent: json['backContent'] as Map<String, dynamic>,
      difficulty: json['difficulty'] as int? ?? 0,
      orderIndex: json['orderIndex'] as int? ?? 0,
      nextReviewAt: DateTime.parse(json['nextReviewAt'] as String),
      intervalDays: json['intervalDays'] as int? ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      repetitions: json['repetitions'] as int? ?? 0,
      lastReviewedAt: json['lastReviewedAt'] != null
          ? DateTime.parse(json['lastReviewedAt'] as String)
          : null,
      isNew: json['isNew'] as bool? ?? true,
      createAt: DateTime.parse(json['createAt'] as String),
      updateAt: DateTime.parse(json['updateAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deckId': deckId,
      'kanjiId': kanjiId,
      'frontContent': frontContent,
      'backContent': backContent,
      'difficulty': difficulty,
      'orderIndex': orderIndex,
      'nextReviewAt': nextReviewAt.toIso8601String(),
      'intervalDays': intervalDays,
      'easeFactor': easeFactor,
      'repetitions': repetitions,
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'isNew': isNew,
      'createAt': createAt.toIso8601String(),
      'updateAt': updateAt.toIso8601String(),
    };
  }

  FlashcardCardEntity toEntity() {
    return FlashcardCardEntity(
      id: id,
      deckId: deckId,
      kanjiId: kanjiId,
      frontContent: frontContent,
      backContent: backContent,
      difficulty: difficulty,
      orderIndex: orderIndex,
      nextReviewAt: nextReviewAt,
      intervalDays: intervalDays,
      easeFactor: easeFactor,
      repetitions: repetitions,
      lastReviewedAt: lastReviewedAt,
      isNew: isNew,
      createAt: createAt,
      updateAt: updateAt,
    );
  }
}
