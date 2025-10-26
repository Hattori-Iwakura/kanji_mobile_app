import 'package:equatable/equatable.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../kanji/data/models/kanji_model.dart';

/// Flashcard Card model (new backend structure)
class FlashcardCardNewModel extends Equatable {
  final int id;
  final int deckId;
  final int kanjiId;
  final String front;
  final String back;
  final KanjiModel kanji;

  const FlashcardCardNewModel({
    required this.id,
    required this.deckId,
    required this.kanjiId,
    required this.front,
    required this.back,
    required this.kanji,
  });

  factory FlashcardCardNewModel.fromJson(Map<String, dynamic> json) {
    return FlashcardCardNewModel(
      id: json['id'] as int,
      deckId: json['deckId'] as int,
      kanjiId: json['kanjiId'] as int,
      front: json['front'] as String,
      back: json['back'] as String,
      kanji: KanjiModel.fromJson(json['kanji'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deckId': deckId,
      'kanjiId': kanjiId,
      'front': front,
      'back': back,
      'kanji': kanji.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, deckId, kanjiId, front, back, kanji];
}

/// Flashcard Deck model (new backend structure)
class FlashcardDeckNewModel extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int userId;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<FlashcardCardNewModel> cards;
  final UserModel user;

  const FlashcardDeckNewModel({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    required this.cards,
    required this.user,
  });

  factory FlashcardDeckNewModel.fromJson(Map<String, dynamic> json) {
    return FlashcardDeckNewModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      userId: json['userId'] as int,
      isPublic: json['isPublic'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      cards: (json['cards'] as List)
          .map(
            (card) =>
                FlashcardCardNewModel.fromJson(card as Map<String, dynamic>),
          )
          .toList(),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'userId': userId,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'cards': cards.map((card) => card.toJson()).toList(),
      'user': user.toJson(),
    };
  }

  /// Get total number of cards in deck
  int get totalCards => cards.length;

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
    user,
  ];
}

/// Response wrapper for deck list
class FlashcardDecksResponse extends Equatable {
  final List<FlashcardDeckNewModel> data;
  final int total;
  final int limit;
  final int offset;

  const FlashcardDecksResponse({
    required this.data,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory FlashcardDecksResponse.fromJson(Map<String, dynamic> json) {
    return FlashcardDecksResponse(
      data: (json['data'] as List)
          .map(
            (deck) =>
                FlashcardDeckNewModel.fromJson(deck as Map<String, dynamic>),
          )
          .toList(),
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
    );
  }

  @override
  List<Object?> get props => [data, total, limit, offset];
}
