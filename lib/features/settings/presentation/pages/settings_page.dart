import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/app_settings.dart';
import '../../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsService _settingsService;
  late AppSettings _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _settingsService = SettingsService(prefs);
    _settings = _settingsService.loadSettings();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateSettings(AppSettings newSettings) async {
    setState(() {
      _settings = newSettings;
    });
    await _settingsService.saveSettings(newSettings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu cài đặt'),
          duration: Duration(seconds: 1),
          backgroundColor: Color(0xFF1A1F2E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0F14),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1F2E),
          title: const Text('Cài đặt'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF00BFA5)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text('Cài đặt'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Display Section
          _buildSectionHeader('Hiển thị'),
          _buildSwitchTile(
            title: 'Chế độ tối',
            subtitle: 'Sử dụng giao diện tối',
            icon: Icons.dark_mode,
            value: _settings.isDarkMode,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(isDarkMode: value));
            },
          ),
          _buildListTile(
            title: 'Ngôn ngữ',
            subtitle: _getLanguageName(_settings.language),
            icon: Icons.language,
            onTap: () => _showLanguageDialog(),
          ),
          _buildListTile(
            title: 'Font chữ',
            subtitle: _getFontName(_settings.fontFamily),
            icon: Icons.font_download,
            onTap: () => _showFontDialog(),
          ),
          _buildSwitchTile(
            title: 'Hiển thị Furigana',
            subtitle: 'Hiển thị phiên âm trên Kanji',
            icon: Icons.text_fields,
            value: _settings.showFurigana,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(showFurigana: value));
            },
          ),
          Divider(height: 32, color: Colors.white.withOpacity(0.12)),

          // Study Section
          _buildSectionHeader('Học tập'),
          _buildListTile(
            title: 'Mục tiêu hàng ngày',
            subtitle: '${_settings.dailyGoal} kanji/ngày',
            icon: Icons.emoji_events,
            onTap: () => _showDailyGoalDialog(),
          ),
          _buildSwitchTile(
            title: 'Tự động phát âm thanh',
            subtitle: 'Phát âm thanh Kanji tự động',
            icon: Icons.volume_up,
            value: _settings.autoPlayAudio,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(autoPlayAudio: value));
            },
          ),
          Divider(height: 32, color: Colors.white.withOpacity(0.12)),

          // Notifications Section
          _buildSectionHeader('Thông báo'),
          _buildSwitchTile(
            title: 'Bật thông báo',
            subtitle: 'Nhận thông báo học tập',
            icon: Icons.notifications,
            value: _settings.notificationsEnabled,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(notificationsEnabled: value));
            },
          ),
          _buildListTile(
            title: 'Nhắc nhở học tập',
            subtitle: 'Sau ${_settings.sessionReminderTime} giờ',
            icon: Icons.alarm,
            onTap: () => _showReminderTimeDialog(),
            enabled: _settings.notificationsEnabled,
          ),
          Divider(height: 32, color: Colors.white.withOpacity(0.12)),

          // Sound & Vibration Section
          _buildSectionHeader('Âm thanh & Rung'),
          _buildSwitchTile(
            title: 'Âm thanh',
            subtitle: 'Bật hiệu ứng âm thanh',
            icon: Icons.music_note,
            value: _settings.soundEnabled,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(soundEnabled: value));
            },
          ),
          _buildSwitchTile(
            title: 'Rung',
            subtitle: 'Bật rung khi tương tác',
            icon: Icons.vibration,
            value: _settings.vibrationEnabled,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(vibrationEnabled: value));
            },
          ),
          Divider(height: 32, color: Colors.white.withOpacity(0.12)),

          // About Section
          _buildSectionHeader('Về ứng dụng'),
          _buildListTile(
            title: 'Phiên bản',
            subtitle: '1.0.0',
            icon: Icons.info,
            onTap: () => _showAboutDialog(),
          ),
          _buildListTile(
            title: 'Điều khoản sử dụng',
            icon: Icons.description,
            onTap: () {
              // Navigate to terms page
            },
          ),
          _buildListTile(
            title: 'Chính sách bảo mật',
            icon: Icons.privacy_tip,
            onTap: () {
              // Navigate to privacy page
            },
          ),
          const SizedBox(height: 16),

          // Reset Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: _showResetDialog,
              icon: const Icon(Icons.restore, color: Colors.red),
              label: const Text(
                'Đặt lại cài đặt',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00BFA5),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled ? const Color(0xFF00BFA5) : Colors.white38,
      ),
      title: Text(
        title,
        style: TextStyle(color: enabled ? Colors.white : Colors.white38),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: enabled ? Colors.white.withOpacity(0.6) : Colors.white38,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: enabled ? Colors.white54 : Colors.white24,
      ),
      onTap: enabled ? onTap : null,
      enabled: enabled,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFF00BFA5)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.6)),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF00BFA5),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      default:
        return 'Tiếng Việt';
    }
  }

  String _getFontName(String font) {
    switch (font) {
      case 'default':
        return 'Mặc định';
      case 'noto-serif':
        return 'Noto Serif';
      case 'noto-sans':
        return 'Noto Sans';
      default:
        return 'Mặc định';
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text(
          'Chọn ngôn ngữ',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text(
                'Tiếng Việt',
                style: TextStyle(color: Colors.white),
              ),
              value: 'vi',
              groupValue: _settings.language,
              activeColor: const Color(0xFF00BFA5),
              onChanged: (value) {
                Navigator.pop(context);
                _updateSettings(_settings.copyWith(language: value));
              },
            ),
            RadioListTile<String>(
              title: const Text(
                'English',
                style: TextStyle(color: Colors.white),
              ),
              value: 'en',
              groupValue: _settings.language,
              activeColor: const Color(0xFF00BFA5),
              onChanged: (value) {
                Navigator.pop(context);
                _updateSettings(_settings.copyWith(language: value));
              },
            ),
            RadioListTile<String>(
              title: const Text('日本語', style: TextStyle(color: Colors.white)),
              value: 'ja',
              groupValue: _settings.language,
              activeColor: const Color(0xFF00BFA5),
              onChanged: (value) {
                Navigator.pop(context);
                _updateSettings(_settings.copyWith(language: value));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text(
          'Chọn font chữ',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text(
                'Mặc định',
                style: TextStyle(color: Colors.white),
              ),
              value: 'default',
              groupValue: _settings.fontFamily,
              activeColor: const Color(0xFF00BFA5),
              onChanged: (value) {
                Navigator.pop(context);
                _updateSettings(_settings.copyWith(fontFamily: value));
              },
            ),
            RadioListTile<String>(
              title: const Text(
                'Noto Serif',
                style: TextStyle(color: Colors.white),
              ),
              value: 'noto-serif',
              groupValue: _settings.fontFamily,
              activeColor: const Color(0xFF00BFA5),
              onChanged: (value) {
                Navigator.pop(context);
                _updateSettings(_settings.copyWith(fontFamily: value));
              },
            ),
            RadioListTile<String>(
              title: const Text(
                'Noto Sans',
                style: TextStyle(color: Colors.white),
              ),
              value: 'noto-sans',
              groupValue: _settings.fontFamily,
              activeColor: const Color(0xFF00BFA5),
              onChanged: (value) {
                Navigator.pop(context);
                _updateSettings(_settings.copyWith(fontFamily: value));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDailyGoalDialog() {
    int tempGoal = _settings.dailyGoal;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text(
          'Mục tiêu hàng ngày',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$tempGoal kanji/ngày',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00BFA5),
                ),
              ),
              Slider(
                value: tempGoal.toDouble(),
                min: 5,
                max: 50,
                divisions: 9,
                label: tempGoal.toString(),
                activeColor: const Color(0xFF00BFA5),
                inactiveColor: const Color(0xFF00BFA5).withOpacity(0.3),
                onChanged: (value) {
                  setDialogState(() {
                    tempGoal = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Đặt mục tiêu học từ 5-50 kanji mỗi ngày',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateSettings(_settings.copyWith(dailyGoal: tempGoal));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showReminderTimeDialog() {
    int tempTime = _settings.sessionReminderTime;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text(
          'Nhắc nhở học tập',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sau $tempTime giờ',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00BFA5),
                ),
              ),
              Slider(
                value: tempTime.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                label: '$tempTime giờ',
                activeColor: const Color(0xFF00BFA5),
                inactiveColor: const Color(0xFF00BFA5).withOpacity(0.3),
                onChanged: (value) {
                  setDialogState(() {
                    tempTime = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Nhận nhắc nhở sau 1-12 giờ không hoạt động',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateSettings(
                _settings.copyWith(sessionReminderTime: tempTime),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text('Về ứng dụng', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kanji Learning App',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Phiên bản: 1.0.0',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ứng dụng học Kanji với công nghệ AI, '
              'giúp bạn học và ghi nhớ Kanji hiệu quả.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2025 Kanji Learning Team',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text(
          'Đặt lại cài đặt',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bạn có chắc muốn đặt lại tất cả cài đặt về mặc định?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _settingsService.clearSettings();
              _settings = const AppSettings();
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã đặt lại cài đặt về mặc định'),
                    backgroundColor: Color(0xFF1A1F2E),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đặt lại'),
          ),
        ],
      ),
    );
  }
}
