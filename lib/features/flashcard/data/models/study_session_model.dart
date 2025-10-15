import '../../domain/entities/study_session.dart';
import 'flashcard_card_model.dart';

class StudySessionModel extends StudySession {
  const StudySessionModel({
    required super.id,
    required super.deckId,
    required super.userId,
    required super.cardsStudied,
    required super.cardsCorrect,
    required super.cardsWrong,
    required super.totalTime,
    required super.completed,
    required super.createAt,
    required super.updateAt,
    super.cards,
  });

  factory StudySessionModel.fromJson(Map<String, dynamic> json) {
    return StudySessionModel(
      id: json['id'] as int,
      deckId: json['deck_id'] as int,
      userId: json['user_id'] as int,
      cardsStudied: json['cards_studied'] as int,
      cardsCorrect: json['cards_correct'] as int,
      cardsWrong: json['cards_wrong'] as int,
      totalTime: json['total_time'] as int,
      completed: json['completed'] as bool,
      createAt: DateTime.parse(json['create_at'] as String),
      updateAt: DateTime.parse(json['update_at'] as String),
      cards: json['cards'] != null
          ? (json['cards'] as List)
                .map((card) => FlashcardCardModel.fromJson(card))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deck_id': deckId,
      'user_id': userId,
      'cards_studied': cardsStudied,
      'cards_correct': cardsCorrect,
      'cards_wrong': cardsWrong,
      'total_time': totalTime,
      'completed': completed,
      'create_at': createAt.toIso8601String(),
      'update_at': updateAt.toIso8601String(),
      'cards': cards
          ?.map((card) => (card as FlashcardCardModel).toJson())
          .toList(),
    };
  }
}
