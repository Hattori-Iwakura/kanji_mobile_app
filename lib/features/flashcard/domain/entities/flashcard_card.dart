import 'package:equatable/equatable.dart';

class FlashcardCard extends Equatable {
  final int id;
  final int deckId;
  final int kanjiId;
  final String character;
  final String? onyomi;
  final String? kunyomi;
  final String meanings;
  final double easinessFactor;
  final int repetitions;
  final int interval;
  final DateTime nextReviewAt;
  final DateTime? lastReviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FlashcardCard({
    required this.id,
    required this.deckId,
    required this.kanjiId,
    required this.character,
    this.onyomi,
    this.kunyomi,
    required this.meanings,
    required this.easinessFactor,
    required this.repetitions,
    required this.interval,
    required this.nextReviewAt,
    this.lastReviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    deckId,
    kanjiId,
    character,
    onyomi,
    kunyomi,
    meanings,
    easinessFactor,
    repetitions,
    interval,
    nextReviewAt,
    lastReviewedAt,
    createdAt,
    updatedAt,
  ];
}
