/// Route names for the application
class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';

  // Main routes
  static const String home = '/home';
  static const String profile = '/profile';

  // Debug routes
  static const String debugSettings = '/debug-settings';

  // Kanji routes
  static const String kanjiDictionary = '/kanji-dictionary';
  static const String kanjiDetail = '/kanji-detail';
  static const String kanjiEdit = '/kanji-edit';
  static const String kanjiCreate = '/kanji-create';

  // Kanji List routes
  static const String kanjiLists = '/kanji-lists';
  static const String kanjiListDetail = '/kanji-list-detail';
  static const String kanjiListCreate = '/kanji-list-create';
  static const String kanjiListEdit = '/kanji-list-edit';

  // Search routes
  static const String search = '/search';

  // Flashcard routes
  static const String flashcardDecks = '/flashcard-decks';
  static const String flashcardStudy = '/flashcard-study';
  static const String flashcardDeckDetail = '/flashcard-deck-detail';

  // Quiz routes
  static const String quizList = '/quiz-list';
  static const String quizDetail = '/quiz-detail';
  static const String quizSession = '/quiz-session';

  // Admin routes
  static const String adminDashboard = '/admin-dashboard';
  static const String adminUsers = '/admin-users';
  static const String adminKanji = '/admin-kanji';
  static const String adminQuizzes = '/admin-quizzes';
}
