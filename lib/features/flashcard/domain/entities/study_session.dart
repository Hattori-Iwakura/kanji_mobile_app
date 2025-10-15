import 'package:equatable/equatable.dart';
import 'flashcard_card.dart';

class StudySession extends Equatable {
  final int id;
  final int deckId;
  final int userId;
  final int cardsStudied;
  final int cardsCorrect;
  final int cardsWrong;
  final int totalTime;
  final bool completed;
  final DateTime createAt;
  final DateTime updateAt;
  final List<FlashcardCard>? cards;

  const StudySession({
    required this.id,
    required this.deckId,
    required this.userId,
    required this.cardsStudied,
    required this.cardsCorrect,
    required this.cardsWrong,
    required this.totalTime,
    required this.completed,
    required this.createAt,
    required this.updateAt,
    this.cards,
  });

  @override
  List<Object?> get props => [
    id,
    deckId,
    userId,
    cardsStudied,
    cardsCorrect,
    cardsWrong,
    totalTime,
    completed,
    createAt,
    updateAt,
    cards,
  ];
}
