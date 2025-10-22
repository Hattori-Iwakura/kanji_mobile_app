# 🧠 Copilot Instructions — Kanji Master Flutter App

You are building a **Flutter mobile app** called **Kanji Master**, integrated with the backend **kanji-web-be (NestJS + Prisma + PostgreSQL)**.

Follow these rules and tasks exactly.

---

## 🧩 1️⃣ Overall Architecture
Use **Clean Architecture + BLoC pattern** for state management.  
No **Fire Base**.

Project folder structure:
```
lib/
 ├─ core/
 │   ├─ theme/
 │   ├─ utils/
 │   ├─ network/
 │   ├─ di/
 │   └─ widgets/
 ├─ features/
 │   ├─ auth/
 │   ├─ kanji/
 │   ├─ kanji_list/
 │   ├─ kanji_search/
 │   ├─ flashcard/
 │   ├─ quiz/
 │   ├─ profile/
 │   ├─ settings/
 │   ├─ user/
 │   ├─ dashboard/
 │   └─ notification/
 ├─ model/
 ├─ main.dart
 └─ app.dart
```

Each feature contains:
```
data/
domain/
presentation/
```
and uses **repository pattern** and **flutter_bloc** for event/state handling.

---

## 🎨 2️⃣ UI Design Rules
- Canvas background: **always black (#000000)**
- Text color: **always white (#FFFFFF)**
- Use **Material 3**, **responsive UI**
- Font: **"Noto Sans JP"** or other Japanese-compatible fonts
- Use **anime-style transitions** (fade, slide, or scale)
- UI should feel **friendly, minimal, and immersive**
- Dark mode is **default**, no light mode toggle needed

---

## 👤 3️⃣ User Roles and Access
### Admin
- Has full CRUD rights across all entities
- Can approve public content requests
- Access to `/dashboard` and `/user-management`

### User
- Can create, edit, delete **private Kanji list**, **quiz**, **flashcard**
- To publish to public system → must **send request to Admin**
- Access limited to their own data

---

## 🔐 4️⃣ Feature Breakdown

### 🧱 Auth
- Register, Login, Forgot password (send code via email)
- 2FA (Two-factor authentication)
- Login with Google & Facebook
- Role-Based Access Control (RBAC)
- Use pub.dev packages:
  - `flutter_bloc`
  - `dio` or `http`
  - `jwt_decoder`
  - `flutter_secure_storage`


### 🈶 Kanji (Dictionary)
- Fetch Kanji list from backend API `/api/kanji`
- Display Kanji grid (character + meaning)
- On tap → open **Kanji Detail Page**:
  - Show stroke order animation (from **Jisho.org API**)
  - Display examples (with **audio** from Kanji Alive Rapid API)
- Support favorite Kanji list (local or cloud)



### 📚 Kanji List
- Curated collections of Kanji grouped by:
  - JLPT level
  - School grade
  - Vocabulary set (Genki, Minna no Nihongo, etc.)
- Users can create custom lists (private/public)
- Admin can approve public submissions


### 🔍 Kanji Search
- Search by character, reading (onyomi, kunyomi), meaning, or radicals
- Search UI similar to **Jisho.org**
- Add **Canvas Input Button**:
  - Opens a black canvas for user to draw
  - Send image to **CNN-Kanji model (Fast API)** to detect
  - Return top 5 most similar Kanji → show in grid under search bar

### 🃏 Flashcard
- Use animation packages (`flutter_card_swiper`, `flip_card`, `rive`)
- Each card has:
  - Front: Kanji + onyomi/kunyomi
  - Back: Meaning + example + audio
- Users can:
  - View all cards
  - View card details
  - Start **Study Session**:
    - Use spaced repetition algorithm (SM2 or Leitner)
    - Remind users to review later

### 🧩 Japanese Translate
- Support both:
  - **Text → Speech (TTS)**  
  - **Speech → Text (STT)**
- Use:
  - `google_mlkit_translation`
  - `flutter_tts`
  - `speech_to_text`
- Allow reading out Kanji/word pronunciation

### 🧠 Kanji Quiz
- List of Kanji quizzes (Multiple-choice, fill-in-blank, draw)
- Integrate CNN model: show meaning of Kanji to user if drawn Kanji is recognized correctly → answer correct
- Use clean BLoC event/state flow
- Store quiz history and score progress in user profile

### 👤 Profile
- Show:
  - Avatar
  - Username, email
  - Learning progress (%)
  - Favorite Kanji
  - Study streaks
- Allow user to update info and password

### ⚙️ Settings
- Change font size
- Change app language (Japanese, Vietnamese, English)
- Manage notification settings
- Save locally using 'shared_preferences' 

### 🤖 Model
- Manage CNN Kanji recognition model
- Handle image upload → backend Flask model endpoint
- Display result grid after prediction

### 👥 User (Admin Panel)
- Admin feature only
- Manage users (view, update, deactivate)
- Assign roles (admin/user)
- CRUD for all Kanji, Quiz, Flashcard

### 📊 Dashboard
- For admin
- Show:
  - Number of users
  - Number of public Kanji
  - Number of quizzes
  - Recent activity logs
- Use chart package (`syncfusion_flutter_charts` or `fl_chart`)

### 🔔 Notification
- No Firebase
- Use custom backend polling or socket for updates
- Use `flutter_local_notifications` for reminders and system alerts
- Push notification for:
  - Flashcard review reminder
  - Quiz result updates
  - Admin announcements

---

## ⚙️ 5️⃣ Integration
- Read backend API from `.env`:  
  `API_BASE_URL=http://10.0.2.2:3000/api`
- Use `flutter_dotenv` to load environment variables
- Implement Repository layer using `dio` or `http`
- Connect all repositories through `get_it` dependency injection

---

## ✅ 6️⃣ To-Do List for Copilot
Generate a **step-by-step TODO list** to:
1. Initialize Flutter project with all dependencies
2. Set up folder structure (Clean Architecture + BLoC)
3. Implement Auth first (JWT + social login)
4. Add Kanji feature (API integration + details + stroke animation)
5. Add Flashcard & Quiz feature
6. Add Kanji Search with CNN model connection
7. Add Admin features (User + Dashboard)
8. Add Settings + Notification
9. Polish UI (dark theme + Japanese font)
10. Add full **integration tests** and **BLoC + UI flow tests** for all features

---

## 💡 7️⃣ Design Guidelines
- All screens have **black background** and **white text**
- Typography: `"Noto Sans JP"` from Google Fonts
- Animation: smooth, no clutter
- Respect Material motion rules
- Always prioritize UX simplicity and clarity

---

## 🧩 8️⃣ Testing
Each feature must be **fully tested end-to-end**, including:

| Test Type | Scope | Description |
|------------|--------|-------------|
| **Unit Test** | Repository, Entities | Test logic and data transformations |
| **Integration Test** | API, Repository | Ensure endpoints return and parse correctly |
| **BLoC Flow Test** | Event → State | Verify each BLoC emits correct states for given events |
| **UI Flow Test** | Widget → BLoC → API | Verify user interactions trigger correct backend calls and state transitions |
| **E2E Test** | Full App Flow | From Login → Fetch Kanji → Search → Quiz → Profile |

Use packages:
- `flutter_test`
- `mockito`
- `bloc_test`
- `integration_test`
- `http_test`

Example E2E flow:
```
1️⃣ Auth → Login → Token stored
2️⃣ Kanji → Fetch list → Open details
3️⃣ Search → Draw Kanji → Show results
4️⃣ Quiz → Complete → Save progress
5️⃣ Profile → View stats → Logout
```

---

## 🚀 9️⃣ Final Goal
Create a **Kanji Learning Flutter App** that:
- Integrates real backend data
- Has full offline/online capability
- Supports all roles (admin/user)
- Feels premium and polished
- Has **complete integration & flow testing coverage**

Copilot should now:
✅ Generate `TODO.md` with detailed development steps for all features above  
✅ Scaffold base folders  
✅ Create `main.dart`, `app.dart`, `theme.dart`  
✅ Implement **BLoC templates** for each feature  
✅ Generate **test suites for repository, bloc, and UI flows**  
✅ Ensure `.env` is used for backend config and **no Firebase dependency**
