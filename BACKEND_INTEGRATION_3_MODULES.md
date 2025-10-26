# 🔥 BACKEND INTEGRATION - 3 NEW MODULES

## Status: Ready to Implement

### ✅ Module 1: Kanji Recognition (COMPLETED - Data Layer)

**Backend Endpoints:**
- `POST /api/kanji-recognition/recognize` - Recognize kanji from base64 image
- `GET /api/kanji-recognition/health` - Check CNN model health

**Flutter Implementation:**

✅ **Data Layer (COMPLETE)**
- ✅ Models: `KanjiRecognitionRequest`, `KanjiRecognitionResult`
- ✅ Remote Datasource: `recognizeKanji()` method added
- ✅ Repository: `KanjiRepositoryImpl.recognizeKanji()` implemented

✅ **Domain Layer (COMPLETE)**
- ✅ Entity: `KanjiRecognitionResultEntity`, `Top5Prediction`
- ✅ UseCase: `RecognizeKanji` class created
- ✅ Repository interface: `recognizeKanji()` added

🔄 **Presentation Layer (TODO)**
- [ ] Add `RecognizeKanjiEvent` to KanjiBloc
- [ ] Add `KanjiRecognitionResult` state to KanjiBloc
- [ ] Integrate with existing canvas drawing page
- [ ] Show top 5 predictions in UI
- [ ] Handle loading/error states

---

### 📋 Module 2: Flashcard Deck Management

**Backend Endpoints:**
```
GET    /api/flashcard-decks                - Get all decks (public + user's)
GET    /api/flashcard-decks/:id            - Get single deck with cards
POST   /api/flashcard-decks                - Create new deck
PUT    /api/flashcard-decks/:id            - Update deck
DELETE /api/flashcard-decks/:id            - Delete deck
POST   /api/flashcard-decks/:id/cards/:kanjiId    - Add kanji to deck
DELETE /api/flashcard-decks/:id/cards/:kanjiId    - Remove kanji from deck
POST   /api/flashcard-decks/:id/publish    - Request publish (make public)
```

**Request/Response Models:**

```typescript
// GET /flashcard-decks - Response
{
  data: [{
    id: number,
    name: string,
    description?: string,
    userId: number,
    isPublic: boolean,
    createdAt: Date,
    updatedAt: Date,
    cards: [{
      id: number,
      deckId: number,
      kanjiId: number,
      front: string,
      back: string,
      kanji: {
        id: number,
        character: string,
        meaning: string,
        kunyomi?: string,
        onyomi?: string,
        jlpt?: number,
        grade?: number
      }
    }],
    user: {
      id: number,
      email: string,
      name?: string
    }
  }],
  total: number,
  limit: number,
  offset: number
}

// POST /flashcard-decks - Request
{
  name: string,
  description?: string,
  kanjiIds?: number[]  // Initial kanji to add
}

// PUT /flashcard-decks/:id - Request
{
  name?: string,
  description?: string,
  isPublic?: boolean
}
```

**Flutter Implementation TODO:**

🔄 **Data Layer**
- [ ] Models: `FlashcardDeckModel`, `FlashcardCardModel`
- [ ] Remote Datasource: `FlashcardDeckRemoteDataSource`
  - `getAllDecks()`
  - `getDeckById(id)`
  - `createDeck(name, description, kanjiIds)`
  - `updateDeck(id, data)`
  - `deleteDeck(id)`
  - `addCardToDeck(deckId, kanjiId)`
  - `removeCardFromDeck(deckId, kanjiId)`
- [ ] Repository: `FlashcardDeckRepositoryImpl`

🔄 **Domain Layer**
- [ ] Entity: `FlashcardDeck`, `FlashcardCard`
- [ ] UseCases:
  - `GetAllDecks`
  - `GetDeckById`
  - `CreateDeck`
  - `UpdateDeck`
  - `DeleteDeck`
  - `AddCardToDeck`
  - `RemoveCardFromDeck`
- [ ] Repository interface: `FlashcardDeckRepository`

🔄 **Presentation Layer**
- [ ] Create new BLoC: `FlashcardDeckBloc`
- [ ] Events: `LoadDecks`, `LoadDeck`, `CreateDeck`, `UpdateDeck`, `DeleteDeck`, `AddCard`, `RemoveCard`
- [ ] States: `Loading`, `Loaded`, `DeckLoaded`, `Error`
- [ ] Pages:
  - `DeckListPage` - Browse all decks (replace current fake data)
  - `DeckDetailPage` - View cards in deck, manage cards
  - `CreateDeckPage` - Create new deck with kanji selection
  - `EditDeckPage` - Edit deck name/description

---

### 📚 Module 3: Kanji List Management

**Backend Endpoints:**
```
GET    /api/kanji-lists                    - Get all lists (public + user's)
GET    /api/kanji-lists/:id                - Get single list with kanji
POST   /api/kanji-lists                    - Create new list
PUT    /api/kanji-lists/:id                - Update list
PATCH  /api/kanji-lists/:id                - Update list (alias)
DELETE /api/kanji-lists/:id                - Delete list
POST   /api/kanji-lists/:id/kanji/:kanjiId      - Add kanji to list
DELETE /api/kanji-lists/:id/kanji/:kanjiId      - Remove kanji from list
POST   /api/kanji-lists/:id/publish        - Request publish (make public)
```

**Query Params:**
```typescript
// GET /kanji-lists
{
  search?: string,   // Search by name/description
  type?: string,     // Filter by type
  limit?: number,    // Pagination limit
  offset?: number    // Pagination offset
}
```

**Request/Response Models:**

```typescript
// GET /kanji-lists - Response
{
  data: [{
    id: number,
    name: string,
    description?: string,
    userId: number,
    isPublic: boolean,
    categoryId?: number,
    createdAt: Date,
    updatedAt: Date,
    kanji: [{
      id: number,
      character: string,
      meaning: string,
      kunyomi?: string,
      onyomi?: string,
      jlpt?: number,
      grade?: number,
      strokeCount?: number
    }],
    user: {
      id: number,
      email: string,
      name?: string
    }
  }],
  total: number,
  limit: number,
  offset: number
}

// POST /kanji-lists - Request
{
  name: string,
  description?: string,
  categoryId?: number,
  kanjiIds?: number[]  // Initial kanji to add
}

// PUT /kanji-lists/:id - Request
{
  name?: string,
  description?: string,
  isPublic?: boolean,
  categoryId?: number
}
```

**Flutter Implementation TODO:**

🔄 **Data Layer**
- [ ] Models: `KanjiListModel`, `KanjiListItemModel`
- [ ] Remote Datasource: `KanjiListRemoteDataSource`
  - `getAllLists()`
  - `getListById(id)`
  - `createList(name, description, kanjiIds)`
  - `updateList(id, data)`
  - `deleteList(id)`
  - `addKanjiToList(listId, kanjiId)`
  - `removeKanjiFromList(listId, kanjiId)`
- [ ] Repository: `KanjiListRepositoryImpl`

🔄 **Domain Layer**
- [ ] Entity: `KanjiList`, `KanjiListItem`
- [ ] UseCases:
  - `GetAllLists`
  - `GetListById`
  - `CreateList`
  - `UpdateList`
  - `DeleteList`
  - `AddKanjiToList`
  - `RemoveKanjiFromList`
- [ ] Repository interface: `KanjiListRepository`

🔄 **Presentation Layer**
- [ ] Create new BLoC: `KanjiListBloc`
- [ ] Events: `LoadLists`, `LoadList`, `CreateList`, `UpdateList`, `DeleteList`, `AddKanji`, `RemoveKanji`
- [ ] States: `Loading`, `Loaded`, `ListLoaded`, `Error`
- [ ] Pages:
  - `KanjiListsPage` - Browse all custom lists
  - `KanjiListDetailPage` - View kanji in list, manage kanji
  - `CreateKanjiListPage` - Create new list with kanji selection
  - `EditKanjiListPage` - Edit list name/description

---

## 🎯 IMPLEMENTATION PRIORITY

### **Phase 1: Kanji Recognition (Highest Priority - COMPLETED DATA LAYER)**
- ✅ Data + Domain layers done
- 🔄 Presentation layer integration (1 day)
  - Add BLoC events/states
  - Integrate with canvas drawing page
  - Test end-to-end flow

### **Phase 2: Flashcard Deck (High Priority - 2-3 days)**
- Replace old fake flashcard module
- Full CRUD operations
- Deck management UI
- Card practice with spaced repetition

### **Phase 3: Kanji List (Medium Priority - 2-3 days)**
- New feature for organizing kanji
- Custom lists creation
- Share lists functionality
- Integration with flashcard creation

---

## 📦 Dependencies to Register

**In `injection_container.dart`:**

```dart
// Kanji Recognition (already have kanji module, just add usecase)
sl.registerLazySingleton(() => RecognizeKanji(sl()));

// Flashcard Deck
// Data sources
sl.registerLazySingleton<FlashcardDeckRemoteDataSource>(
  () => FlashcardDeckRemoteDataSourceImpl(dio: sl()),
);

// Repositories
sl.registerLazySingleton<FlashcardDeckRepository>(
  () => FlashcardDeckRepositoryImpl(remoteDataSource: sl()),
);

// Use cases
sl.registerLazySingleton(() => GetAllDecks(sl()));
sl.registerLazySingleton(() => GetDeckById(sl()));
sl.registerLazySingleton(() => CreateDeck(sl()));
sl.registerLazySingleton(() => UpdateDeck(sl()));
sl.registerLazySingleton(() => DeleteDeck(sl()));
sl.registerLazySingleton(() => AddCardToDeck(sl()));
sl.registerLazySingleton(() => RemoveCardFromDeck(sl()));

// BLoC
sl.registerFactory(() => FlashcardDeckBloc(
  getAllDecks: sl(),
  getDeckById: sl(),
  createDeck: sl(),
  updateDeck: sl(),
  deleteDeck: sl(),
  addCardToDeck: sl(),
  removeCardFromDeck: sl(),
));

// Kanji List
// Data sources
sl.registerLazySingleton<KanjiListRemoteDataSource>(
  () => KanjiListRemoteDataSourceImpl(dio: sl()),
);

// Repositories
sl.registerLazySingleton<KanjiListRepository>(
  () => KanjiListRepositoryImpl(remoteDataSource: sl()),
);

// Use cases
sl.registerLazySingleton(() => GetAllKanjiLists(sl()));
sl.registerLazySingleton(() => GetKanjiListById(sl()));
sl.registerLazySingleton(() => CreateKanjiList(sl()));
sl.registerLazySingleton(() => UpdateKanjiList(sl()));
sl.registerLazySingleton(() => DeleteKanjiList(sl()));
sl.registerLazySingleton(() => AddKanjiToList(sl()));
sl.registerLazySingleton(() => RemoveKanjiFromList(sl()));

// BLoC
sl.registerFactory(() => KanjiListBloc(
  getAllLists: sl(),
  getListById: sl(),
  createList: sl(),
  updateList: sl(),
  deleteList: sl(),
  addKanjiToList: sl(),
  removeKanjiFromList: sl(),
));
```

---

## 🧪 Testing Strategy

Each module requires:
1. ✅ Unit tests for UseCases (5-8 tests each)
2. ✅ Unit tests for BLoC (10-15 tests)
3. ✅ Widget tests for Pages (6-8 tests each)
4. ✅ Integration tests for E2E flows

**Test Coverage Target: ≥ 90%**

---

## 📝 Notes

- All endpoints require JWT authentication (except GET /decks and GET /lists with isPublic=true)
- Base URL already configured: `http://10.0.2.2:3000/api`
- Error handling: Use existing `_mapExceptionToFailure()` pattern
- State management: Follow existing BLoC pattern
- UI components: Reuse existing widgets (KanjiCard, LoadingIndicator, etc.)

---

## 🚀 Next Immediate Steps

1. ✅ Complete Kanji Recognition presentation layer integration
2. Start Flashcard Deck implementation (Data → Domain → Presentation)
3. Start Kanji List implementation (Data → Domain → Presentation)
4. Update routing for new pages
5. Write comprehensive tests
6. Update TODO_PHASE2.md with progress

**Estimated Total Time: 5-7 days**

**Current Progress:**
- Kanji Recognition: 70% (Data + Domain done, Presentation TODO)
- Flashcard Deck: 0%
- Kanji List: 0%
