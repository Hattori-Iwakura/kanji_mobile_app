# Complete Testing System - TODO List 🧪

**Project:** Kanji Mobile v1  
**Architecture:** Clean Architecture (Domain → Data → Presentation)  
**Testing Strategy:** Unit → Integration → E2E  
**Date:** October 23, 2025

---

## Testing Structure Overview

```
test/
├── unit/                    # Pure logic tests (no Flutter dependencies)
│   ├── domain/             # Use cases, entities, repositories (interfaces)
│   └── data/               # Models, data sources, repository implementations
├── integration/            # Feature tests (BLoC + Repository + API)
│   ├── features/           # Full feature integration tests
│   └── api/                # API integration tests
├── widget/                 # Widget tests (UI components)
│   └── features/           # Feature-specific widget tests
├── e2e/                    # End-to-end tests (full user flows)
│   └── flows/              # Complete user journey tests
└── helpers/                # Test utilities, mocks, fixtures
    ├── mock_data.dart
    ├── test_helpers.dart
    └── fixtures/
```

---

## 📋 Testing TODO List by Feature

### ✅ Feature 1: Authentication (COMPLETE - Reference)

**Status:** ✅ Tests exist and can be used as reference

**Existing Tests:**
- `test/unit/domain/auth/login_usecase_test.dart` ✅
- `test/unit/domain/auth/register_usecase_test.dart` ✅
- `test/unit/domain/auth/logout_usecase_test.dart` ✅
- `test/unit/domain/auth/get_profile_usecase_test.dart` ✅
- `test/unit/data/auth/auth_local_datasource_test.dart` ✅
- `test/widget/auth/login_page_test.dart` ✅
- `test/features/auth/presentation/pages/login_page_test.dart` ✅
- `test/bloc/auth_bloc_test.dart` ✅

**Coverage:**
- ✅ Unit: Login, Register, Logout, Get Profile use cases
- ✅ Data: Local data source
- ✅ Widget: Login page UI
- ✅ BLoC: Auth state management

**Use as reference for:** Clean Architecture testing patterns

---

### 🔴 Feature 2: Kanji Dictionary & Search

#### 2.1 Unit Tests - Domain Layer

**Priority:** HIGH 🔴

- [ ] **test/unit/domain/kanji/get_all_kanji_test.dart** ✅ EXISTS
  - Update to include new filters (JLPT, Grade, Stroke count)
  - Test cases: ~10
  
- [ ] **test/unit/domain/kanji/get_kanji_by_id_test.dart** ✅ EXISTS
  - Verify existing tests
  - Test cases: ~5

- [ ] **test/unit/domain/kanji/search_kanji_test.dart** ✅ EXISTS
  - Update for advanced filters
  - Add canvas drawing integration test
  - Test cases: ~15

- [ ] **test/unit/domain/kanji/get_kanji_by_character_test.dart** 🆕
  - New use case for DRAWING questions
  - Test cases: ~5

#### 2.2 Unit Tests - Data Layer

- [ ] **test/unit/data/kanji/kanji_model_test.dart** 🆕
  - Test fromJson, toJson, toEntity
  - Edge cases: null fields, invalid data
  - Test cases: ~10

- [ ] **test/unit/data/kanji/kanji_repository_impl_test.dart** 🆕
  - Mock remote data source
  - Test error handling (network, server)
  - Test cases: ~12

- [ ] **test/unit/data/kanji/kanji_remote_datasource_test.dart** 🆕
  - Mock Dio client
  - Test API calls
  - Test cases: ~8

#### 2.3 Integration Tests

- [ ] **test/integration/features/kanji/kanji_search_integration_test.dart** 🆕
  - KanjiBloc + Repository + API
  - Search flow: Query → Results → Detail
  - Canvas drawing → CNN → Search by result
  - Test cases: ~15

#### 2.4 Widget Tests

- [ ] **test/widget/kanji/kanji_search_page_test.dart** 🆕
  - Search field, filter chips
  - Canvas panel (collapsible)
  - Grid results
  - Test cases: ~12

- [ ] **test/widget/kanji/kanji_detail_page_test.dart** 🆕
  - Display kanji info
  - KanjiVG stroke animation
  - RapidAPI examples with audio
  - Test cases: ~10

- [ ] **test/widget/kanji/kanji_card_widget_test.dart** 🆕
  - Kanji display card
  - Test cases: ~5

#### 2.5 E2E Tests

- [ ] **test/e2e/flows/kanji_search_flow_test.dart** 🆕
  - Full flow: Open search → Type query → Apply filters → View results → View detail
  - Canvas flow: Open canvas → Draw → Get predictions → Tap prediction → View detail
  - Test cases: ~8

**Subtotal:** ~115 test cases

---

### 🟠 Feature 3: Kanji Lists

#### 3.1 Unit Tests - Domain Layer

**Priority:** HIGH 🟠

- [ ] **test/unit/domain/kanji_list/create_kanji_list_test.dart** 🆕
  - Test use case logic
  - Validation (name, description)
  - Test cases: ~6

- [ ] **test/unit/domain/kanji_list/get_all_kanji_lists_test.dart** 🆕
  - Filter by category, JLPT
  - Pagination
  - Test cases: ~8

- [ ] **test/unit/domain/kanji_list/get_kanji_list_by_id_test.dart** 🆕
  - Fetch single list with kanji
  - Test cases: ~5

- [ ] **test/unit/domain/kanji_list/update_kanji_list_test.dart** 🆕
  - Update name, description, category
  - Test cases: ~6

- [ ] **test/unit/domain/kanji_list/delete_kanji_list_test.dart** 🆕
  - Delete with confirmation
  - Test cases: ~4

- [ ] **test/unit/domain/kanji_list/add_kanji_to_list_test.dart** 🆕
  - Add single/multiple kanji
  - Duplicate check
  - Test cases: ~7

- [ ] **test/unit/domain/kanji_list/remove_kanji_from_list_test.dart** 🆕
  - Remove kanji by ID
  - Test cases: ~5

- [ ] **test/unit/domain/kanji_list/get_kanji_lists_by_jlpt_test.dart** 🆕
  - Filter by JLPT level (N5-N1)
  - Test cases: ~6

#### 3.2 Unit Tests - Data Layer

- [ ] **test/unit/data/kanji_list/kanji_list_model_test.dart** 🆕
  - Test serialization
  - Test cases: ~8

- [ ] **test/unit/data/kanji_list/kanji_list_repository_impl_test.dart** 🆕
  - Mock data source
  - Test cases: ~15

#### 3.3 Integration Tests

- [ ] **test/integration/features/kanji_list/kanji_list_crud_integration_test.dart** 🆕
  - Full CRUD flow with BLoC
  - Test cases: ~18

#### 3.4 Widget Tests

- [ ] **test/widget/kanji_list/kanji_list_page_test.dart** 🆕
  - List display
  - JLPT filter chips
  - Create button
  - Test cases: ~10

- [ ] **test/widget/kanji_list/kanji_list_detail_page_test.dart** 🆕
  - Display list details
  - Kanji grid
  - Edit/Delete actions
  - Test cases: ~12

- [ ] **test/widget/kanji_list/create_kanji_list_page_test.dart** 🆕
  - Form validation
  - Category selection
  - Test cases: ~8

- [ ] **test/widget/kanji_list/edit_kanji_list_page_test.dart** 🆕
  - Pre-filled form
  - Update flow
  - Test cases: ~8

#### 3.5 E2E Tests

- [ ] **test/e2e/flows/kanji_list_management_flow_test.dart** 🆕
  - Create list → Add kanji → Edit list → Remove kanji → Delete list
  - JLPT filter → Select list → View details
  - Test cases: ~12

**Subtotal:** ~138 test cases

---

### 🟡 Feature 4: Flashcards

#### 4.1 Unit Tests - Domain Layer

**Priority:** MEDIUM 🟡

- [ ] **test/unit/domain/flashcard/get_all_decks_test.dart** ✅ EXISTS
  - Verify existing tests
  - Test cases: ~5

- [ ] **test/unit/domain/flashcard/create_deck_test.dart** 🆕
  - Validation
  - Test cases: ~6

- [ ] **test/unit/domain/flashcard/get_deck_by_id_test.dart** 🆕
  - Fetch deck with cards
  - Test cases: ~5

- [ ] **test/unit/domain/flashcard/update_deck_test.dart** 🆕
  - Update deck properties
  - Test cases: ~6

- [ ] **test/unit/domain/flashcard/delete_deck_test.dart** 🆕
  - Delete validation
  - Test cases: ~4

- [ ] **test/unit/domain/flashcard/add_card_to_deck_test.dart** 🆕
  - Add flashcard to deck
  - Test cases: ~7

- [ ] **test/unit/domain/flashcard/update_card_test.dart** 🆕
  - Update front/back
  - Test cases: ~6

- [ ] **test/unit/domain/flashcard/delete_card_test.dart** 🆕
  - Remove card from deck
  - Test cases: ~4

- [ ] **test/unit/domain/flashcard/get_due_cards_test.dart** ✅ EXISTS
  - Verify spaced repetition logic
  - Test cases: ~8

- [ ] **test/unit/domain/flashcard/save_study_progress_test.dart** 🆕
  - SM-2 algorithm
  - Update intervals, ease factor
  - Test cases: ~12

#### 4.2 Unit Tests - Data Layer

- [ ] **test/unit/data/flashcard/flashcard_model_test.dart** 🆕
  - Test serialization
  - SM-2 fields
  - Test cases: ~10

- [ ] **test/unit/data/flashcard/deck_model_test.dart** 🆕
  - Test serialization
  - Test cases: ~8

- [ ] **test/unit/data/flashcard/flashcard_repository_impl_test.dart** 🆕
  - Mock data source
  - Test cases: ~18

#### 4.3 Integration Tests

- [ ] **test/integration/features/flashcard/flashcard_study_session_integration_test.dart** 🆕
  - Study session flow with BLoC
  - Progress tracking
  - Test cases: ~15

- [ ] **test/integration/features/flashcard/flashcard_crud_integration_test.dart** 🆕
  - Deck + Card CRUD
  - Test cases: ~20

#### 4.4 Widget Tests

- [ ] **test/widget/flashcard/deck_list_page_test.dart** 🆕
  - Display decks
  - Create deck button
  - Test cases: ~8

- [ ] **test/widget/flashcard/deck_detail_page_test.dart** 🆕
  - Deck info
  - Card list
  - Study button
  - Test cases: ~10

- [ ] **test/widget/flashcard/study_session_page_test.dart** 🆕
  - 3D flip animation
  - Quality buttons (0-5)
  - Test cases: ~12

- [ ] **test/widget/flashcard/session_results_page_test.dart** 🆕
  - Display stats
  - SM-2 results
  - Test cases: ~8

- [ ] **test/widget/flashcard/create_deck_page_test.dart** 🆕
  - Form validation
  - Test cases: ~6

- [ ] **test/widget/flashcard/edit_card_page_test.dart** 🆕
  - Edit front/back
  - Test cases: ~6

#### 4.5 E2E Tests

- [ ] **test/e2e/flows/flashcard_complete_flow_test.dart** 🆕
  - Create deck → Add cards → Study session → Save progress → View stats
  - Test cases: ~15

**Subtotal:** ~193 test cases

---

### 🔵 Feature 5: Quiz Module

#### 5.1 Unit Tests - Domain Layer

**Priority:** HIGH 🔵

- [ ] **test/unit/domain/quiz/get_all_quizzes_test.dart** ✅ EXISTS
  - Verify existing tests
  - Test cases: ~6

- [ ] **test/unit/domain/quiz/create_quiz_test.dart** 🆕
  - Validation
  - Test cases: ~8

- [ ] **test/unit/domain/quiz/get_quiz_by_id_test.dart** 🆕
  - Fetch quiz details
  - Test cases: ~5

- [ ] **test/unit/domain/quiz/update_quiz_test.dart** 🆕
  - Update properties
  - Test cases: ~6

- [ ] **test/unit/domain/quiz/delete_quiz_test.dart** 🆕
  - Delete validation
  - Test cases: ~4

- [ ] **test/unit/domain/quiz/get_quiz_questions_test.dart** ✅ EXISTS
  - Verify existing tests
  - Test cases: ~8

- [ ] **test/unit/domain/quiz/add_question_test.dart** 🆕
  - Add question (4 types)
  - Validation per type
  - Test cases: ~12

- [ ] **test/unit/domain/quiz/update_question_test.dart** 🆕
  - Update question
  - Type-specific validation
  - Test cases: ~10

- [ ] **test/unit/domain/quiz/delete_question_test.dart** 🆕
  - Remove question
  - Test cases: ~4

- [ ] **test/unit/domain/quiz/start_quiz_test.dart** 🆕
  - Initialize session
  - Test cases: ~6

- [ ] **test/unit/domain/quiz/submit_quiz_answer_test.dart** ✅ EXISTS
  - Answer validation
  - Test cases: ~10

- [ ] **test/unit/domain/quiz/complete_quiz_test.dart** ✅ EXISTS
  - Score calculation
  - Test cases: ~12

- [ ] **test/unit/domain/quiz/get_quiz_history_test.dart** ✅ EXISTS
  - Verify existing tests
  - Test cases: ~6

#### 5.2 Unit Tests - Data Layer

- [ ] **test/unit/data/quiz/quiz_model_test.dart** 🆕
  - Test serialization
  - Test cases: ~10

- [ ] **test/unit/data/quiz/question_model_test.dart** 🆕
  - 4 question types
  - DRAWING type with meanings
  - Test cases: ~15

- [ ] **test/unit/data/quiz/quiz_result_model_test.dart** 🆕
  - Result serialization
  - Test cases: ~8

- [ ] **test/unit/data/quiz/quiz_repository_impl_test.dart** 🆕
  - Mock data source
  - Test cases: ~25

#### 5.3 Integration Tests

- [ ] **test/integration/features/quiz/quiz_question_management_integration_test.dart** 🆕
  - Question CRUD with all 4 types
  - DRAWING type: Auto-fetch meanings
  - Test cases: ~20

- [ ] **test/integration/features/quiz/quiz_taking_integration_test.dart** 🆕
  - Full quiz session
  - Timer, navigation, answer tracking
  - CNN integration for DRAWING
  - Test cases: ~25

- [ ] **test/integration/features/quiz/quiz_result_integration_test.dart** 🆕
  - Result calculation and display
  - Test cases: ~10

#### 5.4 Widget Tests

- [ ] **test/widget/quiz/quiz_list_page_test.dart** 🆕
  - Display quizzes
  - Difficulty filters
  - Test cases: ~10

- [ ] **test/widget/quiz/question_list_page_test.dart** 🆕
  - Display questions
  - 4 type indicators
  - Test cases: ~12

- [ ] **test/widget/quiz/create_question_page_test.dart** 🆕
  - Form for 4 types
  - DRAWING: Kanji auto-fetch
  - Test cases: ~18

- [ ] **test/widget/quiz/edit_question_page_test.dart** 🆕
  - Pre-filled form
  - Type-specific fields
  - Test cases: ~15

- [ ] **test/widget/quiz/quiz_taking_page_test.dart** 🆕
  - Timer display
  - Progress bar
  - 4 question type renders
  - Navigation buttons
  - Test cases: ~20

- [ ] **test/widget/quiz/quiz_drawing_canvas_test.dart** 🆕
  - Canvas drawing widget
  - Clear/Submit buttons
  - Test cases: ~8

- [ ] **test/widget/quiz/quiz_result_page_test.dart** 🆕
  - Score display
  - Detailed review
  - Test cases: ~12

#### 5.5 E2E Tests

- [ ] **test/e2e/flows/quiz_complete_flow_test.dart** 🆕
  - Create quiz → Add questions (all 4 types) → Take quiz → Submit → View results
  - DRAWING question: Draw kanji → CNN validates → Auto-submit
  - Test cases: ~25

**Subtotal:** ~314 test cases

---

### 🟣 Feature 6: Translation

#### 6.1 Unit Tests - Domain Layer

**Priority:** LOW 🟣

- [ ] **test/unit/domain/translation/translate_text_test.dart** 🆕
  - ML Kit translation wrapper
  - Test cases: ~6

- [ ] **test/unit/domain/translation/detect_language_test.dart** 🆕
  - Regex-based detection (5 languages)
  - Test cases: ~8

#### 6.2 Widget Tests

- [ ] **test/widget/translation/translation_page_test.dart** 🆕
  - Text translation tab
  - Voice tab
  - TTS controls
  - STT with permission
  - Test cases: ~15

#### 6.3 Integration Tests

- [ ] **test/integration/features/translation/translation_stt_integration_test.dart** 🆕
  - Speech-to-text flow
  - Permission handling
  - Language detection
  - Retry mechanism
  - Test cases: ~12

#### 6.4 E2E Tests

- [ ] **test/e2e/flows/translation_flow_test.dart** 🆕
  - Text translation: Input → Translate → Copy
  - Voice: Grant permission → Record → Detect language → Translate → TTS
  - Test cases: ~10

**Subtotal:** ~51 test cases

---

### 🟤 Feature 7: CNN Recognition

#### 7.1 Unit Tests - Domain Layer

**Priority:** MEDIUM 🟤

- [ ] **test/unit/domain/cnn_recognition/predict_kanji_test.dart** 🆕
  - Image upload
  - Top-10 predictions
  - Test cases: ~8

- [ ] **test/unit/domain/cnn_recognition/check_server_status_test.dart** 🆕
  - Health check
  - Test cases: ~4

#### 7.2 Unit Tests - Data Layer

- [ ] **test/unit/data/cnn_recognition/prediction_result_model_test.dart** 🆕
  - Serialization
  - Test cases: ~6

- [ ] **test/unit/data/cnn_recognition/cnn_repository_impl_test.dart** 🆕
  - Mock HTTP client
  - Test cases: ~10

#### 7.3 Integration Tests

- [ ] **test/integration/features/cnn_recognition/cnn_prediction_integration_test.dart** 🆕
  - Full prediction flow
  - BLoC + Repository + API
  - Test cases: ~12

#### 7.4 Widget Tests

- [ ] **test/widget/cnn_recognition/kanji_drawing_page_test.dart** 🆕
  - Canvas drawing
  - Predictions display
  - Test cases: ~10

#### 7.5 E2E Tests

- [ ] **test/e2e/flows/cnn_recognition_flow_test.dart** 🆕
  - Draw → Submit → Get predictions → Use in search/quiz
  - Test cases: ~8

**Subtotal:** ~58 test cases

---

### 🔶 Feature 8: Profile & Settings

#### 8.1 Unit Tests - Domain Layer

**Priority:** LOW 🔶

- [ ] **test/unit/domain/profile/get_profile_test.dart** 🆕
  - Fetch user profile
  - Test cases: ~5

- [ ] **test/unit/domain/profile/update_profile_test.dart** 🆕
  - Update name, bio, language
  - Test cases: ~8

- [ ] **test/unit/domain/profile/upload_avatar_test.dart** 🆕
  - Image upload
  - Test cases: ~6

#### 8.2 Widget Tests

- [ ] **test/widget/profile/profile_page_test.dart** 🆕
  - Display user info
  - Edit button
  - Test cases: ~8

- [ ] **test/widget/profile/edit_profile_page_test.dart** 🆕
  - Form validation
  - Image picker
  - Test cases: ~10

- [ ] **test/widget/settings/settings_page_test.dart** 🆕
  - Settings list
  - Toggle switches
  - Test cases: ~8

#### 8.3 E2E Tests

- [ ] **test/e2e/flows/profile_management_flow_test.dart** 🆕
  - View profile → Edit → Upload avatar → Save
  - Test cases: ~6

**Subtotal:** ~51 test cases

---

### 🟢 Feature 9: Dashboard & Home

#### 9.1 Widget Tests

**Priority:** LOW 🟢

- [ ] **test/widget/dashboard/home_page_test.dart** 🆕
  - Bottom navigation
  - Tab switching
  - Test cases: ~8

- [ ] **test/widget/dashboard/dashboard_stats_test.dart** 🆕
  - Stats cards
  - Charts
  - Test cases: ~6

#### 9.2 E2E Tests

- [ ] **test/e2e/flows/navigation_flow_test.dart** 🆕
  - Navigate between all tabs
  - Test cases: ~5

**Subtotal:** ~19 test cases

---

## 📊 Testing Summary

### Total Test Files to Create: **~120 files**

### Total Test Cases: **~939 test cases**

| Category | Files | Test Cases |
|----------|-------|------------|
| **Auth (Reference)** | 8 | ~60 |
| **Kanji Dictionary** | 12 | ~115 |
| **Kanji Lists** | 14 | ~138 |
| **Flashcards** | 16 | ~193 |
| **Quiz Module** | 22 | ~314 |
| **Translation** | 6 | ~51 |
| **CNN Recognition** | 7 | ~58 |
| **Profile & Settings** | 7 | ~51 |
| **Dashboard** | 3 | ~19 |

---

## 🎯 Testing Priorities

### Phase 1: Critical Features (Week 1-2)
**Priority: 🔴 HIGH**

1. **Kanji Search & Dictionary** (~115 tests)
   - Core functionality
   - CNN integration
   
2. **Quiz Module** (~314 tests)
   - Most complex feature
   - 4 question types
   - DRAWING with CNN

3. **Kanji Lists** (~138 tests)
   - CRUD operations
   - JLPT filtering

**Total Phase 1:** ~567 tests

---

### Phase 2: Important Features (Week 3)
**Priority: 🟡 MEDIUM**

4. **Flashcards** (~193 tests)
   - Study sessions
   - SM-2 algorithm

5. **CNN Recognition** (~58 tests)
   - Standalone testing

**Total Phase 2:** ~251 tests

---

### Phase 3: Supporting Features (Week 4)
**Priority: 🟢 LOW**

6. **Translation** (~51 tests)
7. **Profile & Settings** (~51 tests)
8. **Dashboard** (~19 tests)

**Total Phase 3:** ~121 tests

---

## 🛠️ Testing Tools & Setup

### Required Packages

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Mocking
  mockito: ^5.4.4
  build_runner: ^2.4.12
  
  # BLoC Testing
  bloc_test: ^9.1.7
  
  # Network Mocking
  http_mock_adapter: ^0.6.1
  
  # Integration Testing
  integration_test:
    sdk: flutter
  
  # Code Coverage
  coverage: ^1.9.2
```

### Test Helpers

**Already Existing:**
- ✅ `test/helpers/mock_data.dart` - Mock entities
- ✅ `test/helpers/test_helpers.dart` - Test utilities

**To Create:**
- [ ] `test/helpers/fixtures/kanji_fixtures.dart` - Kanji test data
- [ ] `test/helpers/fixtures/quiz_fixtures.dart` - Quiz test data
- [ ] `test/helpers/fixtures/flashcard_fixtures.dart` - Flashcard test data
- [ ] `test/helpers/mock_services.dart` - Mock services
- [ ] `test/helpers/test_blocs.dart` - Test BLoC instances

---

## 📝 Testing Best Practices

### Unit Tests
```dart
// test/unit/domain/kanji/search_kanji_test.dart
void main() {
  late MockKanjiRepository mockRepository;
  late SearchKanji usecase;

  setUp(() {
    mockRepository = MockKanjiRepository();
    usecase = SearchKanji(mockRepository);
  });

  group('SearchKanji', () {
    test('should return list of kanji when search is successful', () async {
      // Arrange
      when(mockRepository.searchKanji(any))
          .thenAnswer((_) async => Right(tKanjiList));

      // Act
      final result = await usecase(SearchParams(query: 'test'));

      // Assert
      expect(result, Right(tKanjiList));
      verify(mockRepository.searchKanji('test'));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
```

### Integration Tests
```dart
// test/integration/features/kanji/kanji_search_integration_test.dart
void main() {
  late KanjiBloc bloc;
  late MockKanjiRepository repository;

  setUp(() {
    repository = MockKanjiRepository();
    bloc = KanjiBloc(
      searchKanji: SearchKanji(repository),
      getAllKanji: GetAllKanji(repository),
    );
  });

  blocTest<KanjiBloc, KanjiState>(
    'emits [KanjiLoading, KanjiSearchLoaded] when search succeeds',
    build: () => bloc,
    act: (bloc) => bloc.add(SearchKanjiEvent(query: 'test')),
    expect: () => [
      KanjiLoading(),
      KanjiSearchLoaded(results: tKanjiList),
    ],
  );
}
```

### E2E Tests
```dart
// test/e2e/flows/kanji_search_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete kanji search flow', (tester) async {
    // 1. Launch app
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // 2. Navigate to search
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // 3. Enter search query
    await tester.enterText(find.byType(TextField), '水');
    await tester.pumpAndSettle();

    // 4. Verify results
    expect(find.text('水'), findsWidgets);

    // 5. Tap on result
    await tester.tap(find.text('水').first);
    await tester.pumpAndSettle();

    // 6. Verify detail page
    expect(find.byType(KanjiDetailPage), findsOneWidget);
  });
}
```

---

## 🚀 Getting Started

### Step 1: Run Existing Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
lcov --summary coverage/lcov.info
```

### Step 2: Create Test Structure
```bash
# Create directories
mkdir -p test/integration/features/{kanji,kanji_list,flashcard,quiz,translation,cnn_recognition,profile}
mkdir -p test/e2e/flows
mkdir -p test/helpers/fixtures

# Create helper files
touch test/helpers/fixtures/kanji_fixtures.dart
touch test/helpers/fixtures/quiz_fixtures.dart
touch test/helpers/mock_services.dart
```

### Step 3: Start with High Priority
1. Begin with **Kanji Search** tests
2. Use **Auth tests** as reference
3. Follow **Clean Architecture** pattern
4. Test **happy path** first, then **edge cases**

### Step 4: Track Progress
- Update this TODO list as tests are completed
- Maintain **>80% code coverage** target
- Run tests in CI/CD pipeline

---

## 📈 Coverage Goals

| Layer | Target Coverage |
|-------|----------------|
| **Domain (Use Cases)** | 95%+ |
| **Data (Models, Repos)** | 90%+ |
| **Presentation (BLoCs)** | 85%+ |
| **Widgets (UI)** | 70%+ |
| **E2E (Flows)** | Critical paths |

**Overall Target:** 80%+ code coverage

---

## ✅ Completion Checklist

### Phase 1 (High Priority)
- [ ] Kanji Dictionary & Search (~115 tests)
- [ ] Quiz Module (~314 tests)
- [ ] Kanji Lists (~138 tests)

### Phase 2 (Medium Priority)
- [ ] Flashcards (~193 tests)
- [ ] CNN Recognition (~58 tests)

### Phase 3 (Low Priority)
- [ ] Translation (~51 tests)
- [ ] Profile & Settings (~51 tests)
- [ ] Dashboard (~19 tests)

### Documentation
- [ ] Update README with testing instructions
- [ ] Create testing guidelines document
- [ ] Document mock data structure
- [ ] Add CI/CD test pipeline

---

**Total Progress: 0 / 939 test cases (0%)**

**Estimated Time:** 4-6 weeks (with 1-2 developers)

**Last Updated:** October 23, 2025

---

**Author:** GitHub Copilot  
**Project:** Kanji Mobile v1  
**Architecture:** Clean Architecture + BLoC
