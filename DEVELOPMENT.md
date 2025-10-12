# Hướng dẫn chạy và phát triển

## Yêu cầu hệ thống

- Flutter SDK: ^3.9.2
- Dart SDK: ^3.9.2
- Android Studio hoặc VS Code
- Android Emulator hoặc iOS Simulator (hoặc thiết bị thật)

## Cài đặt

### 1. Clone repository (nếu có)
```bash
git clone <repository-url>
cd kanji_mobile
```

### 2. Cài đặt dependencies
```bash
flutter pub get
```

### 3. Kiểm tra môi trường Flutter
```bash
flutter doctor
```

## Chạy ứng dụng

### Android
```bash
# Chạy trên emulator/device
flutter run

# Chạy ở release mode
flutter run --release
```

### iOS (chỉ trên macOS)
```bash
flutter run -d ios

# Hoặc chạy trên simulator cụ thể
flutter run -d "iPhone 14"
```

### Chrome (Web)
```bash
flutter run -d chrome
```

## Build ứng dụng

### Android APK
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# APK split theo ABI (giảm kích thước)
flutter build apk --split-per-abi
```

### Android App Bundle (AAB - cho Google Play)
```bash
flutter build appbundle --release
```

### iOS (trên macOS)
```bash
flutter build ios --release
```

## Development Commands

### Kiểm tra lỗi
```bash
flutter analyze
```

### Format code
```bash
flutter format lib/
```

### Clean build
```bash
flutter clean
flutter pub get
```

### Xem logs
```bash
flutter logs
```

### Xem devices
```bash
flutter devices
```

## Cấu trúc Database

Database sẽ được tự động tạo khi app chạy lần đầu:

1. **Database name**: `kanji.db`
2. **Location**: 
   - Android: `/data/data/com.example.kanji_mobile/databases/`
   - iOS: `Library/Application Support/databases/`
3. **Data seeding**: Tự động load từ `assets/kanji-merged.json`

### Database Schema

```sql
CREATE TABLE kanji (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character TEXT NOT NULL,
  strokes INTEGER NOT NULL,
  grade INTEGER,
  freq INTEGER,
  jlpt_old INTEGER,
  jlpt_new INTEGER,
  meanings TEXT NOT NULL,
  readings_on TEXT NOT NULL,
  readings_kun TEXT NOT NULL,
  wk_level INTEGER,
  wk_meanings TEXT,
  wk_readings_on TEXT,
  wk_readings_kun TEXT,
  wk_radicals TEXT
)
```

## Debugging

### VS Code
1. Mở VS Code
2. Chọn Run > Start Debugging (F5)
3. Chọn device để chạy

### Android Studio
1. Mở Android Studio
2. Chọn device từ device selector
3. Click Run button (Shift+F10)

### Debug Database
Sử dụng các tools:
- **Android**: DB Browser for SQLite, sdb pull database
- **iOS**: Simulator data directory

```bash
# Android - Pull database
adb pull /data/data/com.example.kanji_mobile/databases/kanji.db
```

## Hot Reload & Hot Restart

### Hot Reload (r)
- Giữ state của app
- Reload UI nhanh chóng
- Phím tắt: `r` trong terminal

### Hot Restart (R)
- Reset toàn bộ state
- Reload app từ đầu
- Phím tắt: `R` trong terminal

## Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## Troubleshooting

### 1. Database không được seed
```bash
# Xóa app và reinstall
flutter clean
flutter run
```

### 2. Hot reload không hoạt động
```bash
# Hot restart
Nhấn R trong terminal
```

### 3. Dependencies lỗi
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### 4. Build lỗi
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter run
```

### 5. Emulator chậm
- Tăng RAM cho emulator (khuyến nghị: 2GB+)
- Enable Hardware Acceleration
- Sử dụng physical device

## Performance Tips

### 1. Release Mode
Luôn test performance ở release mode:
```bash
flutter run --release
```

### 2. Profile Mode
Để profile performance:
```bash
flutter run --profile
```

### 3. Analyze App Size
```bash
flutter build apk --analyze-size
```

## Updating Dependencies

### Check outdated packages
```bash
flutter pub outdated
```

### Upgrade packages
```bash
flutter pub upgrade
```

### Upgrade Flutter SDK
```bash
flutter upgrade
```

## Git Workflow

### Recommended .gitignore
```
# Flutter/Dart
.dart_tool/
.packages
.flutter-plugins
.flutter-plugins-dependencies
build/
*.iml

# Android
android/.gradle
android/local.properties
android/app/debug
android/app/release

# iOS
ios/Pods/
ios/.symlinks/
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec
```

### Commit Best Practices
```bash
# Add files
git add .

# Commit with meaningful message
git commit -m "feat: add kanji search functionality"

# Push
git push origin main
```

## CI/CD (Optional)

### GitHub Actions Example
```yaml
name: Flutter CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.2'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk --release
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

## Quick Reference

```bash
# Development
flutter run                  # Run app
flutter analyze             # Check for errors
flutter format lib/         # Format code

# Build
flutter build apk           # Build Android APK
flutter build appbundle     # Build for Play Store
flutter build ios           # Build iOS

# Maintenance
flutter clean              # Clean build
flutter pub get            # Install dependencies
flutter pub upgrade        # Update dependencies
flutter upgrade            # Update Flutter SDK
```

Happy coding! 🚀
