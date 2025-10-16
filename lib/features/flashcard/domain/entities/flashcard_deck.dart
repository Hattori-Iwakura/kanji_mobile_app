import 'package:equatable/equatable.dart';
import 'flashcard_card.dart';

class FlashcardDeck extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int userId;
  final String sourceType;
  final int? sourceId;
  final bool isPublic;
  final int totalCards;
  final int cardsDue;
  final int cardsNew;
  final DateTime createAt;
  final DateTime updateAt;
  final List<FlashcardCard>? cards;

  const FlashcardDeck({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    required this.sourceType,
    this.sourceId,
    required this.isPublic,
    required this.totalCards,
    required this.cardsDue,
    required this.cardsNew,
    required this.createAt,
    required this.updateAt,
    this.cards,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    userId,
    sourceType,
    sourceId,
    isPublic,
    totalCards,
    cardsDue,
    cardsNew,
    createAt,
    updateAt,
    cards,
  ];
}
