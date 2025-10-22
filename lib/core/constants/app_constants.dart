class AppConstants {
  // App Info
  static const String appName = 'Kanji Master';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyLanguage = 'language';
  static const String keyFontSize = 'font_size';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyIsFirstLaunch = 'is_first_launch';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration refreshTokenTimeout = Duration(seconds: 10);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Languages
  static const String languageEnglish = 'en';
  static const String languageJapanese = 'ja';
  static const String languageVietnamese = 'vi';

  // User Roles
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';

  // Flashcard Review Intervals (in days)
  static const List<int> reviewIntervals = [1, 3, 7, 14, 30, 90];

  // Quiz Types
  static const String quizTypeMultipleChoice = 'multiple_choice';
  static const String quizTypeFillInBlank = 'fill_in_blank';
  static const String quizTypeDraw = 'draw';

  // Canvas Settings
  static const double canvasStrokeWidth = 8.0;
  static const double canvasWidth = 300.0;
  static const double canvasHeight = 300.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Asset Paths
  static const String imagePath = 'assets/images/';
  static const String iconPath = 'assets/icons/';
  static const String animationPath = 'assets/animations/';

  // JLPT Levels
  static const List<String> jlptLevels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  // School Grades
  static const List<int> schoolGrades = [1, 2, 3, 4, 5, 6, 7, 8, 9];
}
