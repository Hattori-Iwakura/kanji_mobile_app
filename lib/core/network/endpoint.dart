import '../config/env_config.dart';

class ApiEndpoints {
  // Use environment variable for base URL
  static String get baseUrl => "${EnvConfig.apiBaseUrl}/api";

  // Auth endpoints - aligned with new backend
  static String get login => "$baseUrl/auth/login";
  static String get register => "$baseUrl/auth/register";
  static String get profile => "$baseUrl/auth/profile";

  // Kanji endpoints
  static String get kanji => "$baseUrl/kanji";
  static String kanjiById(int id) => "$baseUrl/kanji/$id";
  static String kanjiByCharacter(String character) =>
      "$baseUrl/kanji/character/$character";

  // Kanji List endpoints
  static String get kanjiLists => "$baseUrl/kanji-lists";
  static String kanjiListById(int id) => "$baseUrl/kanji-lists/$id";
  static String addKanjiToList(int listId, int kanjiId) =>
      "$baseUrl/kanji-lists/$listId/kanji/$kanjiId";
  static String removeKanjiFromList(int listId, int kanjiId) =>
      "$baseUrl/kanji-lists/$listId/kanji/$kanjiId";
  static String publishKanjiList(int listId) =>
      "$baseUrl/kanji-lists/$listId/publish";

  // Flashcard endpoints
  static String get flashcardDecks => "$baseUrl/flashcard-decks";
  static String flashcardDeckById(int id) => "$baseUrl/flashcard-decks/$id";
  static String addCardToDeck(int deckId) =>
      "$baseUrl/flashcard-decks/$deckId/cards";
  static String removeCardFromDeck(int deckId, int cardId) =>
      "$baseUrl/flashcard-decks/$deckId/cards/$cardId";

  // Quiz endpoints
  static String get quizzes => "$baseUrl/quizzes";
  static String quizById(int id) => "$baseUrl/quizzes/$id";

  // Kanji Recognition (preserved) - Use environment variable
  static String get kanjiRecognition =>
      "${EnvConfig.aiModelUrl}/api/v1/recognize";
}
