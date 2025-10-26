# 🔥 TODO FIX PHASE 2 - Implementation Checklist

## 📊 Overall Progress: 35% Complete

**Last Updated:** October 22, 2025

---

## ✅ PRIORITY 1: CRITICAL FIXES (100% COMPLETE)

### 1.1 UI Overflow Issues ✅
- [x] **kanji_grid_item.dart** - Fixed RenderFlex overflow by 12 pixels
  - Reduced padding from 8 to 6
  - Changed fontSize from 48 to 42
  - Added Flexible + FittedBox wrapper
  - Added mainAxisSize: MainAxisSize.min
  - **Status:** FIXED ✅

### 1.2 API Endpoint Configuration ✅
- [x] **api_endpoints.dart** - Added `/api` prefix to baseUrl
  - Changed: `http://10.0.2.2:3000` → `http://10.0.2.2:3000/api`
  - **Impact:** Fixed Kanji, Quiz, Auth endpoints (200 OK)
  - **Status:** FIXED ✅

### 1.3 Hive Initialization ✅
- [x] **main.dart** - Added `Hive.initFlutter()`
  - Fixed HiveError preventing local storage
  - **Status:** FIXED ✅

---

## 🔥 PRIORITY 2: BACKEND INTEGRATION - NEW MODULES (30% COMPLETE)

### 2.1 Kanji Recognition Module (70% ⚠️ IN PROGRESS)

**Backend Endpoint:**
- `POST /api/kanji-recognition/recognize` - Recognize kanji from canvas drawing
- `GET /api/kanji-recognition/health` - Check CNN model health

**Implementation:**

#### Data Layer (100% COMPLETE) ✅
- [x] Create `KanjiRecognitionRequest` model (base64 image)
- [x] Create `KanjiRecognitionResult` model (character, confidence, top5)
- [x] Add `recognizeKanji()` to `KanjiRemoteDataSource`
- [x] Add `recognizeKanji()` to `KanjiRepositoryImpl`

#### Domain Layer (100% COMPLETE) ✅
- [x] Create `KanjiRecognitionResultEntity` entity
- [x] Create `Top5Prediction` entity
- [x] Create `RecognizeKanji` UseCase
- [x] Update `KanjiRepository` interface

#### Presentation Layer (0% TODO) 🔴
- [ ] Add `RecognizeKanjiEvent` to `KanjiBloc`
  - Event params: `String base64Image`
- [ ] Add `KanjiRecognitionInProgress` state
- [ ] Add `KanjiRecognitionSuccess(KanjiRecognitionResultEntity result)` state
- [ ] Add `KanjiRecognitionFailure(String message)` state
- [ ] Handle event in bloc:
  ```dart
  on<RecognizeKanjiEvent>((event, emit) async {
    emit(KanjiRecognitionInProgress());
    final result = await recognizeKanji(event.base64Image);
    result.fold(
      (failure) => emit(KanjiRecognitionFailure(failure.message)),
      (data) => emit(KanjiRecognitionSuccess(data)),
    );
  });
  ```

#### UI Integration (0% TODO) 🔴
- [ ] Find existing canvas drawing page (check Translation page or create new)
- [ ] Add "Recognize" button on canvas
- [ ] Convert canvas to base64 image:
  ```dart
  final image = await canvasController.toPng();
  final base64 = base64Encode(image);
  final dataUrl = 'data:image/png;base64,$base64';
  ```
- [ ] Dispatch `RecognizeKanjiEvent` with base64
- [ ] Show loading indicator during recognition
- [ ] Display results:
  - Top prediction with confidence (large)
  - Top 5 predictions in grid below
  - Each card shows character + confidence %
- [ ] Add "Search This Kanji" button for each result
- [ ] Handle errors with snackbar

#### Testing (0% TODO) 🔴
- [ ] Unit test: `recognize_kanji_test.dart` (8 tests)
- [ ] BLoC test: Recognition events/states (6 tests)
- [ ] Widget test: Canvas recognition UI (5 tests)
- [ ] Integration test: E2E canvas → recognition → results

**Files to Create/Modify:**
- `lib/features/kanji/presentation/bloc/kanji_bloc.dart` (add events/states)
- `lib/features/kanji/presentation/bloc/kanji_event.dart` (add RecognizeKanjiEvent)
- `lib/features/kanji/presentation/bloc/kanji_state.dart` (add recognition states)
- `lib/features/kanji/presentation/pages/kanji_recognition_page.dart` (NEW)
- `test/features/kanji/presentation/bloc/kanji_bloc_recognize_test.dart` (NEW)

**Estimated Time:** 1 day

---

### 2.2 Flashcard Deck Management (0% TODO) 🔴

**Backend Endpoints:**
```
GET    /api/flashcard-decks                          - Get all decks
GET    /api/flashcard-decks/:id                      - Get single deck
POST   /api/flashcard-decks                          - Create deck
PUT    /api/flashcard-decks/:id                      - Update deck
DELETE /api/flashcard-decks/:id                      - Delete deck
POST   /api/flashcard-decks/:id/cards/:kanjiId       - Add card
DELETE /api/flashcard-decks/:id/cards/:kanjiId       - Remove card
POST   /api/flashcard-decks/:id/publish              - Request publish
```

#### Data Layer (0% TODO) 🔴
- [ ] Create `FlashcardDeckModel`:
  ```dart
  class FlashcardDeckModel {
    final int id;
    final String name;
    final String? description;
    final int userId;
    final bool isPublic;
    final DateTime createdAt;
    final DateTime updatedAt;
    final List<FlashcardCardModel> cards;
    final UserModel user;
  }
  ```
- [ ] Create `FlashcardCardModel`:
  ```dart
  class FlashcardCardModel {
    final int id;
    final int deckId;
    final int kanjiId;
    final String front;
    final String back;
    final KanjiModel kanji;
  }
  ```
- [ ] Create `FlashcardDeckRemoteDataSource` interface
- [ ] Implement `FlashcardDeckRemoteDataSourceImpl`:
  - `getAllDecks({search, limit, offset})`
  - `getDeckById(id)`
  - `createDeck(name, description, kanjiIds)`
  - `updateDeck(id, {name, description, isPublic})`
  - `deleteDeck(id)`
  - `addCardToDeck(deckId, kanjiId)`
  - `removeCardFromDeck(deckId, kanjiId)`
- [ ] Create `FlashcardDeckRepositoryImpl`

#### Domain Layer (0% TODO) 🔴
- [ ] Create `FlashcardDeck` entity
- [ ] Create `FlashcardCard` entity
- [ ] Create `FlashcardDeckRepository` interface
- [ ] Create UseCases:
  - [ ] `GetAllDecks` (5 tests)
  - [ ] `GetDeckById` (6 tests)
  - [ ] `CreateDeck` (7 tests)
  - [ ] `UpdateDeck` (6 tests)
  - [ ] `DeleteDeck` (5 tests)
  - [ ] `AddCardToDeck` (6 tests)
  - [ ] `RemoveCardFromDeck` (6 tests)

#### Presentation Layer (0% TODO) 🔴
- [ ] Create `FlashcardDeckBloc`:
  - Events: `LoadDecks`, `LoadDeck`, `CreateDeck`, `UpdateDeck`, `DeleteDeck`, `AddCard`, `RemoveCard`
  - States: `Initial`, `Loading`, `DecksLoaded`, `DeckLoaded`, `DeckCreated`, `DeckUpdated`, `DeckDeleted`, `CardAdded`, `CardRemoved`, `Error`
- [ ] Create pages:
  - [ ] `DeckListPage` - Browse all decks (replace fake data)
  - [ ] `DeckDetailPage` - View cards, manage deck
  - [ ] `CreateDeckPage` - Create with kanji selection
  - [ ] `EditDeckPage` - Edit name/description
- [ ] Create widgets:
  - [ ] `DeckCard` - Display deck summary
  - [ ] `FlashcardCardWidget` - Display single card
  - [ ] `KanjiSelectionDialog` - Select kanji for deck

#### Testing (0% TODO) 🔴
- [ ] Unit tests: 7 UseCase tests × 6 tests each = 42 tests
- [ ] BLoC tests: 12 tests for deck operations
- [ ] Widget tests: 4 pages × 6 tests each = 24 tests
- [ ] Integration test: E2E deck creation → card practice

**Files to Create:**
- `lib/features/flashcard/data/models/flashcard_deck_model.dart`
- `lib/features/flashcard/data/models/flashcard_card_model.dart`
- `lib/features/flashcard/data/datasources/flashcard_deck_remote_datasource.dart`
- `lib/features/flashcard/data/repositories/flashcard_deck_repository_impl.dart`
- `lib/features/flashcard/domain/entities/flashcard_deck.dart`
- `lib/features/flashcard/domain/entities/flashcard_card.dart`
- `lib/features/flashcard/domain/repositories/flashcard_deck_repository.dart`
- `lib/features/flashcard/domain/usecases/*.dart` (7 files)
- `lib/features/flashcard/presentation/bloc/flashcard_deck_bloc.dart`
- `lib/features/flashcard/presentation/pages/*.dart` (4 files)
- `lib/features/flashcard/presentation/widgets/*.dart` (3 files)
- `test/features/flashcard/domain/usecases/*.dart` (7 files)
- `test/features/flashcard/presentation/bloc/flashcard_deck_bloc_test.dart`
- `test/features/flashcard/presentation/pages/*.dart` (4 files)

**Estimated Time:** 3 days

---

### 2.3 Kanji List Management (0% TODO) 🔴

**Backend Endpoints:**
```
GET    /api/kanji-lists                              - Get all lists
GET    /api/kanji-lists/:id                          - Get single list
POST   /api/kanji-lists                              - Create list
PUT    /api/kanji-lists/:id                          - Update list
DELETE /api/kanji-lists/:id                          - Delete list
POST   /api/kanji-lists/:id/kanji/:kanjiId           - Add kanji
DELETE /api/kanji-lists/:id/kanji/:kanjiId           - Remove kanji
POST   /api/kanji-lists/:id/publish                  - Request publish
```

#### Data Layer (0% TODO) 🔴
- [ ] Create `KanjiListModel`:
  ```dart
  class KanjiListModel {
    final int id;
    final String name;
    final String? description;
    final int userId;
    final bool isPublic;
    final int? categoryId;
    final DateTime createdAt;
    final DateTime updatedAt;
    final List<KanjiModel> kanji;
    final UserModel user;
  }
  ```
- [ ] Create `KanjiListRemoteDataSource` interface
- [ ] Implement `KanjiListRemoteDataSourceImpl`:
  - `getAllLists({search, type, limit, offset})`
  - `getListById(id)`
  - `createList(name, description, categoryId, kanjiIds)`
  - `updateList(id, {name, description, isPublic, categoryId})`
  - `deleteList(id)`
  - `addKanjiToList(listId, kanjiId)`
  - `removeKanjiFromList(listId, kanjiId)`
- [ ] Create `KanjiListRepositoryImpl`

#### Domain Layer (0% TODO) 🔴
- [ ] Create `KanjiList` entity
- [ ] Create `KanjiListRepository` interface
- [ ] Create UseCases:
  - [ ] `GetAllKanjiLists` (5 tests)
  - [ ] `GetKanjiListById` (6 tests)
  - [ ] `CreateKanjiList` (7 tests)
  - [ ] `UpdateKanjiList` (6 tests)
  - [ ] `DeleteKanjiList` (5 tests)
  - [ ] `AddKanjiToList` (6 tests)
  - [ ] `RemoveKanjiFromList` (6 tests)

#### Presentation Layer (0% TODO) 🔴
- [ ] Create `KanjiListBloc`:
  - Events: `LoadLists`, `LoadList`, `CreateList`, `UpdateList`, `DeleteList`, `AddKanji`, `RemoveKanji`
  - States: `Initial`, `Loading`, `ListsLoaded`, `ListLoaded`, `ListCreated`, `ListUpdated`, `ListDeleted`, `KanjiAdded`, `KanjiRemoved`, `Error`
- [ ] Create pages:
  - [ ] `KanjiListsPage` - Browse all custom lists
  - [ ] `KanjiListDetailPage` - View kanji in list
  - [ ] `CreateKanjiListPage` - Create with kanji selection
  - [ ] `EditKanjiListPage` - Edit name/description
- [ ] Create widgets:
  - [ ] `KanjiListCard` - Display list summary
  - [ ] `KanjiListItemWidget` - Kanji in list

#### Testing (0% TODO) 🔴
- [ ] Unit tests: 7 UseCase tests × 6 tests each = 42 tests
- [ ] BLoC tests: 12 tests for list operations
- [ ] Widget tests: 4 pages × 6 tests each = 24 tests
- [ ] Integration test: E2E list creation → kanji management

**Files to Create:**
- `lib/features/kanji_list/data/models/kanji_list_model.dart`
- `lib/features/kanji_list/data/datasources/kanji_list_remote_datasource.dart`
- `lib/features/kanji_list/data/repositories/kanji_list_repository_impl.dart`
- `lib/features/kanji_list/domain/entities/kanji_list.dart`
- `lib/features/kanji_list/domain/repositories/kanji_list_repository.dart`
- `lib/features/kanji_list/domain/usecases/*.dart` (7 files)
- `lib/features/kanji_list/presentation/bloc/kanji_list_bloc.dart`
- `lib/features/kanji_list/presentation/pages/*.dart` (4 files)
- `lib/features/kanji_list/presentation/widgets/*.dart` (2 files)
- `test/features/kanji_list/domain/usecases/*.dart` (7 files)
- `test/features/kanji_list/presentation/bloc/kanji_list_bloc_test.dart`
- `test/features/kanji_list/presentation/pages/*.dart` (4 files)

**Estimated Time:** 3 days

---

### 2.4 Advanced Kanji Search (60% ⚠️ PARTIAL)

**Current Status:**
- ✅ Basic search works (text query)
- ❌ Radical filter not implemented
- ❌ Stroke count filter not implemented
- ❌ Canvas draw search not connected

**Backend Endpoint:**
- `GET /api/kanji/search?query=...&jlptLevels=...&grades=...&minStrokes=...&maxStrokes=...`

#### UI Enhancements (0% TODO) 🔴
- [ ] Add filter drawer to `KanjiListPage`:
  - [ ] JLPT level chips (N5, N4, N3, N2, N1)
  - [ ] Grade filter (1-6, 中学, 高校, 常用)
  - [ ] Stroke count range slider (1-30)
  - [ ] Sort options (character, frequency, jlpt, strokes)
- [ ] Add "Draw to Search" FAB:
  - [ ] Opens canvas dialog
  - [ ] Converts drawing to kanji recognition
  - [ ] Auto-searches for recognized character
- [ ] Improve search results:
  - [ ] Show search stats (X results found)
  - [ ] Add "Clear filters" button
  - [ ] Persist filters in Hive

#### Testing (0% TODO) 🔴
- [ ] Widget test: Filter drawer (8 tests)
- [ ] Integration test: Search with filters
- [ ] Integration test: Canvas → recognition → search

**Estimated Time:** 1 day

---

### 2.5 User Profile Management (0% TODO) 🔴

**Backend Endpoint:**
- `PUT /api/user/profile` - Update name and avatar

**Current Status:**
- ❌ Shows "Coming Soon" snackbar
- ❌ No avatar upload
- ❌ No name edit

#### Implementation (0% TODO) 🔴
- [ ] Create `UpdateProfileUseCase`
- [ ] Add to AuthBloc:
  - [ ] `UpdateProfileEvent(name, File? avatar)`
  - [ ] `ProfileUpdating` state
  - [ ] `ProfileUpdated(User user)` state
  - [ ] `ProfileUpdateFailure(message)` state
- [ ] Modify `ProfilePage`:
  - [ ] Add "Edit Profile" button
  - [ ] Show edit dialog:
    - [ ] Text field for name
    - [ ] Avatar picker (image_picker package)
    - [ ] Save/Cancel buttons
  - [ ] Upload as multipart/form-data
  - [ ] Update cached user in AuthBloc
  - [ ] Show success snackbar

#### Testing (0% TODO) 🔴
- [ ] Unit test: `update_profile_test.dart` (7 tests)
- [ ] BLoC test: Profile update flow (6 tests)
- [ ] Widget test: Edit profile dialog (5 tests)

**Files to Modify:**
- `lib/features/auth/domain/usecases/update_profile.dart` (NEW)
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/features/auth/presentation/bloc/auth_bloc.dart`
- `lib/features/profile/presentation/pages/profile_page.dart`
- `test/features/auth/domain/usecases/update_profile_test.dart` (NEW)

**Dependencies to Add:**
```yaml
dependencies:
  image_picker: ^1.0.7
```

**Estimated Time:** 1 day

---

### 2.6 Real Statistics & Dashboard (0% TODO) 🔴

**Backend Endpoint:**
- `GET /api/stats/dashboard` - Get user statistics

**Expected Response:**
```json
{
  "totalKanjiLearned": 250,
  "flashcardsReviewed": 540,
  "quizAccuracy": 86,
  "streakDays": 5,
  "weeklyProgress": [10, 15, 8, 20, 12, 18, 14]
}
```

**Current Status:**
- ❌ Dashboard shows fake hardcoded data
- ❌ Profile stats are fake
- ❌ No API integration

#### Implementation (0% TODO) 🔴
- [ ] Create `StatisticsModel`:
  ```dart
  class StatisticsModel {
    final int totalKanjiLearned;
    final int flashcardsReviewed;
    final int quizAccuracy;
    final int streakDays;
    final List<int> weeklyProgress;
  }
  ```
- [ ] Create `StatsRemoteDataSource`
- [ ] Create `GetUserStatistics` UseCase
- [ ] Create `StatisticsBloc`:
  - [ ] `LoadStatistics` event
  - [ ] `StatisticsLoading` state
  - [ ] `StatisticsLoaded(Statistics stats)` state
  - [ ] `StatisticsError(message)` state
- [ ] Update `DashboardPage`:
  - [ ] Replace fake data with BLoC data
  - [ ] Add animated counters (TweenAnimationBuilder)
  - [ ] Add weekly progress chart (fl_chart package)
  - [ ] Add refresh indicator
  - [ ] Cache data in Hive
- [ ] Update `ProfilePage`:
  - [ ] Replace fake stats with real data
  - [ ] Show loading shimmer

#### Testing (0% TODO) 🔴
- [ ] Unit test: `get_user_statistics_test.dart` (6 tests)
- [ ] BLoC test: Statistics loading (8 tests)
- [ ] Widget test: Dashboard with stats (6 tests)

**Files to Create:**
- `lib/features/statistics/data/models/statistics_model.dart`
- `lib/features/statistics/data/datasources/stats_remote_datasource.dart`
- `lib/features/statistics/data/repositories/stats_repository_impl.dart`
- `lib/features/statistics/domain/entities/statistics.dart`
- `lib/features/statistics/domain/repositories/stats_repository.dart`
- `lib/features/statistics/domain/usecases/get_user_statistics.dart`
- `lib/features/statistics/presentation/bloc/statistics_bloc.dart`
- `test/features/statistics/domain/usecases/get_user_statistics_test.dart`
- `test/features/statistics/presentation/bloc/statistics_bloc_test.dart`

**Dependencies to Add:**
```yaml
dependencies:
  fl_chart: ^0.66.0
```

**Estimated Time:** 2 days

---

## 🎨 PRIORITY 3: ENHANCED FEATURES (10% COMPLETE)

### 3.1 Stroke Order Animation (0% TODO) 🔴

**Problem:**
- Kanji detail page does not show stroke order animation

**Solution:**
- Integrate **KanjiVG API** or **Jisho.org**

#### Implementation (0% TODO) 🔴
- [ ] Research KanjiVG API:
  - URL pattern: `https://kanjivg.tagaini.net/kanjivg/kanji/{unicode}.svg`
  - Example: `https://kanjivg.tagaini.net/kanjivg/kanji/06f22.svg` (漢)
- [ ] Create `StrokeOrderWidget`:
  - [ ] Fetch SVG from KanjiVG
  - [ ] Parse SVG paths
  - [ ] Animate each stroke sequentially
  - [ ] Add controls:
    - [ ] Play/Pause button
    - [ ] Replay button
    - [ ] Speed slider (0.5x, 1x, 2x)
    - [ ] Step through strokes (< >)
- [ ] Add to `KanjiDetailPage`:
  - [ ] New section: "Stroke Order"
  - [ ] Display animated SVG
  - [ ] Show stroke count
- [ ] Cache SVG locally (Hive)

#### Testing (0% TODO) 🔴
- [ ] Widget test: Stroke order animation (5 tests)
- [ ] Integration test: Load and animate strokes

**Dependencies to Add:**
```yaml
dependencies:
  flutter_svg: ^2.0.9
  path_drawing: ^1.0.1
```

**Files to Create:**
- `lib/features/kanji/presentation/widgets/stroke_order_widget.dart`
- `lib/core/services/kanjivg_service.dart`
- `test/features/kanji/presentation/widgets/stroke_order_widget_test.dart`

**Estimated Time:** 2 days

---

### 3.2 Example Sentences + Audio (0% TODO) 🔴

**Problem:**
- Kanji details do not include example sentences or pronunciation

**Solution:**
- Integrate **Kanji Alive RapidAPI**

#### Implementation (0% TODO) 🔴
- [ ] Add RapidAPI key to `.env`:
  ```
  RAPIDAPI_KEY=ab84e2d5d7mshec320cda6671a01p122264jsnfa7b71b22317
  ```
- [ ] Create `KanjiAliveService`:
  - [ ] `getKanjiExamples(character)`:
    - Endpoint: `https://kanjialive-api.p.rapidapi.com/api/public/kanji/{char}`
    - Headers: `x-rapidapi-host`, `x-rapidapi-key`
  - [ ] Parse response for:
    - Example words
    - Example sentences
    - Audio pronunciation URLs
- [ ] Create `ExampleSentence` model:
  ```dart
  class ExampleSentence {
    final String japanese;
    final String reading;
    final String meaning;
    final String? audioUrl;
  }
  ```
- [ ] Add to `KanjiDetailPage`:
  - [ ] New section: "Examples"
  - [ ] List view with cards:
    - Japanese word/sentence
    - Reading (furigana)
    - English meaning
    - 🔊 Play button (audioplayers package)
  - [ ] Load on demand (separate BLoC event)
  - [ ] Cache examples locally

#### Testing (0% TODO) 🔴
- [ ] Unit test: Kanji Alive API service (5 tests)
- [ ] Widget test: Example sentences list (6 tests)
- [ ] Integration test: Load and play audio

**Dependencies to Add:**
```yaml
dependencies:
  audioplayers: ^5.2.1
  http: ^1.2.0
```

**Files to Create:**
- `lib/core/services/kanji_alive_service.dart`
- `lib/features/kanji/data/models/example_sentence_model.dart`
- `lib/features/kanji/domain/entities/example_sentence.dart`
- `lib/features/kanji/presentation/widgets/example_sentences_list.dart`
- `test/core/services/kanji_alive_service_test.dart`
- `test/features/kanji/presentation/widgets/example_sentences_list_test.dart`

**Estimated Time:** 2 days

---

### 3.3 Speech-to-Text Translation (0% TODO) 🔴

**Problem:**
- `TranslationPage` shows "speech recognition not available" snackbar
- Widget lifecycle error: "State no longer has a context"

**Current Issues:**
```
[ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: 
This widget has been unmounted, so the State no longer has a context
```

#### Implementation (0% TODO) 🔴
- [ ] Fix widget lifecycle error:
  - [ ] Add `if (!mounted) return;` checks before `setState` or `context` usage
  - [ ] Example:
    ```dart
    void _showSnackBar(String message) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    ```
- [ ] Install `speech_to_text` package:
  ```yaml
  dependencies:
    speech_to_text: ^6.5.1
    permission_handler: ^11.2.0
  ```
- [ ] Initialize `SpeechToText`:
  ```dart
  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _isAvailable = await _speech.initialize(
      onError: (error) => _showError(error.errorMsg),
      onStatus: (status) => print('Speech status: $status'),
    );
    if (mounted) setState(() {});
  }
  ```
- [ ] Add to TranslationBloc:
  - [ ] `StartListeningEvent(Locale locale)`
  - [ ] `StopListeningEvent`
  - [ ] `SpeechListening` state
  - [ ] `SpeechResult(String text)` state
  - [ ] `SpeechError(String message)` state
- [ ] Handle mic button:
  ```dart
  void _startListening() async {
    if (!_isAvailable) {
      _showError('Speech recognition not available');
      return;
    }
    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          context.read<TranslationBloc>().add(
            TranslateTextEvent(result.recognizedWords),
          );
        }
      },
      localeId: 'ja_JP', // Japanese
    );
  }
  ```
- [ ] Request permissions:
  ```dart
  final status = await Permission.microphone.request();
  if (!status.isGranted) {
    _showError('Microphone permission denied');
  }
  ```
- [ ] Add permissions to `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.RECORD_AUDIO"/>
  <uses-permission android:name="android.permission.INTERNET"/>
  ```

#### Testing (0% TODO) 🔴
- [ ] Unit test: Speech recognition mock (5 tests)
- [ ] Widget test: Mic button interaction (6 tests)
- [ ] Integration test: E2E speech → translation

**Files to Modify:**
- `lib/features/translation/presentation/pages/translation_page.dart`
- `lib/features/translation/presentation/bloc/translation_bloc.dart`
- `android/app/src/main/AndroidManifest.xml`
- `test/features/translation/presentation/pages/translation_page_test.dart`

**Estimated Time:** 1 day

---

## 🧪 PRIORITY 4: TESTING & VALIDATION (40% COMPLETE)

### 4.1 Unit Tests (60% COMPLETE) ⚠️

**Current Status:**
- ✅ Auth: 60 tests passing
- ✅ Kanji: 39 tests passing
- ✅ Flashcard: 21/23 tests (2 failing due to BLoC async bug)
- ✅ Quiz: 49 tests passing
- ❌ Translation: 0 tests
- ❌ Profile: 0 tests
- ❌ Statistics: 0 tests

**TODO:**
- [ ] Fix 2 failing Flashcard BLoC tests (async handling)
- [ ] Add Translation UseCase tests (3 UseCases × 6 tests = 18 tests)
- [ ] Add Profile UseCase tests (update_profile: 7 tests)
- [ ] Add Statistics UseCase tests (get_statistics: 6 tests)
- [ ] Add Kanji Recognition UseCase tests (recognize_kanji: 8 tests)
- [ ] Add Flashcard Deck UseCase tests (7 UseCases × 6 tests = 42 tests)
- [ ] Add Kanji List UseCase tests (7 UseCases × 6 tests = 42 tests)

**Target:** 300+ unit tests total

---

### 4.2 BLoC Tests (50% COMPLETE) ⚠️

**Current Status:**
- ✅ AuthBloc: 13 tests passing
- ✅ KanjiBloc: 13 tests passing
- ✅ FlashcardBloc: 10/12 tests (2 failing)
- ✅ QuizBloc: Tests exist
- ❌ TranslationBloc: 0 tests
- ❌ StatisticsBloc: 0 tests
- ❌ FlashcardDeckBloc: 0 tests
- ❌ KanjiListBloc: 0 tests

**TODO:**
- [ ] Fix 2 failing FlashcardBloc tests
- [ ] Add TranslationBloc tests (10 tests)
- [ ] Add StatisticsBloc tests (8 tests)
- [ ] Add FlashcardDeckBloc tests (12 tests)
- [ ] Add KanjiListBloc tests (12 tests)
- [ ] Add Kanji recognition to KanjiBloc tests (6 tests)

**Target:** 100+ BLoC tests total

---

### 4.3 Widget Tests (20% COMPLETE) ⚠️

**Current Status:**
- ✅ LoginPage: 6 tests passing
- ❌ Most pages: 0 tests

**TODO:**
- [ ] RegisterPage widget tests (6 tests)
- [ ] KanjiListPage widget tests (8 tests)
- [ ] KanjiDetailPage widget tests (8 tests)
- [ ] DashboardPage widget tests (6 tests)
- [ ] ProfilePage widget tests (6 tests)
- [ ] TranslationPage widget tests (8 tests)
- [ ] QuizListPage widget tests (6 tests)
- [ ] QuizTakePage widget tests (10 tests)
- [ ] FlashcardPracticePage widget tests (8 tests)
- [ ] StrokeOrderWidget tests (5 tests)
- [ ] ExampleSentencesList tests (6 tests)

**Target:** 80+ widget tests total

---

### 4.4 Integration Tests (10% COMPLETE) ⚠️

**Current Status:**
- ✅ `auth_navigation_test.dart`: 15 tests created (not run yet)
- ✅ `home_navigation_test.dart`: 12 tests created (not run yet)

**TODO:**
- [ ] Run existing integration tests with backend
- [ ] Add integration tests:
  - [ ] `kanji_flow_test.dart`: Browse → Detail → Search → Recognition (8 tests)
  - [ ] `flashcard_flow_test.dart`: Deck list → Create → Practice → Review (10 tests)
  - [ ] `quiz_flow_test.dart`: List → Start → Answer → Results (8 tests)
  - [ ] `translation_flow_test.dart`: Input → STT → Translate → TTS (6 tests)
  - [ ] `profile_flow_test.dart`: View → Edit → Update → Logout (6 tests)

**Target:** 65+ integration tests total

**Command to run:**
```bash
flutter test integration_test/
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/auth_navigation_test.dart
```

---

### 4.5 End-to-End Testing (0% TODO) 🔴

**TODO:**
- [ ] Set up E2E test environment:
  - [ ] Ensure backend is running with test database
  - [ ] Seed test data (users, kanji, quizzes)
  - [ ] Configure test auth tokens
- [ ] Create E2E test scenarios:
  - [ ] Complete user journey: Register → Login → Browse → Quiz → Flashcard → Profile → Logout
  - [ ] Kanji recognition: Canvas draw → CNN predict → Search results
  - [ ] Flashcard creation: Select kanji → Create deck → Practice → SRS review
  - [ ] Profile update: Edit name → Upload avatar → Save
- [ ] Run E2E tests in CI/CD pipeline
- [ ] Generate coverage report:
  ```bash
  flutter test --coverage
  genhtml coverage/lcov.info -o coverage/html
  ```
- [ ] Document test results in `TEST_RESULTS.md`

**Target:** Full E2E coverage with ≥85% code coverage

---

## 🚀 PRIORITY 5: PERFORMANCE & UX (20% COMPLETE)

### 5.1 Loading States (40% COMPLETE) ⚠️

**Current Status:**
- ✅ Some pages have shimmer loading
- ❌ Inconsistent loading indicators
- ❌ No skeleton loaders

**TODO:**
- [ ] Standardize loading indicators across all pages
- [ ] Add shimmer effect for:
  - [ ] Kanji list loading
  - [ ] Quiz list loading
  - [ ] Flashcard deck loading
  - [ ] Profile stats loading
- [ ] Add skeleton loaders for:
  - [ ] Kanji detail page
  - [ ] Quiz taking page
  - [ ] Flashcard practice page
- [ ] Show progress indicators for:
  - [ ] Image uploads
  - [ ] Audio loading
  - [ ] Canvas recognition

**Dependencies:**
```yaml
dependencies:
  shimmer: ^3.0.0
```

---

### 5.2 Error Handling (30% COMPLETE) ⚠️

**Current Status:**
- ✅ Basic error states in BLoCs
- ❌ No retry mechanism
- ❌ No offline support

**TODO:**
- [ ] Implement retry logic:
  - [ ] Add "Retry" button on error screens
  - [ ] Exponential backoff for network errors
  - [ ] Max retry count (3 attempts)
- [ ] Add offline support:
  - [ ] Cache API responses in Hive
  - [ ] Show cached data with "Offline" badge
  - [ ] Queue mutations for sync when online
- [ ] Improve error messages:
  - [ ] User-friendly messages instead of technical errors
  - [ ] Localized error strings
  - [ ] Error logging to analytics

---

### 5.3 Caching & Persistence (20% COMPLETE) ⚠️

**Current Status:**
- ✅ Hive initialized
- ✅ Auth token cached
- ❌ No data caching

**TODO:**
- [ ] Cache kanji list in Hive (TTL: 24 hours)
- [ ] Cache kanji details (TTL: 7 days)
- [ ] Cache quiz results locally
- [ ] Cache user profile
- [ ] Cache statistics (TTL: 1 hour)
- [ ] Cache flashcard decks
- [ ] Implement cache invalidation:
  - [ ] On pull-to-refresh
  - [ ] On logout
  - [ ] On TTL expiry

---

### 5.4 Navigation & Routing (50% COMPLETE) ⚠️

**Current Status:**
- ✅ Bottom navigation works
- ✅ Basic page transitions
- ❌ No deep linking
- ❌ No route guards

**TODO:**
- [ ] Implement deep linking:
  - [ ] `/kanji/:id` - Direct link to kanji detail
  - [ ] `/quiz/:id` - Direct link to quiz
  - [ ] `/deck/:id` - Direct link to flashcard deck
- [ ] Add route guards:
  - [ ] Redirect to login if not authenticated
  - [ ] Redirect to home if already logged in (on login page)
  - [ ] Check permissions before admin pages
- [ ] Improve transitions:
  - [ ] Hero animations for kanji cards
  - [ ] Slide transitions for page navigation
  - [ ] Fade animations for dialogs

---

## 📚 PRIORITY 6: DOCUMENTATION (30% COMPLETE)

### 6.1 Code Documentation (40% COMPLETE) ⚠️

**TODO:**
- [ ] Add dartdoc comments to all public APIs
- [ ] Document complex logic with inline comments
- [ ] Add usage examples for custom widgets
- [ ] Generate API documentation:
  ```bash
  flutter pub global activate dartdoc
  dartdoc --output docs/api
  ```

---

### 6.2 README Updates (20% COMPLETE) ⚠️

**TODO:**
- [ ] Update `README.md` with:
  - [ ] Feature list with screenshots
  - [ ] Setup instructions
  - [ ] Environment variables
  - [ ] Running tests
  - [ ] Building for production
- [ ] Create `CONTRIBUTING.md`
- [ ] Create `CHANGELOG.md`

---

### 6.3 Architecture Documentation (30% COMPLETE) ⚠️

**TODO:**
- [ ] Create `ARCHITECTURE.md`:
  - [ ] Clean Architecture diagram
  - [ ] Folder structure explanation
  - [ ] Data flow diagrams
  - [ ] State management patterns
- [ ] Document API endpoints in `API.md`
- [ ] Create sequence diagrams for key flows

---

## 📦 DEPENDENCY INJECTION UPDATES

**Need to register in `injection_container.dart`:**

```dart
// Kanji Recognition
sl.registerLazySingleton(() => RecognizeKanji(sl()));

// Flashcard Deck
sl.registerLazySingleton<FlashcardDeckRemoteDataSource>(
  () => FlashcardDeckRemoteDataSourceImpl(dio: sl()),
);
sl.registerLazySingleton<FlashcardDeckRepository>(
  () => FlashcardDeckRepositoryImpl(remoteDataSource: sl()),
);
sl.registerLazySingleton(() => GetAllDecks(sl()));
sl.registerLazySingleton(() => GetDeckById(sl()));
sl.registerLazySingleton(() => CreateDeck(sl()));
sl.registerLazySingleton(() => UpdateDeck(sl()));
sl.registerLazySingleton(() => DeleteDeck(sl()));
sl.registerLazySingleton(() => AddCardToDeck(sl()));
sl.registerLazySingleton(() => RemoveCardFromDeck(sl()));
sl.registerFactory(() => FlashcardDeckBloc(/* inject usecases */));

// Kanji List
sl.registerLazySingleton<KanjiListRemoteDataSource>(
  () => KanjiListRemoteDataSourceImpl(dio: sl()),
);
sl.registerLazySingleton<KanjiListRepository>(
  () => KanjiListRepositoryImpl(remoteDataSource: sl()),
);
sl.registerLazySingleton(() => GetAllKanjiLists(sl()));
sl.registerLazySingleton(() => GetKanjiListById(sl()));
sl.registerLazySingleton(() => CreateKanjiList(sl()));
sl.registerLazySingleton(() => UpdateKanjiList(sl()));
sl.registerLazySingleton(() => DeleteKanjiList(sl()));
sl.registerLazySingleton(() => AddKanjiToList(sl()));
sl.registerLazySingleton(() => RemoveKanjiFromList(sl()));
sl.registerFactory(() => KanjiListBloc(/* inject usecases */));

// Statistics
sl.registerLazySingleton<StatsRemoteDataSource>(
  () => StatsRemoteDataSourceImpl(dio: sl()),
);
sl.registerLazySingleton<StatsRepository>(
  () => StatsRepositoryImpl(remoteDataSource: sl()),
);
sl.registerLazySingleton(() => GetUserStatistics(sl()));
sl.registerFactory(() => StatisticsBloc(getUserStatistics: sl()));

// Services
sl.registerLazySingleton(() => KanjiVGService());
sl.registerLazySingleton(() => KanjiAliveService(apiKey: dotenv.env['RAPIDAPI_KEY']!));
```

---

## 📋 DEPENDENCIES TO ADD

**pubspec.yaml updates:**

```yaml
dependencies:
  # Existing dependencies...
  
  # New for Phase 2
  image_picker: ^1.0.7           # Profile avatar upload
  audioplayers: ^5.2.1           # Example sentence audio
  speech_to_text: ^6.5.1         # STT translation
  permission_handler: ^11.2.0    # Mic permissions
  flutter_svg: ^2.0.9            # Stroke order SVG
  path_drawing: ^1.0.1           # SVG path animation
  fl_chart: ^0.66.0              # Statistics charts
  shimmer: ^3.0.0                # Loading skeletons
  http: ^1.2.0                   # KanjiAlive API

dev_dependencies:
  # Existing dev dependencies...
```

---

## 🎯 PHASE 2 COMPLETION CHECKLIST

### Critical (Must Have)
- [ ] Kanji Recognition (canvas → CNN → results)
- [ ] Flashcard Deck Management (CRUD + practice)
- [ ] Kanji List Management (CRUD + organize)
- [ ] Profile Update (name + avatar)
- [ ] Real Statistics Dashboard
- [ ] Speech-to-Text Translation
- [ ] Fix all UI overflow errors
- [ ] Fix widget lifecycle errors

### High Priority
- [ ] Advanced Kanji Search (filters + draw)
- [ ] Stroke Order Animation
- [ ] Example Sentences + Audio
- [ ] 300+ Unit Tests
- [ ] 100+ BLoC Tests
- [ ] 80+ Widget Tests
- [ ] 65+ Integration Tests

### Nice to Have
- [ ] Deep linking
- [ ] Offline support
- [ ] Performance optimizations
- [ ] Comprehensive documentation
- [ ] E2E test automation

---

## ⏱️ ESTIMATED TIMELINE

| Phase | Tasks | Duration | Status |
|-------|-------|----------|--------|
| **Week 1** | Kanji Recognition + Flashcard Deck | 5 days | 🔴 TODO |
| **Week 2** | Kanji List + Profile + Statistics | 5 days | 🔴 TODO |
| **Week 3** | Stroke Order + Examples + STT | 5 days | 🔴 TODO |
| **Week 4** | Testing + Documentation + Polish | 5 days | 🔴 TODO |

**Total Estimated Time:** 4 weeks (20 working days)

---

## 📊 SUCCESS METRICS

- ✅ All critical features implemented and working
- ✅ Zero UI overflow errors
- ✅ Zero widget lifecycle errors
- ✅ All API endpoints integrated correctly
- ✅ ≥85% test coverage
- ✅ All integration tests passing
- ✅ App passes E2E testing from backend → UI
- ✅ Performance: Time to interactive < 3s
- ✅ No memory leaks or performance issues
- ✅ Clean Architecture maintained throughout

---

## 🚀 NEXT IMMEDIATE STEPS

1. ✅ Complete Kanji Recognition presentation layer (1 day)
2. Start Flashcard Deck implementation (3 days)
3. Start Kanji List implementation (3 days)
4. Implement Profile Update (1 day)
5. Implement Real Statistics (2 days)
6. Fix Speech-to-Text (1 day)
7. Add Stroke Order Animation (2 days)
8. Add Example Sentences + Audio (2 days)
9. Write comprehensive tests (5 days)
10. Final polish and documentation (2 days)

---

**Document Version:** 1.0  
**Last Updated:** October 22, 2025  
**Overall Progress:** 35%  
**Status:** 🔴 Phase 2 In Progress
