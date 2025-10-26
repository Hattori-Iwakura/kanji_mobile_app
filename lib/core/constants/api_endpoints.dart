class ApiEndpoints {
  // Base URLs - loaded from .env
  static late String baseUrl;
  static late String aiModelUrl;

  // Initialize from environment
  static void init(String apiBaseUrl, String modelUrl) {
    // Ensure baseUrl has /api suffix for backend global prefix
    baseUrl = apiBaseUrl.endsWith('/api') ? apiBaseUrl : '$apiBaseUrl/api';
    aiModelUrl = modelUrl;
  }

  // Auth Endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get refreshToken => '$baseUrl/auth/refresh';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get resetPassword => '$baseUrl/auth/reset-password';
  static String get verify2FA => '$baseUrl/auth/verify-2fa';
  static String get enable2FA => '$baseUrl/auth/enable-2fa';
  static String get googleLogin => '$baseUrl/auth/google';
  static String get facebookLogin => '$baseUrl/auth/facebook';
  static String get logout => '$baseUrl/auth/logout';

  // Kanji Endpoints
  static String get kanji => '$baseUrl/kanji';
  static String kanjiDetail(int id) => '$baseUrl/kanji/$id';
  static String get searchKanji => '$baseUrl/kanji/search';
  static String get favoriteKanji => '$baseUrl/kanji/favorites';

  // Kanji List Endpoints
  static String get kanjiLists => '$baseUrl/kanji-lists';
  static String kanjiListDetail(int id) => '$baseUrl/kanji-lists/$id';
  static String get userKanjiLists => '$baseUrl/kanji-lists/user';
  static String get publicKanjiLists => '$baseUrl/kanji-lists/public';

  // Flashcard Endpoints
  static String get flashcards => '$baseUrl/flashcards';
  static String flashcardDetail(int id) => '$baseUrl/flashcards/$id';
  static String get userFlashcards => '$baseUrl/flashcards/user';
  static String get flashcardDecks => '$baseUrl/flashcards/decks';
  static String get studySession => '$baseUrl/flashcards/study-session';
  static String updateCardProgress(int cardId) =>
      '$baseUrl/flashcards/$cardId/progress';

  // Quiz Endpoints
  static String get quizzes => '$baseUrl/quizzes';
  static String quizDetail(int id) => '$baseUrl/quizzes/$id';
  static String get userQuizzes => '$baseUrl/quizzes/user';
  static String get submitQuiz => '$baseUrl/quizzes/submit';
  static String get quizHistory => '$baseUrl/quizzes/history';

  // Profile Endpoints
  static String get profile => '$baseUrl/users/profile';
  static String get updateProfile => '$baseUrl/users/profile';
  static String get uploadAvatar => '$baseUrl/users/avatar';
  static String get changePassword => '$baseUrl/users/change-password';
  static String get userStats => '$baseUrl/users/stats';
  static String get studyProgress => '$baseUrl/users/progress';

  // Admin Endpoints
  static String get adminUsers => '$baseUrl/admin/users';
  static String adminUserDetail(int id) => '$baseUrl/admin/users/$id';
  static String get adminDashboard => '$baseUrl/admin/dashboard';
  static String get adminApproveContent => '$baseUrl/admin/approve';

  // Admin Dashboard Statistics
  static String get adminDashboardContentStats =>
      '$baseUrl/admin/dashboard/stats/content';
  static String get adminDashboardActivityStats =>
      '$baseUrl/admin/dashboard/stats/activity';
  static String get adminDashboardUsersChart =>
      '$baseUrl/admin/dashboard/charts/users';
  static String get adminDashboardActivityChart =>
      '$baseUrl/admin/dashboard/charts/activity';

  // Admin Publish Requests
  static String adminPublishRequestReview(int requestId) =>
      '$baseUrl/admin/publish/requests/$requestId/review';
  static String get adminPublishStatistics =>
      '$baseUrl/admin/publish/statistics';

  // Admin System Monitoring
  static String get adminSystemHealth => '$baseUrl/admin/system/health';
  static String get adminSystemMetrics => '$baseUrl/admin/system/metrics';

  // Progress Endpoints
  static String get progressOverview => '$baseUrl/progress/overview';
  static String get progressFlashcard => '$baseUrl/progress/flashcard';
  static String get progressQuiz => '$baseUrl/progress/quiz';
  static String get progressStreak => '$baseUrl/progress/streak';
  static String get progressLeaderboard => '$baseUrl/progress/leaderboard';
  static String get progressAchievements => '$baseUrl/progress/achievements';
  static String get progressChartData => '$baseUrl/progress/chart-data';
  static String get progressStudyTime => '$baseUrl/progress/study-time';

  // Notification Endpoints
  static String get notifications => '$baseUrl/notifications';
  static String notificationDetail(int id) => '$baseUrl/notifications/$id';
  static String get markAsRead => '$baseUrl/notifications/read';

  // AI Model Endpoints
  static String get recognizeKanji => '$aiModelUrl/api/v1/predict';
  static String get recognizeDrawing => '$aiModelUrl/api/v1/recognize';

  // External APIs
  static const String jishoApi = 'https://jisho.org/api/v1/search/words';
  static const String kanjiAliveApi =
      'https://kanji-alive.rapid.api.com/api/public/kanji';
}
