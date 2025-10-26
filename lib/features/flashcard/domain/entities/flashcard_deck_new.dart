import 'package:equatable/equatable.dart';
import '../../../kanji/domain/entities/kanji.dart';

/// Flashcard Card entity
class FlashcardCardNew extends Equatable {
  final int id;
  final int deckId;
  final int kanjiId;
  final String front;
  final String back;
  final Kanji kanji;

  const FlashcardCardNew({
    required this.id,
    required this.deckId,
    required this.kanjiId,
    required this.front,
    required this.back,
    required this.kanji,
  });

  @override
  List<Object?> get props => [id, deckId, kanjiId, front, back, kanji];
}

/// Flashcard Deck entity
class FlashcardDeckNew extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int userId;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<FlashcardCardNew> cards;
  final String userName;
  final String? userEmail;

  const FlashcardDeckNew({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    required this.cards,
    required this.userName,
    this.userEmail,
  });

  /// Get total number of cards in deck
  int get totalCards => cards.length;

  /// Check if deck belongs to user
  bool isOwnedBy(int userId) => this.userId == userId;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    userId,
    isPublic,
    createdAt,
    updatedAt,
    cards,
    userName,
    userEmail,
  ];
}
