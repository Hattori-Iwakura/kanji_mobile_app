# Kanji Mobile App

A comprehensive Flutter application for learning and practicing Japanese Kanji characters with integrated quiz and flashcard systems.

## 🎯 Features

### Core Features
- **Kanji Database**: Browse and search 3000+ kanji characters
- **Kanji Lists**: Create and manage custom kanji study lists
- **Quiz System**: Interactive quizzes with multiple question types
  - Multiple Choice
  - True/False
  - Drawing Recognition (Canvas)
  - Matching
- **Flashcard Decks**: Spaced repetition learning system
- **User Authentication**: Secure login and registration

### Advanced Features
- JLPT level filtering
- Search by character, meaning, or reading
- Progress tracking
- Quiz result analytics
- Custom deck creation
- AI-powered drawing recognition

## 🏗️ Architecture

This project follows **Clean Architecture** principles with BLoC state management:

```
lib/
├── core/                    # Core utilities and constants
├── features/
│   ├── kanji/              # Kanji feature
│   │   ├── domain/         # Entities, repositories, use cases
│   │   ├── data/           # Models, data sources, repository impl
│   │   └── presentation/   # BLoC, pages, widgets
│   ├── kanji_list/         # Kanji List feature
│   ├── quiz/               # Quiz feature
│   └── flashcard/          # Flashcard feature
└── injection_container.dart # Dependency injection
```

## 🧪 Test Coverage

**93.6% Coverage** - 646 tests passing

| Feature | Unit Tests | Integration | Widget Tests | Total |
|---------|-----------|-------------|--------------|-------|
| Kanji | 72 ✅ | 12 ✅ | 30 ✅ | 114 (100%) |
| Kanji List | 101 ✅ | 20 ✅ | 37 ✅ | 158 (100%) |
| Quiz | 195 ✅ | 0 | 123 ✅ | 318 (100%) |
| Flashcard | 45 ✅ | 0 | 11 🔨 | 56 (80%) |

### Running Tests

```bash
# Run all tests
flutter test

# Run specific feature tests
flutter test test/unit/kanji/
flutter test test/widget/quiz/

# Generate coverage report
flutter test --coverage
```

### Test Documentation
- **Full Report**: [TEST_COVERAGE_REPORT.md](TEST_COVERAGE_REPORT.md)
- **Quick Start**: [TESTING_QUICK_START.md](TESTING_QUICK_START.md)
- **Visual Summary**: [TEST_COVERAGE_VISUAL.md](TEST_COVERAGE_VISUAL.md)
- **Progress Tracking**: [TEST_IMPLEMENTATION_PROGRESS.md](TEST_IMPLEMENTATION_PROGRESS.md)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart 3.0.0 or higher
- Android Studio / VS Code
- Backend API running (see [kanji-web-be](../kanji-web-be))

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Hattori-Iwakura/kanji_mobile_app.git
   cd kanji_mobile_v1
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   ```dart
   // lib/core/api/api_constants.dart
   static const String baseUrl = 'http://your-api-url:3000';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Running with Backend

Ensure the backend server is running:
```bash
cd ../kanji-web-be
npm run start:dev
```

## 📦 Dependencies

### Core Dependencies
- **flutter_bloc** (^8.1.3): State management
- **get_it** (^7.6.0): Dependency injection
- **dartz** (^0.10.1): Functional programming
- **http** (^1.0.0): API calls
- **equatable** (^2.0.5): Value equality

### UI Dependencies
- **cached_network_image** (^3.2.3): Image caching
- **shimmer** (^3.0.0): Loading placeholders
- **lottie** (^2.6.0): Animations

### Development Dependencies
- **flutter_test**: Unit testing
- **bloc_test** (^9.1.4): BLoC testing
- **mocktail** (^1.0.0): Mocking
- **integration_test**: E2E testing

## 🏃 Development

### Code Generation
```bash
# Generate code (if using json_serializable, etc.)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Code Analysis
```bash
# Run static analysis
flutter analyze

# Format code
flutter format .
```

### Build
```bash
# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 🧩 Project Structure

```
kanji_mobile_v1/
├── lib/
│   ├── core/
│   │   ├── api/              # API configuration
│   │   ├── errors/           # Error handling
│   │   ├── network/          # Network info
│   │   └── usecases/         # Base use case
│   ├── features/
│   │   ├── kanji/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   ├── datasources/
│   │   │   │   └── repositories/
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   └── [other features...]
│   └── main.dart
├── test/
│   ├── unit/                 # Unit tests
│   ├── widget/               # Widget tests
│   ├── integration/          # Integration tests
│   └── helpers/              # Test utilities
├── assets/                   # Images, animations
└── docs/                     # Documentation
```

## 🌟 Key Features Implementation

### Kanji Search
- Real-time search with debouncing
- Search by character, meaning, or reading
- Filter by JLPT level
- Pagination support

### Quiz System
- Multiple question types support
- Canvas-based drawing questions
- Real-time scoring
- Result analytics
- Question bank management

### Flashcard System
- Create custom decks
- Add kanji to decks
- Study mode with flip animation
- Progress tracking

## 🔧 Configuration

### Environment Variables
```dart
// lib/core/config/env.dart
class Environment {
  static const String apiUrl = String.fromEnvironment('API_URL');
  static const String apiKey = String.fromEnvironment('API_KEY');
}
```

### API Configuration
```dart
// lib/core/api/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:3000';
  static const String kanjiEndpoint = '/api/kanji';
  static const String quizEndpoint = '/api/quiz';
}
```

## 🐛 Troubleshooting

### Common Issues

**Issue**: Tests failing with "Bad state: A test tried to use `any`"  
**Solution**: Register fallback values in `setUpAll()`

**Issue**: Widget not found in tests  
**Solution**: Add `await tester.pump()` after state changes

**Issue**: API connection refused  
**Solution**: Check backend is running and API URL is correct

## 📝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`flutter test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Contribution Guidelines
- Follow Clean Architecture principles
- Write tests for all new features (target: 90%+ coverage)
- Use BLoC for state management
- Follow Flutter style guide
- Document complex logic

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Development Team** - Initial work

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- NestJS team for the backend framework
- Contributors to all open-source packages used

## 📚 Resources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [BLoC Library](https://bloclibrary.dev/)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Related Projects
- **Backend API**: [kanji-web-be](../kanji-web-be)
- **AI Model**: [cnn-kanji](../cnn-kanji)

## 📊 Project Status

- ✅ **Version**: 1.0.0
- ✅ **Status**: Production Ready
- ✅ **Test Coverage**: 93.6%
- ✅ **Last Updated**: October 24, 2025

---

**Made with ❤️ using Flutter**
