# Translate Feature

## Mô tả
Feature Translate cung cấp tính năng dịch thuật với Google Translate API, kết hợp Text-to-Speech (TTS) và Speech-to-Text (STT) để hỗ trợ học ngoại ngữ.

## Cấu trúc thư mục
```
lib/features/translate/
├── models/
│   └── translation_result.dart         # Models cho translation & languages
├── services/
│   ├── translation_service.dart        # Google Translate integration
│   ├── text_to_speech_service.dart     # TTS service
│   ├── speech_to_text_service.dart     # STT service
│   └── translation_history_service.dart # History management
├── presentation/pages/
│   └── translate_page.dart             # UI với tabs Translate & History
└── translate.dart                      # Export file
```

## Packages sử dụng

```yaml
dependencies:
  translator: ^1.0.0              # Google Translate API
  flutter_tts: ^4.1.0             # Text to Speech
  speech_to_text: ^7.0.0          # Speech to Text
  permission_handler: ^11.3.1     # Microphone permissions
  shared_preferences: ^2.3.3      # Save history
```

## Tính năng chính

### 1. Translation
- ✅ **Auto language detection**: Tự động phát hiện ngôn ngữ nguồn
- ✅ **10 ngôn ngữ**: Vietnamese, English, Japanese, Chinese, Korean, French, German, Spanish, Italian
- ✅ **Real-time translation**: Dịch ngay khi nhập text
- ✅ **Swap languages**: Đổi chiều dịch nhanh chóng

### 2. Text-to-Speech (TTS)
- ✅ **Speak source text**: Phát âm text nguồn
- ✅ **Speak translated text**: Phát âm kết quả dịch
- ✅ **10 ngôn ngữ TTS**: Hỗ trợ đầy đủ các ngôn ngữ
- ✅ **Adjustable speed**: Điều chỉnh tốc độ đọc
- ✅ **Volume control**: Điều chỉnh âm lượng

### 3. Speech-to-Text (STT)
- ✅ **Voice input**: Nói để nhập text
- ✅ **Real-time recognition**: Nhận dạng giọng nói real-time
- ✅ **Auto translate**: Tự động dịch sau khi nhận dạng
- ✅ **Microphone permission**: Xin quyền tự động
- ✅ **Visual feedback**: Hiển thị trạng thái listening

### 4. Translation History
- ✅ **Auto save**: Tự động lưu mỗi lần dịch
- ✅ **50 recent translations**: Lưu 50 bản dịch gần nhất
- ✅ **Reusable history**: Tap để load lại
- ✅ **Delete individual**: Xóa từng item
- ✅ **Clear all**: Xóa toàn bộ lịch sử
- ✅ **Date formatting**: Hiển thị thời gian thân thiện

### 5. Copy & Share
- ✅ **Copy source**: Copy text nguồn
- ✅ **Copy translation**: Copy kết quả dịch
- ✅ **Clipboard feedback**: SnackBar confirmation

## Ngôn ngữ hỗ trợ

| Code | Language | Native Name | Flag | TTS | STT |
|------|----------|-------------|------|-----|-----|
| auto | Auto Detect | Tự động | 🌐 | ❌ | ❌ |
| vi | Vietnamese | Tiếng Việt | 🇻🇳 | ✅ | ✅ |
| en | English | English | 🇬🇧 | ✅ | ✅ |
| ja | Japanese | 日本語 | 🇯🇵 | ✅ | ✅ |
| zh-cn | Chinese | 中文 | 🇨🇳 | ✅ | ✅ |
| ko | Korean | 한국어 | 🇰🇷 | ✅ | ✅ |
| fr | French | Français | 🇫🇷 | ✅ | ✅ |
| de | German | Deutsch | 🇩🇪 | ✅ | ✅ |
| es | Spanish | Español | 🇪🇸 | ✅ | ✅ |
| it | Italian | Italiano | 🇮🇹 | ✅ | ✅ |

## Sử dụng

### 1. Truy cập Translate
Từ HomePage, tap vào tile "Dịch thuật"

### 2. Dịch văn bản
```dart
// Initialize service
final translationService = TranslationService();

// Translate
final result = await translationService.translate(
  text: 'Hello world',
  from: 'auto',
  to: 'vi',
);

print(result.translatedText); // "Xin chào thế giới"
```

### 3. Text-to-Speech
```dart
// Initialize TTS
final ttsService = TextToSpeechService();
await ttsService.initialize();

// Speak text
await ttsService.speak('Hello world', 'en');

// Stop speaking
await ttsService.stop();

// Adjust settings
await ttsService.setSpeechRate(0.7);
await ttsService.setVolume(0.9);
```

### 4. Speech-to-Text
```dart
// Initialize STT
final sttService = SpeechToTextService();
await sttService.initialize();

// Start listening
await sttService.startListening(
  languageCode: 'en',
  onResult: (text) {
    print('Recognized: $text');
  },
);

// Stop listening
await sttService.stopListening();
```

### 5. Translation History
```dart
// Initialize history service
final prefs = await SharedPreferences.getInstance();
final historyService = TranslationHistoryService(prefs);

// Get history
final history = historyService.getHistory();

// Add to history
await historyService.addToHistory(translationResult);

// Clear history
await historyService.clearHistory();

// Search history
final results = historyService.searchHistory('hello');
```

## UI Components

### Translate Tab
1. **Language Selector**
   - Source language dropdown (with Auto Detect)
   - Target language dropdown
   - Swap button (↔️)

2. **Source Text Input**
   - Multi-line text field
   - Clear button (✕)
   - Microphone button (🎤) - STT
   - Speaker button (🔊) - TTS
   - Copy button (📋)

3. **Translate Button**
   - Blue elevated button
   - Loading indicator when translating

4. **Translation Result**
   - Green background container
   - Selectable text
   - Speaker button (🔊) - TTS
   - Copy button (📋)

### History Tab
1. **Header**
   - Item count display
   - Clear all button (red)

2. **History List**
   - Card-based design
   - Language indicators with flags
   - Source & translated text preview
   - Timestamp (relative time)
   - Delete button per item
   - Tap to load into translator

## Models

### TranslationResult
```dart
class TranslationResult {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
}
```

### Language
```dart
class Language {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  
  static const List<Language> supportedLanguages = [...];
  static Language? getLanguageByCode(String code);
}
```

## Services

### TranslationService
- `translate()`: Dịch text
- `detectLanguage()`: Phát hiện ngôn ngữ

### TextToSpeechService
- `initialize()`: Khởi tạo TTS
- `speak()`: Phát âm text
- `stop()`: Dừng phát âm
- `getLanguages()`: Lấy danh sách ngôn ngữ
- `setSpeechRate()`: Đặt tốc độ đọc
- `setVolume()`: Đặt âm lượng

### SpeechToTextService
- `initialize()`: Khởi tạo STT
- `startListening()`: Bắt đầu nghe
- `stopListening()`: Dừng nghe
- `cancel()`: Hủy nghe
- `getLocales()`: Lấy locales hỗ trợ
- `isAvailable()`: Kiểm tra khả dụng

### TranslationHistoryService
- `getHistory()`: Lấy lịch sử
- `addToHistory()`: Thêm vào lịch sử
- `clearHistory()`: Xóa lịch sử
- `removeFromHistory()`: Xóa item cụ thể
- `searchHistory()`: Tìm kiếm lịch sử

## Permissions

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice input</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition for voice translation</string>
```

## Error Handling

Tất cả services đều có error handling:
- Translation errors: "Translation failed: ..."
- TTS errors: "Failed to speak text: ..."
- STT errors: "Speech recognition failed: ..."
- History errors: "Error loading translation history: ..."

## Performance

### Optimization
- ✅ Lazy initialization cho TTS/STT services
- ✅ History limit 50 items
- ✅ Dispose resources trong dispose()
- ✅ Cancel operations khi leave page

### Network
- ✅ Google Translate API (free tier)
- ✅ Error retry không tự động (user phải retry)

## Testing

### Manual Testing Checklist
- [ ] Translation works với tất cả language pairs
- [ ] Auto-detect phát hiện đúng ngôn ngữ
- [ ] TTS phát âm đúng với tất cả ngôn ngữ
- [ ] STT nhận dạng đúng giọng nói
- [ ] History lưu và load chính xác
- [ ] Swap languages hoạt động
- [ ] Copy to clipboard works
- [ ] Clear history với confirmation
- [ ] Microphone permission prompt

### Unit Tests (TODO)
- [ ] TranslationService tests
- [ ] HistoryService tests
- [ ] Language model tests

### Widget Tests (TODO)
- [ ] TranslatePage widget tests
- [ ] Language selector tests
- [ ] History list tests

## Tính năng tương lai
- [ ] Offline translation (local ML model)
- [ ] Conversation mode (2-way translation)
- [ ] Camera translation (OCR)
- [ ] Phrasebook với common phrases
- [ ] Favorite translations
- [ ] Share translations
- [ ] Translation quality rating
- [ ] Multiple translation providers
- [ ] Dark mode support
- [ ] Accessibility improvements

## Known Issues
- Google Translate có rate limit
- TTS quality phụ thuộc vào device
- STT accuracy phụ thuộc vào accent
- Background noise ảnh hưởng STT
- Chinese variants (Simplified/Traditional) chỉ hỗ trợ Simplified

## Dependencies
- translator: ^1.0.0
- flutter_tts: ^4.1.0
- speech_to_text: ^7.0.0
- permission_handler: ^11.3.1
- shared_preferences: ^2.3.3
