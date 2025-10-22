class ApiEndpoints {
  // Base URLs - loaded from .env
  static late String baseUrl;
  static late String aiModelUrl;

  // Initialize from environment
  static void init(String apiBaseUrl, String modelUrl) {
    baseUrl = apiBaseUrl;
    aiModelUrl = modelUrl;
  }

  // Auth Endpoints
  static String get login => '$baseUrl/api/auth/login';
  static String get register => '$baseUrl/api/auth/register';
  static String get refreshToken => '$baseUrl/api/auth/refresh';
  static String get forgotPassword => '$baseUrl/api/auth/forgot-password';
  static String get resetPassword => '$baseUrl/api/auth/reset-password';
  static String get verify2FA => '$baseUrl/api/auth/verify-2fa';
  static String get enable2FA => '$baseUrl/api/auth/enable-2fa';
  static String get googleLogin => '$baseUrl/api/auth/google';
  static String get facebookLogin => '$baseUrl/api/auth/facebook';
  static String get logout => '$baseUrl/api/auth/logout';

  // Kanji Endpoints
  static String get kanji => '$baseUrl/api/kanji';
  static String kanjiDetail(int id) => '$baseUrl/api/kanji/$id';
  static String get searchKanji => '$baseUrl/api/kanji/search';
  static String get favoriteKanji => '$baseUrl/api/kanji/favorites';

  // Kanji List Endpoints
  static String get kanjiLists => '$baseUrl/api/kanji-lists';
  static String kanjiListDetail(int id) => '$baseUrl/api/kanji-lists/$id';
  static String get userKanjiLists => '$baseUrl/api/kanji-lists/user';
  static String get publicKanjiLists => '$baseUrl/api/kanji-lists/public';

  // Flashcard Endpoints
  static String get flashcards => '$baseUrl/api/flashcards';
  static String flashcardDetail(int id) => '$baseUrl/api/flashcards/$id';
  static String get userFlashcards => '$baseUrl/api/flashcards/user';
  static String get flashcardDecks => '$baseUrl/api/flashcards/decks';
  static String get studySession => '$baseUrl/api/flashcards/study-session';
  static String updateCardProgress(int cardId) =>
      '$baseUrl/api/flashcards/$cardId/progress';

  // Quiz Endpoints
  static String get quizzes => '$baseUrl/api/quizzes';
  static String quizDetail(int id) => '$baseUrl/api/quizzes/$id';
  static String get userQuizzes => '$baseUrl/api/quizzes/user';
  static String get submitQuiz => '$baseUrl/api/quizzes/submit';
  static String get quizHistory => '$baseUrl/api/quizzes/history';

  // Profile Endpoints
  static String get profile => '$baseUrl/api/users/profile';
  static String get updateProfile => '$baseUrl/api/users/profile';
  static String get uploadAvatar => '$baseUrl/api/users/avatar';
  static String get changePassword => '$baseUrl/api/users/change-password';
  static String get userStats => '$baseUrl/api/users/stats';
  static String get studyProgress => '$baseUrl/api/users/progress';

  // Admin Endpoints
  static String get adminUsers => '$baseUrl/api/admin/users';
  static String adminUserDetail(int id) => '$baseUrl/api/admin/users/$id';
  static String get adminDashboard => '$baseUrl/api/admin/dashboard';
  static String get adminApproveContent => '$baseUrl/api/admin/approve';

  // Notification Endpoints
  static String get notifications => '$baseUrl/api/notifications';
  static String notificationDetail(int id) => '$baseUrl/api/notifications/$id';
  static String get markAsRead => '$baseUrl/api/notifications/read';

  // AI Model Endpoints
  static String get recognizeKanji => '$aiModelUrl/api/v1/predict';
  static String get recognizeDrawing => '$aiModelUrl/api/v1/recognize';

  // External APIs
  static const String jishoApi = 'https://jisho.org/api/v1/search/words';
  static const String kanjiAliveApi =
      'https://kanji-alive.rapid.api.com/api/public/kanji';
}
