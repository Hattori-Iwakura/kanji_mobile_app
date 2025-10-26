import 'package:kanji_mobile_v1/features/flashcard/domain/entities/flashcard.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/entities/flashcard_deck.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/entities/flashcard_deck_new.dart';

// Flashcard Deck Fixtures
final tFlashcardDeck1 = FlashcardDeck(
  id: 'deck-1',
  userId: 'user-1',
  name: 'JLPT N5 Kanji',
  description: 'Basic kanji for N5 level',
  totalCards: 80,
  newCards: 20,
  dueCards: 15,
  masteredCards: 45,
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 15),
);

final tFlashcardDeck2 = FlashcardDeck(
  id: 'deck-2',
  userId: 'user-1',
  name: 'JLPT N4 Kanji',
  description: 'Intermediate kanji for N4 level',
  totalCards: 150,
  newCards: 50,
  dueCards: 30,
  masteredCards: 70,
  createdAt: DateTime(2024, 2, 1),
  updatedAt: DateTime(2024, 2, 15),
);

final tFlashcardDeck3 = FlashcardDeck(
  id: 'deck-3',
  userId: 'user-1',
  name: 'Common Verbs',
  description: 'Frequently used verbs',
  totalCards: 50,
  newCards: 0,
  dueCards: 5,
  masteredCards: 45,
  createdAt: DateTime(2024, 3, 1),
  updatedAt: DateTime(2024, 3, 15),
);

final tEmptyDeck = FlashcardDeck(
  id: 'deck-empty',
  userId: 'user-1',
  name: 'Empty Deck',
  description: 'A deck with no cards',
  totalCards: 0,
  newCards: 0,
  dueCards: 0,
  masteredCards: 0,
  createdAt: DateTime(2024, 4, 1),
  updatedAt: DateTime(2024, 4, 1),
);

// Flashcard Fixtures
final tFlashcard1 = Flashcard(
  id: 'card-1',
  deckId: 'deck-1',
  kanjiId: 'kanji-1',
  front: '日',
  back: 'sun, day',
  hint: 'Looks like the sun',
  easeFactor: 2500, // 2.5
  interval: 7,
  repetitions: 3,
  lastReviewedAt: DateTime(2024, 1, 10),
  nextReviewAt: DateTime(2024, 1, 17),
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 10),
);

final tFlashcard2 = Flashcard(
  id: 'card-2',
  deckId: 'deck-1',
  kanjiId: 'kanji-2',
  front: '月',
  back: 'moon, month',
  hint: 'Crescent moon shape',
  easeFactor: 2300,
  interval: 3,
  repetitions: 2,
  lastReviewedAt: DateTime(2024, 1, 12),
  nextReviewAt: DateTime(2024, 1, 15),
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 12),
);

final tNewFlashcard = Flashcard(
  id: 'card-new',
  deckId: 'deck-1',
  kanjiId: 'kanji-3',
  front: '火',
  back: 'fire',
  easeFactor: 2500,
  interval: 0,
  repetitions: 0,
  lastReviewedAt: null,
  nextReviewAt: null,
  createdAt: DateTime(2024, 1, 15),
  updatedAt: DateTime(2024, 1, 15),
);

final tDueFlashcard = Flashcard(
  id: 'card-due',
  deckId: 'deck-1',
  kanjiId: 'kanji-4',
  front: '水',
  back: 'water',
  easeFactor: 2400,
  interval: 5,
  repetitions: 2,
  lastReviewedAt: DateTime(2024, 1, 5),
  nextReviewAt: DateTime(2024, 1, 10), // Past date - due for review
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 5),
);

final tMasteredFlashcard = Flashcard(
  id: 'card-mastered',
  deckId: 'deck-1',
  kanjiId: 'kanji-5',
  front: '木',
  back: 'tree, wood',
  easeFactor: 2500,
  interval: 30,
  repetitions: 8,
  lastReviewedAt: DateTime(2024, 1, 1),
  nextReviewAt: DateTime(2024, 2, 1),
  createdAt: DateTime(2023, 12, 1),
  updatedAt: DateTime(2024, 1, 1),
);

// Lists
final tFlashcardDeckList = [tFlashcardDeck1, tFlashcardDeck2, tFlashcardDeck3];
final tFlashcardList = [tFlashcard1, tFlashcard2, tNewFlashcard, tDueFlashcard];
final tDueFlashcardList = [tDueFlashcard, tNewFlashcard];

// ============================================
// NEW BACKEND ENTITIES (FlashcardDeckNew)
// ============================================

final tFlashcardDeckNew1 = FlashcardDeckNew(
  id: 1,
  name: 'JLPT N5 Kanji',
  description: 'Basic kanji for JLPT N5',
  userId: 1,
  isPublic: false,
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 15),
  cards: const [],
  userName: 'testuser',
  userEmail: 'test@example.com',
);

final tFlashcardDeckNew2 = FlashcardDeckNew(
  id: 2,
  name: 'JLPT N4 Kanji',
  description: 'Intermediate kanji for JLPT N4',
  userId: 1,
  isPublic: true,
  createdAt: DateTime(2024, 2, 1),
  updatedAt: DateTime(2024, 2, 15),
  cards: const [],
  userName: 'testuser',
  userEmail: 'test@example.com',
);

final tFlashcardDeckNew3 = FlashcardDeckNew(
  id: 3,
  name: 'Common Verbs',
  description: null,
  userId: 1,
  isPublic: false,
  createdAt: DateTime(2024, 3, 1),
  updatedAt: DateTime(2024, 3, 15),
  cards: const [],
  userName: 'testuser',
  userEmail: 'test@example.com',
);

final tFlashcardDeckNewList = [
  tFlashcardDeckNew1,
  tFlashcardDeckNew2,
  tFlashcardDeckNew3,
];
