import '../../domain/entities/flashcard_deck_entity.dart';
import 'flashcard_card.dart';

class FlashcardDeck extends FlashcardDeckEntity {
  final List<FlashcardCard>? cards;

  const FlashcardDeck({
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
    this.cards,
  });

  factory FlashcardDeck.fromJson(Map<String, dynamic> json) {
    return FlashcardDeck(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      userId: json['userId'] as int,
      sourceType: json['sourceType'] as String,
      sourceId: json['sourceId'] as int?,
      isPublic: json['isPublic'] as bool? ?? false,
      totalCards: json['totalCards'] as int? ?? 0,
      cardsDue: json['cardsDue'] as int? ?? 0,
      cardsNew: json['cardsNew'] as int? ?? 0,
      createAt: DateTime.parse(json['createAt'] as String),
      updateAt: DateTime.parse(json['updateAt'] as String),
      cards: json['cards'] != null
          ? (json['cards'] as List<dynamic>)
                .map(
                  (cardJson) =>
                      FlashcardCard.fromJson(cardJson as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'userId': userId,
      'sourceType': sourceType,
      'sourceId': sourceId,
      'isPublic': isPublic,
      'totalCards': totalCards,
      'cardsDue': cardsDue,
      'cardsNew': cardsNew,
      'createAt': createAt.toIso8601String(),
      'updateAt': updateAt.toIso8601String(),
      if (cards != null) 'cards': cards!.map((card) => card.toJson()).toList(),
    };
  }

  FlashcardDeckEntity toEntity() {
    return FlashcardDeckEntity(
      id: id,
      name: name,
      description: description,
      userId: userId,
      sourceType: sourceType,
      sourceId: sourceId,
      isPublic: isPublic,
      totalCards: totalCards,
      cardsDue: cardsDue,
      cardsNew: cardsNew,
      createAt: createAt,
      updateAt: updateAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, cards];
}
