# 🧩 Kanji Master — Feature Verification & Completion Prompt

You are my **Flutter + NestJS assistant**.

Your task:  
**Carefully inspect the entire project (both Flutter frontend and NestJS backend)**  
and verify whether the following **features are fully implemented**.

If a feature or sub-feature is missing, incomplete, or stubbed (e.g., “coming soon”),  
report it clearly and explain **what files or logic are missing**.

Then, generate a **TODO list** to complete missing parts and  
**propose new modules, features, or APIs** needed on both backend and frontend.

---
## 🎨 1️⃣ KanjiVG Service (Stroke Order Animation)
### Purpose:
Render stroke order animations directly from the **KanjiVG dataset** or public API.

### Check for:
- [ ] A service file such as `kanjivg_service.dart` or equivalent
- [ ] Logic fetching KanjiVG SVGs from:  
  `https://raw.githubusercontent.com/KanjiVG/kanjivg/master/kanji/<KANJI>.svg`
- [ ] Proper SVG rendering via:
  - `flutter_svg`
  - or custom Canvas animation widget
- [ ] Integration in `KanjiDetailPage` showing animated strokes

## 🎨 1️⃣ KanjiVG Service (Stroke Order Animation)
### Purpose:
Render stroke order animations directly from the **KanjiVG dataset** or public API.

### Check for:
- [ ] A service file such as `kanjivg_service.dart` or equivalent
- [ ] Logic fetching KanjiVG SVGs from:  
  `https://raw.githubusercontent.com/KanjiVG/kanjivg/master/kanji/<KANJI>.svg`
- [ ] Proper SVG rendering via:
  - `flutter_svg`
  - or custom Canvas animation widget
- [ ] Integration in `KanjiDetailPage` showing animated strokes

✅ **Expected Implementation**
```dart
class KanjiVGService {
  Future<String> fetchStrokeSvg(String kanji) async {
    final code = kanji.codeUnitAt(0).toRadixString(16);
    final url = 'https://raw.githubusercontent.com/KanjiVG/kanjivg/master/kanji/$code.svg';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) return res.body;
    throw Exception('KanjiVG not found');
  }
}
⚠️ If missing:
→ Create /lib/core/services/kanjivg_service.dart
→ Update KanjiDetailPage to load and display the SVG animation.

🔊 2️⃣ RapidAPI (Kanji Alive)
Purpose:
Fetch example words, meanings, and audio pronunciation from Kanji Alive API.

Check for:
 Service file like rapidapi_service.dart

 Request to RapidAPI endpoint:
https://kanjialive-api.p.rapidapi.com/api/public/kanji/<KANJI>

 Proper RapidAPI headers:

x-rapidapi-key

x-rapidapi-host

 Audio playback using:

audioplayers

or just_audio

 Integration in KanjiDetailPage for example list + play audio button

✅ Expected Implementation



<!-- class RapidApiService {
  final String baseUrl = 'https://kanjialive-api.p.rapidapi.com/api/public/kanji/all';
  final String apiKey = 'ab84e2d5d7mshec320cda6671a01p122264jsnfa7b71b22317';

  Future<Map<String, dynamic>> getKanjiData(String kanji) async {
    final res = await http.get(
      Uri.parse('$baseUrl/$kanji'),
      headers: {
        'x-rapidapi-key': apiKey,
        'x-rapidapi-host': 'kanjialive-api.p.rapidapi.com',
      },
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Kanji Alive API failed');
  }
} -->

⚠️ If missing:
→ Add rapidapi_service.dart under /lib/core/services/
→ Inject into KanjiRepository to provide example + audio data to BLoC.

## 🔍 1️⃣ Kanji List
Check:
- [ ] Can display all **Kanji lists** (public and user-created)
- [ ] Can **CRUD (Create, Read, Update, Delete)** Kanji lists
- [ ] Can **add or remove Kanji items** inside a list
- [ ] Has **pre-generated lists** by **JLPT level** (N5 → N1)
- [ ] Has proper backend routes like `/api/kanji-list`, `/api/kanji-list/:id`, `/api/kanji-list/jlpt/:level`

✅ **Expected Files**
- Backend: `kanji-list.controller.ts`, `kanji-list.service.ts`, Prisma model for `KanjiList`
- Frontend: `features/kanji_list/` folder with `bloc`, `repository`, and UI pages

---

## 🃏 2️⃣ Kanji Flashcard
Check:
- [ ] Can **view all flashcard decks**
- [ ] Can **view deck details**
- [ ] Can **view each card in a deck**
- [ ] Supports **CRUD for deck**
- [ ] Supports **CRUD for cards** within a deck
- [ ] Backend routes exist for:
  - `/api/flashcard/decks`
  - `/api/flashcard/decks/:id`
  - `/api/flashcard/decks/:id/cards`

✅ **Expected Files**
- Backend: `flashcard.controller.ts`, `flashcard.service.ts`, Prisma models `Deck`, `Card`
- Frontend: `features/flashcard/` folder with `bloc`, `data_source`, and UI screens

---

## 🔍 3️⃣ Kanji Search
Check:
- [ ] Can **search Kanji by character, meaning, reading, radicals**
- [ ] Has **Canvas Search** (draw input) feature
- [ ] Canvas sends image to **CNN model API**
- [ ] Displays **top 5 similar Kanji** returned from backend
- [ ] Has backend endpoint like `/api/kanji/search` and `/api/model/predict`

✅ **Expected Files**
- Backend: `kanji.controller.ts` with `@Get('search')`
- Frontend: `features/kanji_search/` with search UI and `CanvasPainter` widget

---

## 🧠 4️⃣ Kanji Quiz
Check:
- [ ] Can **view quiz list**
- [ ] Can **view quiz details**
- [ ] Can **view list of questions**
- [ ] Supports **CRUD for quiz**
- [ ] Supports **CRUD for questions** within a quiz
- [ ] Has backend endpoints like:
  - `/api/quiz`
  - `/api/quiz/:id`
  - `/api/quiz/:id/questions`

✅ **Expected Files**
- Backend: `quiz.controller.ts`, `quiz.service.ts`, Prisma models `Quiz`, `Question`
- Frontend: `features/quiz/` with BLoC and repository pattern implemented

---

## 🗣️ 5️⃣ Translate (Speech to Text)
Check:
- [ ] Has functional **speech-to-text** conversion
- [ ] Uses working `speech_to_text` logic (not just snackbar fallback)
- [ ] Properly initializes speech recognition and microphone permissions
- [ ] Translation result shown in UI (and possibly translated text using `google_mlkit_translation`)

✅ **Expected Files**
- Frontend: `features/translate/` with `speech_bloc.dart` or equivalent
- No Firebase or Google API dependency that breaks offline mode

---

## 👤 6️⃣ Profile
Check:
- [ ] Can **view user profile**
- [ ] Can **update profile information** (name, avatar, etc.)
- [ ] Sends update request to backend endpoint `/api/user/profile`
- [ ] Profile page shows correct user info from cache or API

✅ **Expected Files**
- Backend: `user.controller.ts` with `@Put('profile')`
- Frontend: `features/profile/` with `ProfileBloc` and update logic

---

## ✅ 7️⃣ Output Requirements

Copilot must:
1. Analyze both Flutter and backend files in this repo.
2. For each feature, clearly state:
   - ✅ Fully implemented  
   - ⚠️ Partially implemented (specify missing logic/UI/API)  
   - ❌ Missing (no code found)
3. Suggest **file paths** or **module names** for where missing code should go.
4. Generate a markdown summary table like this:

| Feature | Status | Missing / Issue | Suggested Fix |
|----------|---------|-----------------|----------------|
| Kanji List | ⚠️ Partial | Cannot add Kanji to list | Add endpoint `/api/kanji-list/:id/kanji` |
| Flashcard | ❌ Missing | No card CRUD | Implement deck/card model in backend |

---

## 🧱 8️⃣ TODO List Generation

After analysis, generate a **structured TODO.md** file that includes:
- ✅ Features already completed (no action needed)
- 🛠️ Features partially implemented (list missing logic/UI/API)
- 🚧 Features missing entirely (list what to create)

Each TODO must include:
- File path to be created or updated
- Short task description (1 line)
- Related backend or frontend module
- Dependency notes (e.g., BLoC, repository, API endpoint, Prisma model)
- Testing requirements (unit + integration + E2E)

Example:
```md
### TODO — Flashcard Feature
- [ ] Backend: Create `flashcard.controller.ts` and define `/api/flashcard/decks` routes
- [ ] Backend: Add Prisma models `Deck` and `Card`
- [ ] Frontend: Implement `FlashcardBloc` and repository
- [ ] Frontend: Add deck list + deck detail UI
- [ ] Test: Add E2E test for creating a new deck
