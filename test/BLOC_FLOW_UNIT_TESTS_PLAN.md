# Bloc Flow Unit Tests Documentation

**Created**: October 21, 2025  
**Purpose**: Unit tests cho bloc flow của tất cả features sử dụng `bloc_test` package

---

## 📋 Test Files Structure

```
test/
├── features/
│   ├── kanji/
│   │   └── presentation/
│   │       └── bloc/
│   │           ├── kanji_bloc_test.dart ✅ (existing - 25+ tests)
│   │           └── kanji_bloc_test.mocks.dart (generated)
│   ├── kanji_list/
│   │   └── presentation/
│   │       └── bloc/
│   │           ├── kanji_list_bloc_test.dart 🔜 (to create)
│   │           └── kanji_list_bloc_test.mocks.dart (generated)
│   ├── flashcard/
│   │   └── presentation/
│   │       └── bloc/
│   │           ├── flashcard_bloc_test.dart 🔜 (to create)
│   │           └── flashcard_bloc_test.mocks.dart (generated)
│   ├── quiz/
│   │   └── presentation/
│   │       └── bloc/
│   │           ├── quiz_bloc_test.dart 🔜 (to create)
│   │           └── quiz_bloc_test.mocks.dart (generated)
│   ├── auth/
│   │   └── presentation/
│   │       └── bloc/
│   │           ├── auth_bloc_test.dart 🔜 (to create)
│   │           └── auth_bloc_test.mocks.dart (generated)
│   └── admin/
│       └── presentation/
│           └── bloc/
│               ├── category_bloc_test.dart 🔜 (to create)
│               └── category_bloc_test.mocks.dart (generated)
```

---

## ✅ Existing Tests: kanji_bloc_test.dart

**Status**: ✅ Completed (25+ tests)  
**Coverage**: 
- LoadKanjiListEvent (9 tests)
  - Basic load
  - JLPT filter
  - Grade filter
  - Search query
  - Pagination
  - Error handling
- LoadKanjiByIdEvent (2 tests)
- LoadKanjiByCharacterEvent (2 tests)
- CreateKanjiEvent (3 tests)
- UpdateKanjiEvent (3 tests)
- DeleteKanjiEvent (3 tests)
- RefreshKanjiListEvent (1 test)
- Multiple events sequence (1 test)

**Missing**: 
- ❌ Auto-reload after Create/Update/Delete (từ fixes gần đây)
- ❌ RefreshKanjiListEvent preserves filters test

---

## 🔜 To Create: kanji_list_bloc_test.dart

**Test Count**: ~30 tests

### Test Groups:

1. **LoadAllListsEvent** (8 tests)
   - ✅ Basic load
   - ✅ With search filter
   - ✅ With type filter
   - ✅ With pagination
   - ✅ Empty result
   - ✅ Network error
   - ✅ Unauthorized error
   - ✅ Generic error

2. **RefreshListsEvent** (3 tests)
   - ✅ Preserves search filter
   - ✅ Preserves type filter
   - ✅ Reloads without filters when no current state

3. **LoadListByIdEvent** (3 tests)
   - ✅ Load detail succeeds
   - ✅ List not found
   - ✅ Unauthorized access

4. **CreateListEvent** (4 tests)
   - ✅ Create without category
   - ✅ Create with category
   - ✅ Auto-reload after create (500ms)
   - ✅ Validation error

5. **UpdateListEvent** (4 tests)
   - ✅ Update name/description
   - ✅ Update category
   - ✅ Auto-reload after update (500ms)
   - ✅ Not found error

6. **DeleteListEvent** (3 tests)
   - ✅ Delete succeeds
   - ✅ Auto-reload after delete (500ms)
   - ✅ Unauthorized error

7. **AddKanjiToListEvent** (2 tests)
   - ✅ Add kanji succeeds
   - ✅ Reload detail after add (300ms)

8. **RemoveKanjiFromListEvent** (2 tests)
   - ✅ Remove kanji succeeds
   - ✅ Reload detail after remove (300ms)

9. **Publish Events** (3 tests)
   - ✅ Request publish
   - ✅ Approve request (admin)
   - ✅ Reject request (admin)

---

## 🔜 To Create: flashcard_bloc_test.dart

**Test Count**: ~25 tests

### Test Groups:

1. **LoadDecksEvent** (4 tests)
   - ✅ Load all decks
   - ✅ Filter by category
   - ✅ Empty state
   - ✅ Error handling

2. **CreateDeckEvent** (3 tests)
   - ✅ Create succeeds
   - ✅ Duplicate name error
   - ✅ Validation error

3. **StartPracticeEvent** (4 tests)
   - ✅ Start practice with new cards
   - ✅ Start practice with review cards
   - ✅ No cards available
   - ✅ Load cards error

4. **NextCardEvent** (2 tests)
   - ✅ Show next card
   - ✅ Practice complete

5. **RateCardEvent - SRS** (6 tests)
   - ✅ Rate as Again (wrong)
   - ✅ Rate as Hard
   - ✅ Rate as Good
   - ✅ Rate as Easy
   - ✅ SRS calculation correct
   - ✅ Update progress stats

6. **CompletePracticeEvent** (3 tests)
   - ✅ Save session results
   - ✅ Update deck stats
   - ✅ Clear practice state

7. **Progress Tracking** (3 tests)
   - ✅ Track new cards learned
   - ✅ Track review accuracy
   - ✅ Update due dates

---

## 🔜 To Create: quiz_bloc_test.dart

**Test Count**: ~20 tests

### Test Groups:

1. **LoadQuizzesEvent** (3 tests)
   - ✅ Load all quizzes
   - ✅ Filter by difficulty
   - ✅ Error handling

2. **CreateQuizEvent** (3 tests)
   - ✅ Create succeeds
   - ✅ Invalid questions
   - ✅ Duplicate quiz

3. **StartQuizEvent** (4 tests)
   - ✅ Start quiz
   - ✅ Load questions
   - ✅ Initialize timer (if timed)
   - ✅ Quiz not found

4. **SubmitAnswerEvent** (5 tests)
   - ✅ Submit correct answer
   - ✅ Submit wrong answer
   - ✅ Immediate feedback shown
   - ✅ Highlight correct/incorrect
   - ✅ Show explanation

5. **CompleteQuizEvent** (3 tests)
   - ✅ Calculate final score
   - ✅ Save quiz result
   - ✅ Update user stats

6. **Timer Integration** (2 tests)
   - ✅ Timer countdown
   - ✅ Auto-submit on timer expiry

---

## 🔜 To Create: auth_bloc_test.dart

**Test Count**: ~15 tests

### Test Groups:

1. **LoginEvent** (5 tests)
   - ✅ Login with email/password
   - ✅ Store token securely
   - ✅ Invalid credentials
   - ✅ Network error
   - ✅ Account locked

2. **LogoutEvent** (2 tests)
   - ✅ Logout succeeds
   - ✅ Clear stored token

3. **Auto-Login** (3 tests)
   - ✅ Load stored token on app start
   - ✅ Validate token
   - ✅ Token expired - logout

4. **RegisterEvent** (3 tests)
   - ✅ Register new user
   - ✅ Email already exists
   - ✅ Validation error

5. **Token Management** (2 tests)
   - ✅ Refresh token before expiry
   - ✅ Handle token refresh error

---

## 🔜 To Create: category_bloc_test.dart

**Test Count**: ~12 tests

### Test Groups:

1. **LoadCategoriesEvent** (3 tests)
   - ✅ Load all categories
   - ✅ Empty state
   - ✅ Error handling

2. **CreateCategoryEvent** (3 tests)
   - ✅ Create succeeds (admin only)
   - ✅ Duplicate name
   - ✅ Unauthorized (non-admin)

3. **UpdateCategoryEvent** (3 tests)
   - ✅ Update succeeds
   - ✅ Category not found
   - ✅ Unauthorized

4. **DeleteCategoryEvent** (3 tests)
   - ✅ Delete succeeds
   - ✅ Category in use (has lists)
   - ✅ Unauthorized

---

## 🚀 How to Run Tests

### Run Single Bloc Test
```bash
flutter test test/features/kanji/presentation/bloc/kanji_bloc_test.dart
```

### Run All Bloc Tests
```bash
flutter test test/features/**/bloc/
```

### Generate Mocks (Required Before Running)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Run with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📊 Test Patterns with bloc_test

### Pattern 1: Basic State Transition
```dart
blocTest<KanjiBloc, KanjiState>(
  'emits [Loading, Loaded] when event succeeds',
  build: () {
    when(mockUseCase()).thenAnswer((_) async => data);
    return bloc;
  },
  act: (bloc) => bloc.add(SomeEvent()),
  expect: () => [
    LoadingState(),
    LoadedState(data),
  ],
);
```

### Pattern 2: Auto-Reload Test
```dart
blocTest<KanjiListBloc, KanjiListState>(
  'auto-reloads after create with 500ms delay',
  build: () {
    when(mockCreateUseCase(any)).thenAnswer((_) async => item);
    when(mockLoadUseCase()).thenAnswer((_) async => items);
    return bloc;
  },
  act: (bloc) => bloc.add(CreateEvent()),
  wait: const Duration(milliseconds: 600),
  expect: () => [
    Loading(),
    Created(item),
    Loading(),
    Loaded(items),
  ],
);
```

### Pattern 3: Preserve Filters Test
```dart
blocTest<KanjiBloc, KanjiState>(
  'preserves filters on refresh',
  build: () {
    when(mockUseCase(
      jlptLevel: 'N4',
    )).thenAnswer((_) async => data);
    return bloc;
  },
  seed: () => LoadedState(
    data: oldData,
    appliedJlptFilter: 'N4',
  ),
  act: (bloc) => bloc.add(RefreshEvent()),
  verify: (_) {
    verify(mockUseCase(jlptLevel: 'N4')).called(1);
  },
);
```

### Pattern 4: Error Handling Test
```dart
blocTest<KanjiBloc, KanjiState>(
  'emits error when exception thrown',
  build: () {
    when(mockUseCase()).thenThrow(CustomException('Error'));
    return bloc;
  },
  act: (bloc) => bloc.add(SomeEvent()),
  expect: () => [
    Loading(),
    ErrorState('Error'),
  ],
);
```

---

## ✅ Benefits of bloc_test

1. **Cleaner Syntax**: Easier to read and write
2. **Type Safety**: Compile-time checks for states
3. **Time Control**: `wait` parameter for async delays
4. **Seed State**: Initialize bloc with specific state
5. **Verify Calls**: Check use case interactions
6. **Skip States**: Focus on important state changes

---

## 📝 Next Steps

1. ✅ Create kanji_list_bloc_test.dart (Priority 1)
2. ✅ Create auth_bloc_test.dart (Priority 2 - critical for tests)
3. ✅ Create flashcard_bloc_test.dart (Priority 3)
4. ✅ Create quiz_bloc_test.dart (Priority 4)
5. ✅ Create category_bloc_test.dart (Priority 5)
6. ✅ Generate mocks: `flutter pub run build_runner build`
7. ✅ Run all tests: `flutter test`
8. ✅ Review coverage: aim for >80% bloc coverage

---

**Status**: Documentation Complete  
**Ready For**: Implementation
