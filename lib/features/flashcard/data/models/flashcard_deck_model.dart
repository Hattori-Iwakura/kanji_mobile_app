import '../../domain/entities/flashcard_deck.dart';

/// Model for FlashcardDeck with JSON serialization
class FlashcardDeckModel extends FlashcardDeck {
  const FlashcardDeckModel({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    super.totalCards,
    super.newCards,
    super.dueCards,
    super.masteredCards,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from JSON
  factory FlashcardDeckModel.fromJson(Map<String, dynamic> json) {
    return FlashcardDeckModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      totalCards: json['totalCards'] as int? ?? 0,
      newCards: json['newCards'] as int? ?? 0,
      dueCards: json['dueCards'] as int? ?? 0,
      masteredCards: json['masteredCards'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'totalCards': totalCards,
      'newCards': newCards,
      'dueCards': dueCards,
      'masteredCards': masteredCards,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert model to entity
  FlashcardDeck toEntity() {
    return FlashcardDeck(
      id: id,
      userId: userId,
      name: name,
      description: description,
      totalCards: totalCards,
      newCards: newCards,
      dueCards: dueCards,
      masteredCards: masteredCards,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
