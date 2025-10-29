import 'package:equatable/equatable.dart';

class NextCard extends Equatable {
  final int cardId;
  final int kanjiId;
  final String character;
  final String meaning;
  final String onyomi;
  final String kunyomi;
  final bool isNew;
  final int currentCard;
  final int totalCards;

  const NextCard({
    required this.cardId,
    required this.kanjiId,
    required this.character,
    required this.meaning,
    required this.onyomi,
    required this.kunyomi,
    required this.isNew,
    required this.currentCard,
    required this.totalCards,
  });

  @override
  List<Object?> get props => [
    cardId,
    kanjiId,
    character,
    meaning,
    onyomi,
    kunyomi,
    isNew,
    currentCard,
    totalCards,
  ];
}
