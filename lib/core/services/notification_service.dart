import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Service for managing local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return result ?? true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Handle navigation based on payload
    print('Notification tapped: ${response.payload}');
  }

  /// Show instant notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'kanji_master_channel',
      'Kanji Master',
      channelDescription: 'Notifications for Kanji Master app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Schedule daily reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      0, // ID for daily reminder
      '📚 Time to study!',
      'Keep your study streak alive. Practice some kanji now!',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Daily study reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Calculate next instance of specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Cancel daily reminder
  Future<void> cancelDailyReminder() async {
    await _notifications.cancel(0);
  }

  /// Show study streak notification
  Future<void> showStreakNotification(int days) async {
    await showNotification(
      id: 1,
      title: '🔥 $days Day Streak!',
      body: 'Amazing! You\'ve studied for $days days in a row. Keep it up!',
      payload: 'streak',
    );
  }

  /// Show quiz completion notification
  Future<void> showQuizCompletionNotification({
    required String quizTitle,
    required int score,
    required int total,
  }) async {
    final percentage = (score / total * 100).round();
    final emoji = percentage >= 80
        ? '🎉'
        : percentage >= 60
        ? '👍'
        : '💪';

    await showNotification(
      id: 2,
      title: '$emoji Quiz Completed!',
      body: 'You scored $score/$total ($percentage%) on "$quizTitle"',
      payload: 'quiz_result',
    );
  }

  /// Show flashcard practice reminder
  Future<void> showFlashcardReminder(int dueCards) async {
    if (dueCards == 0) return;

    await showNotification(
      id: 3,
      title: '📝 Flashcards waiting!',
      body:
          'You have $dueCards flashcard${dueCards > 1 ? 's' : ''} due for review',
      payload: 'flashcard_due',
    );
  }

  /// Show achievement notification
  Future<void> showAchievementNotification({
    required String achievement,
    required String description,
  }) async {
    await showNotification(
      id: 4,
      title: '🏆 Achievement Unlocked!',
      body: '$achievement\n$description',
      payload: 'achievement',
    );
  }

  /// Schedule weekly summary notification
  Future<void> scheduleWeeklySummary() async {
    // Schedule for Sunday at 8 PM
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20, // 8 PM
      0,
    );

    // Find next Sunday
    while (scheduledDate.weekday != DateTime.sunday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    await _notifications.zonedSchedule(
      5, // ID for weekly summary
      '📊 Your Weekly Summary',
      'Check out your progress this week!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_summary_channel',
          'Weekly Summary',
          channelDescription: 'Weekly study summary notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
