# TODO - Phase 2 Implementation Plan

## 🎯 Based on fix.md Analysis

### Priority 1 - Critical Fixes (DONE)
- [x] Fix API endpoints (added `/api` prefix to baseUrl)
- [x] Initialize Hive for local storage
- [x] Fix UI overflow in kanji_grid_item.dart
- [x] Login/Navigation flow working

### Priority 2 - Backend Missing Features (HIGH)

#### 2.1 Flashcard Module - MISSING BACKEND
**Status**: ❌ Backend endpoint `/api/flashcard/decks` returns 404

**Requirements**:
- Create NestJS module: `src/modules/flashcard`
- Database schema: `Deck`, `Card`, `UserProgress`
- Endpoints needed:
  ```
  GET    /api/flashcard/decks           - Get all user's decks
  POST   /api/flashcard/decks           - Create new deck
  GET    /api/flashcard/decks/:id       - Get deck details
  PUT    /api/flashcard/decks/:id       - Update deck
  DELETE /api/flashcard/decks/:id       - Delete deck
  
  GET    /api/flashcard/cards/due       - Get due cards for review
  POST   /api/flashcard/cards/:id/review - Submit card review (SM-2 algorithm)
  ```

**SM-2 Spaced Repetition**:
- Algorithm: SuperMemo 2
- Fields: `interval`, `repetitions`, `easeFactor`, `nextReviewAt`
- Quality rating: 0-5 (0=complete blackout, 5=perfect recall)

**Frontend Status**:
- ✅ UI implemented
- ✅ BLoC implemented
- ✅ Repository/DataSource ready
- ❌ Backend missing

#### 2.2 Kanji Search Enhancement
**Status**: ⚠️ Basic search works, needs enhancement

**Missing Features**:
1. **Advanced Search**:
   - Search by radical
   - Search by stroke count range
   - Search by JLPT + Grade combination
   - Search by meaning (English)

2. **Canvas Draw Recognition**:
   - Button to open drawing canvas
   - Black canvas with white drawing
   - Send image to CNN model
   - Display top 5 similar kanji

**Endpoints Needed**:
```
GET /api/kanji/search?q=<query>&by=<character|reading|meaning|radical>
POST /api/model/predict - Already exists (8000 port)
```

**CNN Model Status**:
- ✅ Model service running (port 8000)
- ❌ Returns 500 error (need to check backend logs)
- Model file: `src/models/model/kanji_3036_best_e4.h5`

### Priority 3 - Enhanced Features

#### 3.1 Stroke Order Animation
**Requirements**:
- Integrate KanjiVG API or Jisho.org
- Fetch SVG/JSON stroke data
- Animate strokes sequentially
- Add replay button

**Libraries**:
```yaml
dependencies:
  flutter_svg: ^2.0.0
  # or
  rive: ^0.12.0
```

**API Options**:
- KanjiVG: Free SVG data
- Jisho.org: Stroke order diagrams
- Store locally in assets if possible

#### 3.2 Example Sentences + Audio
**Requirements**:
- Integrate Kanji Alive RapidAPI
- API Key: `ab84e2d5d7mshec320cda6671a01p122264jsnfa7b71b22317`
- Fetch examples, readings, audio URLs
- Play audio with `audioplayers` package

**API Endpoint**:
```
GET https://kanjialive-api.p.rapidapi.com/api/public/kanji/all
Headers:
  x-rapidapi-host: kanjialive-api.p.rapidapi.com
  x-rapidapi-key: ab84e2d5d7mshec320cda6671a01p122264jsnfa7b71b22317
```

**Display Format**:
| Word | Reading | Meaning | 🔊 |
|------|---------|---------|-----|
| 戦争 | せんそう | war | Play |

#### 3.3 Speech-to-Text
**Status**: ⚠️ Shows "speech recognition not available"

**Fix Required**:
1. Initialize `SpeechToText` properly
2. Add BLoC states:
   - `SpeechListening`
   - `SpeechResult(String text)`
   - `SpeechError(String message)`
3. Handle Android/iOS permissions
4. Fix widget lifecycle (mounted check)

**Current Error**:
```
State no longer has a context (Translation page STT)
File: translation_page.dart:724:26
```

**Fix**: Add `mounted` check before `context` usage:
```dart
if (!mounted) return;
_showSnackBar(message);
```

#### 3.4 Profile Management
**Status**: 🔄 Shows "Coming Soon"

**Endpoints Needed**:
```
PUT /api/user/profile
  Body: { name: string, avatarFile?: File }

POST /api/user/avatar
  Body: FormData (multipart)
```

**Flow**:
1. User taps edit button
2. Open dialog with name field + avatar picker
3. On save: call API
4. Update cached user in AuthBloc
5. Show success snackbar

#### 3.5 Real Statistics (Not Fake Data)
**Status**: ❌ Dashboard shows fake/hardcoded data

**Backend Endpoints Needed**:
```
GET /api/stats/dashboard
Response: {
  totalKanjiLearned: number,
  flashcardsReviewed: number,
  quizAccuracy: number,
  streakDays: number,
  thisWeekProgress: { day: string, count: number }[],
  recentActivity: Activity[]
}

GET /api/stats/history
Response: StudyHistory[]
```

**Frontend Updates**:
- Connect Dashboard to real API
- Connect Profile stats to real API
- Add loading states
- Add animated counters with `TweenAnimationBuilder`
- Cache data locally (Hive)

### Priority 4 - Testing & Quality

#### 4.1 Integration Tests
**Files Created**:
- ✅ `integration_test/auth_navigation_test.dart`
- ✅ `integration_test/home_navigation_test.dart`

**To Do**:
- Run tests: `flutter test integration_test/`
- Add more scenarios:
  - Quiz flow (start → answer → complete)
  - Flashcard flow (select deck → review cards)
  - Search flow (canvas draw → result)

#### 4.2 Widget Tests
**Status**: ⚠️ Need more coverage

**To Add**:
- Quiz pages widget tests
- Flashcard pages widget tests
- Translation page widget tests
- Profile page widget tests

#### 4.3 E2E Tests
**Requirements**:
- Full user journeys
- Backend must be running
- Test data seeded

**Scenarios**:
1. New user → Register → Login → Browse Kanji → Search → View Detail
2. User → Login → Practice Flashcards → Complete review session
3. User → Login → Take Quiz → Submit → View Results
4. User → Login → Draw Kanji → Get Recognition → View Details

### Priority 5 - Performance & UX

#### 5.1 Error Handling
**Current Issues**:
- CNN model returns 500 - needs investigation
- Hive errors in logs (now fixed)
- Notification permission errors

**To Do**:
- Add global error boundary
- Add retry logic for failed requests
- Show user-friendly error messages
- Log errors to analytics (optional)

#### 5.2 Loading States
**To Do**:
- Add skeleton loaders for kanji grid
- Add shimmer effect for loading cards
- Add progress indicators for long operations
- Disable buttons during loading

#### 5.3 Offline Support
**To Do**:
- Cache kanji list locally
- Cache user profile
- Show cached data when offline
- Sync when back online
- Show offline indicator in AppBar

### Priority 6 - Documentation

#### 6.1 API Documentation
**To Do**:
- Document all backend endpoints
- Add request/response examples
- Add authentication requirements
- Add error codes reference

#### 6.2 Architecture Documentation
**To Do**:
- Update README with current architecture
- Add folder structure diagram
- Add state management flow diagram
- Add testing strategy document

---

## 🚀 Immediate Next Steps (in order)

1. **Fix CNN Model 500 Error**
   - Check `cnn-kanji` backend logs
   - Verify model file path
   - Test predict endpoint with Postman
   - Fix image preprocessing if needed

2. **Implement Flashcard Backend**
   - Create Prisma schema for Deck/Card/Progress
   - Generate migrations
   - Create NestJS module
   - Implement SM-2 algorithm
   - Test with frontend

3. **Fix Translation Page STT**
   - Add `mounted` check in `_initializeStt`
   - Handle dispose properly
   - Test speech recognition

4. **Implement Profile Update**
   - Add backend endpoint
   - Add frontend form
   - Test avatar upload

5. **Connect Real Statistics**
   - Implement stats endpoint
   - Update Dashboard
   - Update Profile
   - Add caching

6. **Run Integration Tests**
   - Fix any failing tests
   - Add coverage for new features
   - Document test scenarios

---

## 📊 Progress Tracking

- **Phase 1 (Critical Fixes)**: 100% ✅
- **Phase 2 (Backend Features)**: 30% 🔄
  - Flashcard: 0% ❌
  - Search: 60% ⚠️
  - Profile: 0% ❌
  - Stats: 0% ❌
- **Phase 3 (Enhanced Features)**: 10% 🔄
  - Stroke Order: 0% ❌
  - Examples/Audio: 0% ❌
  - Speech-to-Text: 20% ⚠️
- **Phase 4 (Testing)**: 40% 🔄
  - Unit Tests: 181 tests ✅
  - Integration Tests: Created, not run 🔄
  - Widget Tests: Partial ⚠️
  - E2E Tests: Not started ❌
- **Phase 5 (Performance/UX)**: 20% 🔄
- **Phase 6 (Documentation)**: 30% 🔄

**Overall Progress**: 35% Complete

---

**Last Updated**: 2025-10-22
**Next Review**: After completing Flashcard backend
