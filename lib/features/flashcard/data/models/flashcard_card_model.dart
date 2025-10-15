import 'dart:convert';
import '../../domain/entities/flashcard_card.dart';

class FlashcardCardModel extends FlashcardCard {
  const FlashcardCardModel({
    required super.id,
    required super.deckId,
    required super.kanjiId,
    required super.frontContent,
    required super.backContent,
    required super.difficulty,
    required super.nextReviewAt,
    required super.intervalDays,
    required super.easeFactor,
    required super.repetitions,
    super.lastReviewedAt,
    required super.isNew,
    required super.createAt,
    required super.updateAt,
  });

  factory FlashcardCardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardCardModel(
      id: json['id'] as int,
      deckId: json['deck_id'] as int,
      kanjiId: json['kanji_id'] as int,
      frontContent: json['front_content'] as String,
      backContent: json['back_content'] is String
          ? jsonDecode(json['back_content'] as String)
          : json['back_content'] as Map<String, dynamic>,
      difficulty: json['difficulty'] as int,
      nextReviewAt: DateTime.parse(json['next_review_at'] as String),
      intervalDays: json['interval_days'] as int,
      easeFactor: (json['ease_factor'] as num).toDouble(),
      repetitions: json['repetitions'] as int,
      lastReviewedAt: json['last_reviewed_at'] != null
          ? DateTime.parse(json['last_reviewed_at'] as String)
          : null,
      isNew: json['is_new'] as bool,
      createAt: DateTime.parse(json['create_at'] as String),
      updateAt: DateTime.parse(json['update_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deck_id': deckId,
      'kanji_id': kanjiId,
      'front_content': frontContent,
      'back_content': jsonEncode(backContent),
      'difficulty': difficulty,
      'next_review_at': nextReviewAt.toIso8601String(),
      'interval_days': intervalDays,
      'ease_factor': easeFactor,
      'repetitions': repetitions,
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
      'is_new': isNew,
      'create_at': createAt.toIso8601String(),
      'update_at': updateAt.toIso8601String(),
    };
  }
}
