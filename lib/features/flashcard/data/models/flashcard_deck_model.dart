import '../../domain/entities/flashcard_deck.dart';

class FlashcardDeckModel extends FlashcardDeck {
  const FlashcardDeckModel({
    required super.id,
    required super.name,
    super.description,
    required super.userId,
    required super.sourceType,
    super.sourceId,
    required super.isPublic,
    required super.totalCards,
    required super.cardsDue,
    required super.cardsNew,
    required super.createAt,
    required super.updateAt,
  });

  factory FlashcardDeckModel.fromJson(Map<String, dynamic> json) {
    return FlashcardDeckModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      userId: json['user_id'] as int,
      sourceType: json['source_type'] as String,
      sourceId: json['source_id'] as int?,
      isPublic: json['is_public'] as bool,
      totalCards: json['total_cards'] as int,
      cardsDue: json['cards_due'] as int,
      cardsNew: json['cards_new'] as int,
      createAt: DateTime.parse(json['create_at'] as String),
      updateAt: DateTime.parse(json['update_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'user_id': userId,
      'source_type': sourceType,
      'source_id': sourceId,
      'is_public': isPublic,
      'total_cards': totalCards,
      'cards_due': cardsDue,
      'cards_new': cardsNew,
      'create_at': createAt.toIso8601String(),
      'update_at': updateAt.toIso8601String(),
    };
  }
}
