# Settings Feature

## Mô tả
Feature Settings cho phép người dùng tùy chỉnh cấu hình ứng dụng theo sở thích cá nhân.

## Cấu trúc thư mục
```
lib/features/settings/
├── models/
│   └── app_settings.dart       # Model chứa các cài đặt
├── services/
│   └── settings_service.dart   # Service lưu/đọc settings từ SharedPreferences
└── presentation/
    └── pages/
        └── settings_page.dart  # UI Settings page
```

## Các cài đặt được hỗ trợ

### 1. Hiển thị
- **Chế độ tối**: Bật/tắt dark mode
- **Ngôn ngữ**: Tiếng Việt / English / 日本語
- **Font chữ**: Mặc định / Noto Serif / Noto Sans
- **Hiển thị Furigana**: Hiển thị phiên âm trên Kanji

### 2. Học tập
- **Mục tiêu hàng ngày**: Số lượng kanji học mỗi ngày (5-50 kanji)
- **Tự động phát âm thanh**: Phát âm thanh Kanji tự động khi xem

### 3. Thông báo
- **Bật thông báo**: Nhận thông báo học tập
- **Nhắc nhở học tập**: Thời gian nhắc nhở (1-12 giờ)

### 4. Âm thanh & Rung
- **Âm thanh**: Bật/tắt hiệu ứng âm thanh
- **Rung**: Bật/tắt rung khi tương tác

### 5. Về ứng dụng
- **Phiên bản**: Hiển thị phiên bản app
- **Điều khoản sử dụng**: Link đến trang điều khoản
- **Chính sách bảo mật**: Link đến trang chính sách

## Sử dụng

### 1. Truy cập Settings
Từ HomePage, tap vào tile "Cài đặt"

### 2. Đọc settings
```dart
final prefs = await SharedPreferences.getInstance();
final settingsService = SettingsService(prefs);
final settings = settingsService.loadSettings();

print('Dark mode: ${settings.isDarkMode}');
print('Language: ${settings.language}');
print('Daily goal: ${settings.dailyGoal}');
```

### 3. Lưu settings
```dart
final newSettings = settings.copyWith(
  isDarkMode: true,
  language: 'en',
  dailyGoal: 20,
);
await settingsService.saveSettings(newSettings);
```

### 4. Reset settings
```dart
await settingsService.clearSettings();
```

## Model: AppSettings

### Thuộc tính
- `isDarkMode`: bool - Chế độ tối (default: false)
- `language`: String - Ngôn ngữ (default: 'vi')
- `notificationsEnabled`: bool - Bật thông báo (default: true)
- `soundEnabled`: bool - Bật âm thanh (default: true)
- `vibrationEnabled`: bool - Bật rung (default: true)
- `dailyGoal`: int - Mục tiêu hàng ngày (default: 10)
- `autoPlayAudio`: bool - Tự động phát audio (default: false)
- `sessionReminderTime`: int - Thời gian nhắc nhở (default: 2)
- `showFurigana`: bool - Hiển thị Furigana (default: true)
- `fontFamily`: String - Font chữ (default: 'default')

### Methods
- `copyWith()`: Tạo bản sao với giá trị mới
- `toJson()`: Chuyển đổi sang Map để lưu
- `fromJson()`: Khôi phục từ Map

## Service: SettingsService

### Constructor
```dart
SettingsService(SharedPreferences prefs)
```

### Methods
- `loadSettings()`: AppSettings - Load settings từ local storage
- `saveSettings(AppSettings)`: Future<bool> - Lưu settings
- `clearSettings()`: Future<bool> - Xóa tất cả settings

## UI Components

### Settings Page
Full-featured settings page với các sections:
1. **Section Headers**: Phân loại các nhóm settings
2. **Switch Tiles**: Bật/tắt các tùy chọn
3. **List Tiles**: Mở dialog để chọn giá trị
4. **Dialogs**:
   - Language picker với RadioListTile
   - Font picker với RadioListTile
   - Daily goal slider (5-50)
   - Reminder time slider (1-12 hours)
   - About dialog với thông tin app
   - Reset confirmation dialog

### Styling
- Icons với màu blue cho các active items
- Grey cho disabled items
- Red cho reset button
- Material Design components

## Lưu trữ
Settings được lưu trong SharedPreferences với key `app_settings` dưới dạng JSON string.

## Tính năng tương lai
- [ ] Sync settings với server (cho multi-device)
- [ ] Export/Import settings
- [ ] Theme customization nâng cao
- [ ] Backup/Restore settings
- [ ] Settings search

## Testing
Chưa có integration test. Cần thêm:
- Unit tests cho AppSettings model
- Unit tests cho SettingsService
- Widget tests cho SettingsPage
- Integration tests cho save/load workflow
