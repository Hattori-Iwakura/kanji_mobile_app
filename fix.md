# 🧠 Kanji Master App — Phase 2 Fix & Completion

## 🎯 Goal
Fix all current issues and **implement missing features** in the **Kanji Master Flutter App**, ensuring that:
- Logic, API integration, and BLoC flows are complete  
- UI navigation works across all pages  
- All functionalities behave correctly  
- App passes **end-to-end (E2E)** integration tests from **backend → bloc → UI**

---

## ⚙️ Tech Context
- Flutter + Clean Architecture + BLoC
- Backend: **NestJS (`kanji-web-be`)** with Prisma + PostgreSQL
- `.env` base URL:  
API_BASE_URL=http://10.0.2.2:3000/api

yaml
Copy code
- Networking via **Dio**
- State management: **flutter_bloc**
- Dependency injection: **get_it**
- Dark mode only — black background, white text
- No Firebase

---

## 🧩 Known Issues & Missing Features

### 1️⃣ UI Overflow
**Error:**
A RenderFlex overflowed by 12 pixels on the bottom.

markdown
Copy code

**Fix:**
- Wrap scrollable content in `SingleChildScrollView`
- Properly use `Expanded` / `Flexible` widgets inside `Column`
- Test across multiple screen sizes and orientations

---

### 2️⃣ Missing Kanji Search Functionality
**Problem:**
- Search feature not yet implemented

**Fix:**
- Add **search UI** similar to Jisho.org:
  - Search by Kanji, reading (on’yomi/kun’yomi), meaning, or radical
  - Integrate with `/api/kanji/search`
- Add **Canvas Draw Input** button:
  - Opens black canvas for user to draw a Kanji
  - Sends image to CNN recognition model (`/api/model/predict`)
  - Returns **top 5 most similar Kanji**
  - Display results below search bar as a grid

---

### 3️⃣ Stroke Order Animation (Missing)
**Problem:**
- Kanji detail page does not show stroke order animation

**Fix:**
- Integrate **Jisho.org** or **KanjiVG API**
- Fetch stroke order SVG/JSON
- Animate strokes using:
  - `flutter_svg`
  - or `Rive` animation for smooth stroke drawing
- Add replay button to repeat stroke order animation

---

### 4️⃣ Missing Example Sentences + Audio
**Problem:**
- Kanji details do not include examples or pronunciation

**Fix:**
- Integrate **Kanji Alive RapidAPI** "curl --request GET 
	--url https://kanjialive-api.p.rapidapi.com/api/public/kanji/all 
	--header 'x-rapidapi-host: kanjialive-api.p.rapidapi.com' 
	--header 'x-rapidapi-key: ab84e2d5d7mshec320cda6671a01p122264jsnfa7b71b22317'"
- Fetch:
  - Example word
  - Example sentence
  - Audio pronunciation URL
- Play audio using `audioplayers` package
- Display example list with:
Word | Reading | Meaning | 🔊 Play Button

yaml
Copy code

---

### 5️⃣ Speech-to-Text Not Working
**Problem:**
- Snackbar “speech recognition not available”

**Fix:**
- Implement `speech_to_text` logic:
- Initialize `SpeechToText`
- Add bloc states:
  - `SpeechListening`
  - `SpeechResult(String text)`
  - `SpeechError(String message)`
- On mic press → start listening  
- On result → call translation API  
- Handle permissions with `permission_handler`

---

### 6️⃣ Flashcard 404 Error
**Error:**
Cannot GET /api/flashcard/decks

markdown
Copy code

**Fix:**
- Confirm correct route (`/api/flashcards/decks` or `/api/flashcard`)
- Adjust client endpoint accordingly
- Add 404-safe handling:
  ```dart
  if (response.statusCode == 404) emit(FlashcardEmptyState());
Ensure Flashcard model matches backend schema

Add placeholder empty state UI when no decks found

7️⃣ Profile Update “Coming Soon”
Fix:

Implement PUT /api/user/profile endpoint

Support:

Update name

Update avatar (multipart upload)

On success:

Update cached user in AuthBloc

Show snackbar “Profile updated successfully”

8️⃣ Missing Study History
Fix:

Create StudyHistory model:

dart
Copy code
class StudyHistory {
  final String date;
  final int cardsReviewed;
  final int quizzesCompleted;
  final Duration totalTime;
}
Backend endpoint: /api/study/history

Display as chart or list in Profile page

Cache locally using hive or shared_preferences

9️⃣ Fake Learning Statistics
Fix:

Connect Dashboard and Profile to /api/stats
Example response:

json
Copy code
{
  "totalKanjiLearned": 250,
  "flashcardsReviewed": 540,
  "quizAccuracy": 86,
  "streakDays": 5
}
Update UI to show live data

Add animation for counters with TweenAnimationBuilder

🔟 Test Coverage and E2E Validation
Goal:
Ensure every logic flow is tested end-to-end.

Test Scopes:

Logic Layer (Unit Test)

Repository and UseCases return correct data or errors

Bloc Layer (Integration Test)

Test transitions: Loading → Success → Error

Mock API responses

Navigation Flow Test (E2E)

Login → Kanji List → Kanji Detail → Quiz → Profile → Settings

Validate routing and auth persistence

UI Test

All widgets render correctly in dark mode

Overflow & layout issues fixed

Snackbar, dialogs, buttons, and inputs respond properly

✅ Expected Output from Copilot
Copilot must:

Generate a new file:
TODO_FIX_PHASE2.md listing all tasks above step-by-step.

Implement missing logic and fix all bugs.

Write bloc tests, UI tests, and E2E tests for:

Auth

Kanji Search

Flashcard

Quiz

Profile

Stroke Animation & Audio

Ensure no UI overflow errors remain.

Validate navigation and auth redirection logic works correctly.

Refactor code to maintain Clean Architecture.

