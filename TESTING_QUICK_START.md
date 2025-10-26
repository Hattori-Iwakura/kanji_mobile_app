# Testing Quick Start Guide

**🚀 Quick Reference for Kanji Mobile App Testing**

---

## 📊 Current Status

```
Total Tests: 646 passing / 690 total (93.6%)

✅ Kanji: 114/114 (100%)
✅ Kanji List: 158/158 (100%)
✅ Quiz: 318/318 (100%)
🔨 Flashcard: 56/70 (80%)
```

---

## 🏃 Quick Commands

### Run All Tests
```bash
flutter test
```

### Run by Feature
```bash
# Kanji tests
flutter test test/unit/kanji/
flutter test test/integration/kanji/
flutter test test/widget/kanji/

# Kanji List tests
flutter test test/unit/kanji_list/
flutter test test/integration/kanji_list/
flutter test test/widget/kanji_list/

# Quiz tests
flutter test test/unit/quiz/
flutter test test/widget/quiz/

# Flashcard tests
flutter test test/unit/flashcard/
flutter test test/widget/flashcard/
```

### Run by Type
```bash
# All unit tests
flutter test test/unit/

# All widget tests
flutter test test/widget/

# All integration tests
flutter test test/integration/
```

### Run with Coverage
```bash
flutter test --coverage
```

### Run Specific Test File
```bash
flutter test test/unit/kanji/domain/get_all_kanji_test.dart
```

### Run with Verbose Output
```bash
flutter test --reporter expanded
```

---

## 📁 Test Structure

```
test/
├── unit/                           # Unit tests (396 tests)
│   ├── kanji/
│   │   ├── domain/                # Use cases (36 tests)
│   │   └── data/                  # Models, repos, datasources (36 tests)
│   ├── kanji_list/
│   │   ├── domain/                # Use cases (43 tests)
│   │   └── data/                  # Models, repos, datasources (58 tests)
│   ├── quiz/
│   │   ├── domain/                # Use cases (77 tests)
│   │   ├── data/                  # Models, repos (58 tests)
│   │   └── bloc/                  # BLoC tests (60 tests)
│   └── flashcard/
│       ├── domain/                # Use cases (18 tests)
│       └── data/                  # Models, repos (27 tests)
│
├── widget/                        # Widget tests (218 tests)
│   ├── kanji/                     # 30 tests
│   ├── kanji_list/                # 37 tests
│   ├── quiz/                      # 123 tests
│   └── flashcard/                 # 28 tests
│
├── integration/                   # Integration tests (32 tests)
│   ├── kanji_search_integration_test.dart
│   └── kanji_list_integration_test.dart
│
└── helpers/                       # Test utilities
    ├── fixtures/                  # Test data
    │   ├── kanji_fixtures.dart
    │   ├── kanji_list_fixtures.dart
    │   ├── quiz_fixtures.dart
    │   └── flashcard_fixtures.dart
    └── mocks/                     # Mock objects
```

---

## 🧪 Test Patterns

### Unit Test Pattern (Use Case)
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockKanjiRepository extends Mock implements KanjiRepository {}

void main() {
  late GetAllKanji usecase;
  late MockKanjiRepository mockRepository;

  setUp(() {
    mockRepository = MockKanjiRepository();
    usecase = GetAllKanji(mockRepository);
  });

  test('should get kanji list from repository', () async {
    // Arrange
    when(() => mockRepository.getAllKanji())
        .thenAnswer((_) async => Right([tKanji1, tKanji2]));

    // Act
    final result = await usecase(NoParams());

    // Assert
    expect(result, equals(Right([tKanji1, tKanji2])));
    verify(() => mockRepository.getAllKanji()).called(1);
  });
}
```

### Widget Test Pattern
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockKanjiBloc extends MockBloc<KanjiEvent, KanjiState>
    implements KanjiBloc {}

void main() {
  late MockKanjiBloc mockBloc;

  setUp(() {
    mockBloc = MockKanjiBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<KanjiBloc>.value(
        value: mockBloc,
        child: const KanjiListPage(),
      ),
    );
  }

  testWidgets('should display loading indicator', (tester) async {
    // Arrange
    when(() => mockBloc.state).thenReturn(KanjiLoading());

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

### BLoC Test Pattern
```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late QuizBloc bloc;
  late MockGetAllQuizzes mockGetAllQuizzes;

  setUp(() {
    mockGetAllQuizzes = MockGetAllQuizzes();
    bloc = QuizBloc(getAllQuizzes: mockGetAllQuizzes);
  });

  blocTest<QuizBloc, QuizState>(
    'emits [QuizLoading, QuizzesLoaded] when LoadQuizzes succeeds',
    build: () {
      when(() => mockGetAllQuizzes(any()))
          .thenAnswer((_) async => Right([tQuiz1, tQuiz2]));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadQuizzes()),
    expect: () => [
      QuizLoading(),
      QuizzesLoaded([tQuiz1, tQuiz2]),
    ],
    verify: (_) {
      verify(() => mockGetAllQuizzes(any())).called(1);
    },
  );
}
```

### Integration Test Pattern
```dart
void main() {
  late KanjiBloc bloc;
  late MockKanjiRepository mockRepository;

  setUp(() {
    mockRepository = MockKanjiRepository();
    bloc = KanjiBloc(
      getAllKanji: GetAllKanji(mockRepository),
      searchKanji: SearchKanji(mockRepository),
    );
  });

  test('complete search flow', () async {
    // Arrange
    when(() => mockRepository.searchKanji(any()))
        .thenAnswer((_) async => Right([tKanji1]));

    // Act
    bloc.add(SearchKanji('日'));

    // Assert
    await expectLater(
      bloc.stream,
      emitsInOrder([
        KanjiLoading(),
        KanjiLoaded([tKanji1]),
      ]),
    );
  });
}
```

---

## 🔧 Common Test Utilities

### Using Fixtures
```dart
import '../../helpers/fixtures/kanji_fixtures.dart';

// Available fixtures:
tKanji1           // Sample kanji 1
tKanji2           // Sample kanji 2
tKanjiList        // List of kanji
tKanjiModel1      // JSON model for kanji 1
```

### Registering Fallback Values
```dart
setUpAll(() {
  registerFallbackValue(NoParams());
  registerFallbackValue(const SearchKanjiParams(keyword: ''));
});
```

### Mocking HTTP Responses
```dart
when(() => mockClient.get(any(), headers: any(named: 'headers')))
    .thenAnswer((_) async => http.Response(
          json.encode({'data': [...]}),
          200,
        ));
```

---

## 🐛 Debugging Failed Tests

### Check Test Output
```bash
# Run with detailed output
flutter test --reporter expanded test/path/to/test.dart
```

### Common Issues

**Issue**: "Found 0 widgets"
```dart
// Solution: Add pump() after state change
await tester.pumpWidget(widget);
await tester.pump(); // Add this
```

**Issue**: "Bad state: A test tried to use `any` on type X"
```dart
// Solution: Register fallback value
setUpAll(() {
  registerFallbackValue(YourType());
});
```

**Issue**: "Multiple widgets found"
```dart
// Solution: Use more specific finder
// Instead of: find.byType(InkWell)
// Use: find.descendant(of: find.byType(Card), matching: find.byType(InkWell))
```

**Issue**: "Null check operator used on null value"
```dart
// Solution: Mock all required methods
when(() => mockBloc.state).thenReturn(InitialState());
when(() => mockBloc.close()).thenAnswer((_) async {});
```

---

## 📈 Coverage Analysis

### Generate Coverage Report
```bash
# Generate coverage
flutter test --coverage

# View coverage (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Coverage by Feature
- **Kanji**: 100% (all layers)
- **Kanji List**: 100% (all layers)
- **Quiz**: 100% (all layers)
- **Flashcard**: 100% (unit), 80% (widget)

---

## ✅ Pre-Commit Checklist

Before committing code:
```bash
# 1. Run all tests
flutter test

# 2. Check test coverage
flutter test --coverage

# 3. Run specific feature tests
flutter test test/unit/your_feature/
flutter test test/widget/your_feature/

# 4. Ensure no warnings
flutter analyze
```

---

## 📝 Writing New Tests

### 1. Create Test File
Match the structure of the file you're testing:
```
lib/features/kanji/domain/usecases/my_usecase.dart
→ test/unit/kanji/domain/my_usecase_test.dart
```

### 2. Import Required Packages
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
```

### 3. Follow AAA Pattern
- **Arrange**: Set up mocks and data
- **Act**: Call the method under test
- **Assert**: Verify the result

### 4. Write Descriptive Test Names
```dart
// ✅ Good
test('should return kanji list when repository call succeeds', () {});

// ❌ Bad
test('test 1', () {});
```

### 5. Test Both Success and Failure Cases
```dart
group('GetAllKanji', () {
  test('should return list when successful', () {});
  test('should return failure when error occurs', () {});
  test('should handle empty list', () {});
});
```

---

## 🎯 Test Priorities

When writing tests, prioritize:

1. **Critical Path**: User flows that must work (login, search, quiz taking)
2. **Business Logic**: Domain layer use cases (100% coverage)
3. **Data Integrity**: Model serialization, repository logic
4. **User Interface**: Widget rendering, interactions
5. **Edge Cases**: Error handling, empty states, null values

---

## 📚 Additional Resources

### Documentation
- Full Report: `TEST_COVERAGE_REPORT.md`
- Project README: `README.md`

### Flutter Testing Docs
- [Flutter Testing](https://flutter.dev/docs/testing)
- [Widget Testing](https://flutter.dev/docs/cookbook/testing/widget/introduction)
- [Integration Testing](https://flutter.dev/docs/testing/integration-tests)

### Packages
- [flutter_test](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)
- [bloc_test](https://pub.dev/packages/bloc_test)
- [mocktail](https://pub.dev/packages/mocktail)

---

## 🤝 Contributing Tests

### Guidelines
1. ✅ Write tests for all new features
2. ✅ Maintain existing test patterns
3. ✅ Keep tests simple and focused
4. ✅ Use fixtures for test data
5. ✅ Document complex test scenarios
6. ✅ Run full test suite before PR

### Review Checklist
- [ ] All tests pass
- [ ] Coverage > 90% for new code
- [ ] Test names are descriptive
- [ ] Mocks are properly set up
- [ ] No console warnings
- [ ] Tests run independently

---

**Last Updated**: October 24, 2025  
**Maintained By**: Development Team

*Keep this guide updated as test patterns evolve!* 🚀
