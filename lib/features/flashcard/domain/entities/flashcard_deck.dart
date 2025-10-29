import 'package:equatable/equatable.dart';
import 'flashcard_card.dart';

class FlashcardDeck extends Equatable {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<FlashcardCard>? cards;
  final int? totalCards;
  final int? dueCards;

  const FlashcardDeck({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    this.cards,
    this.totalCards,
    this.dueCards,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    description,
    isPublic,
    createdAt,
    updatedAt,
    cards,
    totalCards,
    dueCards,
  ];
}
