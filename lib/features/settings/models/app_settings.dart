/// Model representing app settings
class AppSettings {
  final bool isDarkMode;
  final String language;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final int dailyGoal; // Number of kanji to study per day
  final bool autoPlayAudio;
  final int sessionReminderTime; // Hours before reminder
  final bool showFurigana;
  final String fontFamily;

  const AppSettings({
    this.isDarkMode = false,
    this.language = 'vi',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.dailyGoal = 10,
    this.autoPlayAudio = false,
    this.sessionReminderTime = 2,
    this.showFurigana = true,
    this.fontFamily = 'default',
  });

  AppSettings copyWith({
    bool? isDarkMode,
    String? language,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    int? dailyGoal,
    bool? autoPlayAudio,
    int? sessionReminderTime,
    bool? showFurigana,
    String? fontFamily,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      sessionReminderTime: sessionReminderTime ?? this.sessionReminderTime,
      showFurigana: showFurigana ?? this.showFurigana,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'dailyGoal': dailyGoal,
      'autoPlayAudio': autoPlayAudio,
      'sessionReminderTime': sessionReminderTime,
      'showFurigana': showFurigana,
      'fontFamily': fontFamily,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      language: json['language'] as String? ?? 'vi',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      dailyGoal: json['dailyGoal'] as int? ?? 10,
      autoPlayAudio: json['autoPlayAudio'] as bool? ?? false,
      sessionReminderTime: json['sessionReminderTime'] as int? ?? 2,
      showFurigana: json['showFurigana'] as bool? ?? true,
      fontFamily: json['fontFamily'] as String? ?? 'default',
    );
  }
}
