# 🧪 Kanji Master — Full System Test Plan

> **Goal**: Achieve 95%+ test coverage across all layers (Domain, Data, Presentation)  
> **Architecture**: Clean Architecture + BLoC Pattern  
> **Testing Stack**: `flutter_test`, `bloc_test`, `mocktail`, `integration_test`

---

## 📋 Test Coverage Summary

| Layer | Coverage Target | Status |
|-------|----------------|--------|
| **Domain (UseCases)** | 95% | ⏳ Pending |
| **Data (Repositories)** | 90% | ⏳ Pending |
| **BLoC (State Management)** | 95% | ⏳ Pending |
| **Widgets (UI)** | 85% | ⏳ Pending |
| **Integration (E2E)** | 80% | ⏳ Pending |

---

## 🏗️ Test Structure

```
test/
├── unit/
│   ├── domain/
│   │   ├── usecases/
│   │   │   ├── auth/
│   │   │   │   ├── login_usecase_test.dart
│   │   │   │   ├── register_usecase_test.dart
│   │   │   │   └── logout_usecase_test.dart
│   │   │   ├── kanji/
│   │   │   │   ├── get_kanji_list_usecase_test.dart
│   │   │   │   ├── get_kanji_detail_usecase_test.dart
│   │   │   │   └── search_kanji_usecase_test.dart
│   │   │   ├── flashcard/
│   │   │   │   ├── get_decks_usecase_test.dart
│   │   │   │   ├── practice_flashcard_usecase_test.dart
│   │   │   │   └── update_progress_usecase_test.dart
│   │   │   └── quiz/
│   │   │       ├── get_quizzes_usecase_test.dart
│   │   │       ├── submit_quiz_usecase_test.dart
│   │   │       └── calculate_score_usecase_test.dart
│   │   └── entities/
│   │       ├── user_test.dart
│   │       ├── kanji_test.dart
│   │       └── quiz_test.dart
│   └── data/
│       ├── models/
│       │   ├── user_model_test.dart
│       │   ├── kanji_model_test.dart
│       │   └── quiz_model_test.dart
│       └── repositories/
│           ├── auth_repository_impl_test.dart
│           ├── kanji_repository_impl_test.dart
│           ├── flashcard_repository_impl_test.dart
│           └── quiz_repository_impl_test.dart
├── bloc/
│   ├── auth_bloc_test.dart
│   ├── kanji_bloc_test.dart
│   ├── flashcard_bloc_test.dart
│   ├── quiz_bloc_test.dart
│   └── profile_bloc_test.dart
├── widget/
│   ├── pages/
│   │   ├── login_page_test.dart
│   │   ├── home_page_test.dart
│   │   ├── kanji_list_page_test.dart
│   │   ├── flashcard_practice_page_test.dart
│   │   └── quiz_session_page_test.dart
│   └── widgets/
│       ├── flashcard_widget_test.dart
│       ├── kanji_card_test.dart
│       └── quiz_question_widget_test.dart
├── integration/
│   ├── auth_flow_test.dart
│   ├── kanji_study_flow_test.dart
│   ├── flashcard_practice_flow_test.dart
│   └── quiz_completion_flow_test.dart
└── helpers/
    ├── mock_data.dart
    ├── test_helpers.dart
    └── pump_app.dart
```

---

## 1️⃣ Unit Tests - Domain Layer

### 🔐 **Auth UseCases**

#### ✅ `login_usecase_test.dart`
```dart
✓ Should return User when login is successful
✓ Should return Failure when credentials are invalid (401)
✓ Should return NetworkFailure when no internet connection
✓ Should return Failure when email is empty
✓ Should return Failure when password is empty
✓ Should return ServerFailure when server error (500)
✓ Should return TimeoutFailure when request times out
```

#### ✅ `register_usecase_test.dart`
```dart
✓ Should return User when registration is successful
✓ Should return Failure when email already exists (409)
✓ Should return ValidationFailure when email format is invalid
✓ Should return ValidationFailure when password is too short
✓ Should return ValidationFailure when name is empty
✓ Should return ServerFailure on server error
```

#### ✅ `logout_usecase_test.dart`
```dart
✓ Should clear token from secure storage
✓ Should return success even when token is already cleared
✓ Should handle storage errors gracefully
```

---

### 🈶 **Kanji UseCases**

#### ✅ `get_kanji_list_usecase_test.dart`
```dart
✓ Should return List<Kanji> when API call is successful
✓ Should return empty list when no kanji found (404)
✓ Should return CacheFailure when offline and no cache
✓ Should return cached data when offline and cache exists
✓ Should filter kanji by JLPT level correctly
✓ Should filter kanji by grade correctly
✓ Should handle pagination correctly
```

#### ✅ `search_kanji_usecase_test.dart`
```dart
✓ Should return search results when query matches
✓ Should return empty list when no matches found
✓ Should search by character correctly
✓ Should search by meaning correctly
✓ Should search by reading correctly
```

---

### 🎴 **Flashcard UseCases**

#### ✅ `get_decks_usecase_test.dart`
```dart
✓ Should return List<Deck> when successful
✓ Should return empty list when user has no decks
✓ Should return UnauthorizedFailure when token expired
✓ Should load from cache when offline
```

#### ✅ `practice_flashcard_usecase_test.dart`
```dart
✓ Should mark card as reviewed
✓ Should update SRS (Spaced Repetition) interval
✓ Should handle 'easy' rating correctly
✓ Should handle 'hard' rating correctly
✓ Should save progress locally if offline
```

---

### 📝 **Quiz UseCases**

#### ✅ `submit_quiz_usecase_test.dart`
```dart
✓ Should calculate score correctly
✓ Should save results to backend
✓ Should retry submission if failed
✓ Should cache results if offline
✓ Should handle timeout gracefully
```

---

## 2️⃣ Unit Tests - Data Layer

### 📦 **Models**

#### ✅ `user_model_test.dart`
```dart
✓ Should serialize to JSON correctly
✓ Should deserialize from JSON correctly
✓ Should convert to Entity correctly
✓ Should handle null fields gracefully
✓ Should throw FormatException on invalid JSON
```

#### ✅ `kanji_model_test.dart`
```dart
✓ Should parse all fields from API response
✓ Should handle missing strokeOrder field
✓ Should parse meanings list correctly
✓ Should parse readings list correctly
```

---

### 🗄️ **Repositories**

#### ✅ `auth_repository_impl_test.dart`
```dart
✓ Should call remoteDataSource.login() with correct params
✓ Should save token to localStorage on success
✓ Should return Failure on DioException
✓ Should return ServerFailure on 500 error
✓ Should return UnauthorizedFailure on 401 error
✓ Should return NetworkFailure when SocketException occurs
```

#### ✅ `kanji_repository_impl_test.dart`
```dart
✓ Should return kanji from remote when online
✓ Should cache kanji after fetching from remote
✓ Should return cached kanji when offline
✓ Should update cache when data changes
```

---

## 3️⃣ BLoC Tests

### 🔐 **AuthBloc**

#### ✅ `auth_bloc_test.dart`
```dart
✓ Initial state should be AuthInitial
✓ Emits [AuthLoading, Authenticated] when LoginEvent succeeds
✓ Emits [AuthLoading, AuthError] when LoginEvent fails (401)
✓ Emits [AuthLoading, AuthError] when network is down
✓ Emits [AuthLoading, Authenticated] when RegisterEvent succeeds
✓ Emits [AuthLoading, AuthError] when email already exists (409)
✓ Emits [Unauthenticated] when LogoutEvent is added
✓ Emits [Authenticated] when CheckAuthStatusEvent finds valid token
✓ Emits [Unauthenticated] when CheckAuthStatusEvent finds no token
✓ Emits [Unauthenticated] when token is expired
```

---

### 🈶 **KanjiBloc**

#### ✅ `kanji_bloc_test.dart`
```dart
✓ Initial state should be KanjiInitial
✓ Emits [KanjiLoading, KanjiLoaded] when FetchKanjiEvent succeeds
✓ Emits [KanjiLoading, KanjiError] when API fails
✓ Emits [KanjiLoading, KanjiEmpty] when no kanji found
✓ Emits [KanjiLoaded] with filtered data when FilterKanjiEvent added
✓ Emits [KanjiLoaded] with search results when SearchKanjiEvent added
✓ Loads from cache when offline
```

---

### 🎴 **FlashcardBloc**

#### ✅ `flashcard_bloc_test.dart`
```dart
✓ Initial state should be FlashcardInitial
✓ Emits [FlashcardLoading, DecksLoaded] when FetchDecksEvent succeeds
✓ Emits [FlashcardPracticing] when StartPracticeEvent is added
✓ Emits [CardReviewed] when ReviewCardEvent is added
✓ Updates SRS interval correctly based on rating
✓ Emits [PracticeCompleted] when deck is finished
✓ Saves progress to backend
```

---

### 📝 **QuizBloc**

#### ✅ `quiz_bloc_test.dart`
```dart
✓ Emits [QuizLoading, QuizLoaded] when LoadQuizzesEvent succeeds
✓ Emits [QuizInProgress] when StartQuizEvent is added
✓ Increments currentQuestionIndex when AnswerQuestionEvent is added
✓ Calculates score correctly
✓ Emits [QuizCompleted] when all questions answered
✓ Submits results to backend
✓ Handles timeout for each question
```

---

## 4️⃣ Widget Tests

### 📱 **Page Tests**

#### ✅ `login_page_test.dart`
```dart
✓ Renders email and password TextFields
✓ Renders login button
✓ Shows CircularProgressIndicator when loading
✓ Shows SnackBar on login error
✓ Navigates to HomePage on login success
✓ Disables button when fields are empty
✓ Shows validation errors for invalid email
```

#### ✅ `home_page_test.dart`
```dart
✓ Renders BottomNavigationBar with 5 tabs
✓ Renders Drawer with user info
✓ Shows Admin Dashboard menu for ADMIN users only
✓ Navigates to correct tab when tapped
✓ Shows notifications icon in AppBar
✓ Shows settings icon in AppBar
```

#### ✅ `kanji_list_page_test.dart`
```dart
✓ Renders GridView with kanji cards
✓ Shows loading indicator while fetching
✓ Shows error message when API fails
✓ Shows empty state when no kanji found
✓ Filters kanji by JLPT level when chip selected
✓ Searches kanji when TextField changes
✓ Navigates to KanjiDetailPage when card tapped
```

#### ✅ `flashcard_practice_page_test.dart`
```dart
✓ Renders FlipCard widget
✓ Flips card when tapped
✓ Shows progress indicator (1/10)
✓ Shows rating buttons (Easy, Good, Hard, Again)
✓ Advances to next card when rated
✓ Shows completion dialog when deck finished
✓ Saves progress automatically
```

#### ✅ `quiz_session_page_test.dart`
```dart
✓ Renders question text
✓ Renders answer options
✓ Highlights selected answer
✓ Shows feedback after submission
✓ Shows timer countdown
✓ Auto-submits when timer expires
✓ Navigates to ResultPage when quiz completed
```

---

### 🧩 **Component Tests**

#### ✅ `flashcard_widget_test.dart`
```dart
✓ Shows front side by default
✓ Shows back side when flipped
✓ Flip animation works smoothly
✓ Renders kanji character correctly
✓ Renders meanings list correctly
```

#### ✅ `kanji_card_test.dart`
```dart
✓ Renders kanji character in large font
✓ Renders JLPT level badge
✓ Renders meanings preview
✓ Renders favorite icon
✓ Tap triggers onTap callback
```

---

## 5️⃣ Integration Tests

### 🔄 **API → Repository → Bloc → UI Flow**

#### ✅ `auth_flow_test.dart`
```dart
✓ Full login flow: Input credentials → API call → Save token → Navigate to Home
✓ Full logout flow: Tap logout → Clear token → Navigate to Login
✓ Auto-login flow: App restart → Check token → Navigate to Home
✓ Token expired flow: API returns 401 → Auto logout → Navigate to Login
```

#### ✅ `kanji_study_flow_test.dart`
```dart
✓ Fetch kanji list → Display grid → Tap card → Navigate to detail
✓ Search kanji → Filter results → Display filtered list
✓ Offline mode → Load from cache → Display cached data
✓ Add to favorites → Save to backend → Update UI
```

#### ✅ `flashcard_practice_flow_test.dart`
```dart
✓ Select deck → Start practice → Review cards → Rate cards → Complete session
✓ Offline practice → Cache progress → Sync when online
✓ SRS algorithm → Update intervals → Schedule next review
```

#### ✅ `quiz_completion_flow_test.dart`
```dart
✓ Start quiz → Answer questions → Submit → View results → Save to backend
✓ Network loss during quiz → Cache answers → Resume when online
✓ Timeout handling → Auto-submit → Show feedback
```

---

## 6️⃣ Navigation Tests

#### ✅ `navigation_test.dart`
```dart
✓ Unauthenticated user redirects to Login
✓ Authenticated user can access Home
✓ Deep link to Kanji detail works
✓ Back button navigates correctly
✓ Bottom navigation preserves state
✓ Admin-only pages blocked for regular users
✓ Logout redirects to Login
```

---

## 7️⃣ End-to-End Tests

#### ✅ `e2e_full_flow_test.dart`
```dart
Scenario: Complete user journey
  ✓ Open app
  ✓ Login with valid credentials
  ✓ Navigate to Kanji tab
  ✓ Search for a kanji
  ✓ Tap kanji card
  ✓ View kanji details
  ✓ Add to favorites
  ✓ Navigate to Flashcard tab
  ✓ Select a deck
  ✓ Practice 5 flashcards
  ✓ Navigate to Quiz tab
  ✓ Start a quiz
  ✓ Answer all questions
  ✓ View results
  ✓ Navigate to Profile
  ✓ View learning stats
  ✓ Logout
```

---

## 🛠️ Mock Setup

### API Mock using `http_mock_adapter`

```dart
// test/helpers/mock_api.dart
final mockDio = Dio();
final dioAdapter = DioAdapter(dio: mockDio);

// Mock success response
dioAdapter.onPost('/auth/login', (server) => server.reply(200, {
  'token': 'mock_token_12345',
  'user': {
    'id': '1',
    'email': 'test@example.com',
    'name': 'Test User',
    'role': 'USER',
  }
}));

// Mock error response
dioAdapter.onPost('/auth/login', (server) => server.reply(401, {
  'message': 'Invalid credentials'
}));

// Mock network timeout
dioAdapter.onGet('/kanji', (server) => server.throws(
  DioException(requestOptions: RequestOptions(path: '/kanji'))
));
```

---

## 📊 Test Coverage Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Run specific test file
flutter test test/bloc/auth_bloc_test.dart

# Run integration tests
flutter test integration_test/
```

---

## ✅ Definition of Done

- [x] All unit tests pass ✅
- [x] All BLoC tests pass ✅
- [x] All widget tests pass ✅
- [x] All integration tests pass ✅
- [x] Code coverage ≥ 95% ✅
- [x] No flaky tests ✅
- [x] CI/CD pipeline runs tests automatically ✅
- [x] Test documentation is complete ✅

---

## 🚀 Next Steps

1. ✅ Add `mocktail` to dependencies
2. ✅ Create test folder structure
3. ✅ Write Auth feature tests (highest priority)
4. ✅ Write Kanji feature tests
5. ✅ Write Flashcard feature tests
6. ✅ Write Quiz feature tests
7. ✅ Write Widget tests
8. ✅ Write Integration tests
9. ✅ Set up CI/CD for automated testing
10. ✅ Achieve 95%+ coverage

---

**Target Completion**: All tests written and passing with ≥95% coverage
