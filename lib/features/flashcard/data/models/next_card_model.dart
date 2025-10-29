import '../../domain/entities/next_card.dart';

class NextCardModel extends NextCard {
  const NextCardModel({
    required super.cardId,
    required super.kanjiId,
    required super.character,
    required super.meaning,
    required super.onyomi,
    required super.kunyomi,
    required super.isNew,
    required super.currentCard,
    required super.totalCards,
  });

  factory NextCardModel.fromJson(Map<String, dynamic> json) {
    return NextCardModel(
      cardId: json['cardId'] as int,
      kanjiId: json['kanjiId'] as int,
      character: json['character'] as String,
      meaning: json['meaning'] as String,
      onyomi: json['onyomi'] as String? ?? '',
      kunyomi: json['kunyomi'] as String? ?? '',
      isNew: json['isNew'] as bool,
      currentCard: json['currentCard'] as int,
      totalCards: json['totalCards'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'kanjiId': kanjiId,
      'character': character,
      'meaning': meaning,
      'onyomi': onyomi,
      'kunyomi': kunyomi,
      'isNew': isNew,
      'currentCard': currentCard,
      'totalCards': totalCards,
    };
  }
}
