import '../../domain/entities/flashcard_deck.dart';
import 'flashcard_card_model.dart';

class FlashcardDeckModel extends FlashcardDeck {
  const FlashcardDeckModel({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    required super.isPublic,
    required super.createdAt,
    required super.updatedAt,
    super.cards,
    super.totalCards,
    super.dueCards,
  });

  factory FlashcardDeckModel.fromJson(Map<String, dynamic> json) {
    return FlashcardDeckModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isPublic: json['isPublic'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      cards: json['cards'] != null
          ? (json['cards'] as List)
                .map(
                  (e) => FlashcardCardModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      totalCards: json['totalCards'] as int?,
      dueCards: json['dueCards'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (cards != null)
        'cards': cards!.map((e) => (e as FlashcardCardModel).toJson()).toList(),
      if (totalCards != null) 'totalCards': totalCards,
      if (dueCards != null) 'dueCards': dueCards,
    };
  }
}
