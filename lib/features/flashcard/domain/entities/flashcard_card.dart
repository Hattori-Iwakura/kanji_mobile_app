import 'package:equatable/equatable.dart';

class FlashcardCard extends Equatable {
  final int id;
  final int deckId;
  final int kanjiId;
  final String frontContent;
  final Map<String, dynamic> backContent;
  final int difficulty;
  final DateTime nextReviewAt;
  final int intervalDays;
  final double easeFactor;
  final int repetitions;
  final DateTime? lastReviewedAt;
  final bool isNew;
  final DateTime createAt;
  final DateTime updateAt;

  const FlashcardCard({
    required this.id,
    required this.deckId,
    required this.kanjiId,
    required this.frontContent,
    required this.backContent,
    required this.difficulty,
    required this.nextReviewAt,
    required this.intervalDays,
    required this.easeFactor,
    required this.repetitions,
    this.lastReviewedAt,
    required this.isNew,
    required this.createAt,
    required this.updateAt,
  });

  @override
  List<Object?> get props => [
    id,
    deckId,
    kanjiId,
    frontContent,
    backContent,
    difficulty,
    nextReviewAt,
    intervalDays,
    easeFactor,
    repetitions,
    lastReviewedAt,
    isNew,
    createAt,
    updateAt,
  ];
}
