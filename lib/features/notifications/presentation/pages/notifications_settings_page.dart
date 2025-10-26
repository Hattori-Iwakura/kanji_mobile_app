import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/services/notification_service.dart';

/// Notifications Settings Page
class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  final _notificationService = NotificationService();

  bool _dailyReminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 19, minute: 0);
  bool _streakNotificationsEnabled = true;
  bool _quizCompletionEnabled = true;
  bool _flashcardRemindersEnabled = true;
  bool _achievementNotificationsEnabled = true;
  bool _weeklySummaryEnabled = false;

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Daily Reminder Section
          _buildSectionHeader('Daily Reminders'),
          _buildNotificationCard(
            icon: Icons.alarm,
            iconColor: Colors.blue,
            title: 'Daily Study Reminder',
            subtitle: _dailyReminderEnabled
                ? 'Remind me at ${_reminderTime.format(context)}'
                : 'Never miss your daily practice',
            value: _dailyReminderEnabled,
            onChanged: (value) async {
              setState(() => _dailyReminderEnabled = value);
              if (value) {
                await _notificationService.scheduleDailyReminder(
                  hour: _reminderTime.hour,
                  minute: _reminderTime.minute,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Daily reminder set for ${_reminderTime.format(context)}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                await _notificationService.cancelDailyReminder();
              }
            },
            onTap: _dailyReminderEnabled ? _selectTime : null,
          ),

          const SizedBox(height: 24),

          // Activity Notifications Section
          _buildSectionHeader('Activity Notifications'),
          _buildNotificationCard(
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
            title: 'Study Streak',
            subtitle: 'Get notified when you reach new milestones',
            value: _streakNotificationsEnabled,
            onChanged: (value) {
              setState(() => _streakNotificationsEnabled = value);
            },
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.quiz,
            iconColor: Colors.purple,
            title: 'Quiz Completion',
            subtitle: 'See your scores after completing quizzes',
            value: _quizCompletionEnabled,
            onChanged: (value) {
              setState(() => _quizCompletionEnabled = value);
            },
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.style,
            iconColor: Colors.green,
            title: 'Flashcard Reminders',
            subtitle: 'Get reminded when cards are due for review',
            value: _flashcardRemindersEnabled,
            onChanged: (value) {
              setState(() => _flashcardRemindersEnabled = value);
            },
          ),

          const SizedBox(height: 24),

          // Achievement Notifications Section
          _buildSectionHeader('Achievements & Progress'),
          _buildNotificationCard(
            icon: Icons.emoji_events,
            iconColor: Colors.amber,
            title: 'Achievement Unlocked',
            subtitle: 'Celebrate your learning achievements',
            value: _achievementNotificationsEnabled,
            onChanged: (value) {
              setState(() => _achievementNotificationsEnabled = value);
            },
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.bar_chart,
            iconColor: Colors.blue,
            title: 'Weekly Summary',
            subtitle: 'Review your weekly progress every Sunday',
            value: _weeklySummaryEnabled,
            onChanged: (value) async {
              setState(() => _weeklySummaryEnabled = value);
              if (value) {
                await _notificationService.scheduleWeeklySummary();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Weekly summary enabled'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 32),

          // Test Notification Button
          _buildTestButton(),

          const SizedBox(height: 16),

          // Pending Notifications Info
          _buildPendingNotificationsInfo(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? iconColor.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged, activeThumbColor: iconColor),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _reminderTime) {
      setState(() => _reminderTime = picked);

      if (_dailyReminderEnabled) {
        await _notificationService.scheduleDailyReminder(
          hour: picked.hour,
          minute: picked.minute,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Reminder time updated to ${picked.format(context)}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Widget _buildTestButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        await _notificationService.showNotification(
          id: 999,
          title: '✅ Test Notification',
          body: 'If you see this, notifications are working perfectly!',
          payload: 'test',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Test notification sent!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      icon: const Icon(Icons.notifications_active),
      label: const Text('Send Test Notification'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPendingNotificationsInfo() {
    return FutureBuilder<List<PendingNotificationRequest>>(
      future: _notificationService.getPendingNotifications(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final count = snapshot.data!.length;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                color: Colors.white.withOpacity(0.5),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$count scheduled notification${count != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
              if (count > 0)
                TextButton(
                  onPressed: () async {
                    await _notificationService.cancelAll();
                    setState(() {
                      _dailyReminderEnabled = false;
                      _weeklySummaryEnabled = false;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All notifications cancelled'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  child: const Text('Clear All'),
                ),
            ],
          ),
        );
      },
    );
  }
}
