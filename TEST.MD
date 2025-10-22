# 🧪 Kanji Master — Full Coverage Test TODO Generation Prompt (v2)

## 🎯 Task
Generate a **complete and exhaustive TODO list** for **testing the entire system** — from **backend API**, **domain logic**, **BLoC flow**, **navigation between pages**, to **UI rendering and user interaction**.

I want **Copilot to test every possible case** (success, failure, timeout, empty data, token expired, network lost, unauthorized, validation errors, etc.) — until the app behaves correctly under all conditions.

---

## 🧠 Project Context

### 🧩 Architecture
- Flutter app using **Clean Architecture + BLoC**
- Layers:
  - API → Repository → UseCase → Bloc → UI  
- Dependency injection: `getIt`
- HTTP client: `dio`
- Routing: `AppRouter.createRouter(isAuthenticated: bool)`
- Backend: **NestJS + Prisma + PostgreSQL**
- State management: `flutter_bloc`
- Theme: Dark mode only (black background, white text)

---

## 🧰 Tech Stack
- Flutter SDK (latest stable)
- Packages:
  - `flutter_bloc`
  - `bloc_test`
  - `mocktail`
  - `integration_test`
  - `flutter_test`
  - `dio_mock_adapter`
  - `flutter_dotenv`
- Backend API base: `.env` → `API_BASE_URL=http://10.0.2.2:3000/api`

---

## ✅ Test Plan Goals
Copilot must generate a detailed **TODO_TEST.md** containing:

### 1️⃣ Test Layers to Cover
- **Unit Tests:**  
  Test all domain logic (UseCases, Repositories, Validators)
- **Integration Tests:**  
  Test data flow API → Repository → Bloc → UI
- **BLoC Tests:**  
  Test event → state flow for all success & failure scenarios
- **Widget Tests:**  
  Test rendering, color, animations, error UI
- **Navigation Tests:**  
  Verify all route transitions and restricted page access
- **End-to-End Tests:**  
  Simulate real user flow from login to logout

---

## ⚙️ Test Setup Instructions
Copilot should include:
- How to configure `flutter_test`, `bloc_test`, and `integration_test`
- How to mock backend API using `dio_mock_adapter`
- How to simulate:
  - ✅ Success response (200, 201)
  - ❌ Invalid credentials (401)
  - ⛔ Forbidden / expired token (403)
  - 🕒 Timeout
  - 🌐 No internet connection
  - 🧩 Empty API response
  - 🧨 Server error (500)
  - ⚠️ Unexpected data type
  - 🔁 Retry logic validation

---

## 🧩 Features to Test & Scenarios

### 🔐 Auth Feature
| Scenario | Expected Result |
|-----------|----------------|
| ✅ Login success | Emits `Authenticated` → navigates to Home |
| ❌ Wrong password | Emits `AuthError` → shows error snackbar |
| ❌ Empty fields | Prevent API call, show validation message |
| ❌ Server down | Emits `AuthError`, show “try again” message |
| ❌ Token expired | Auto logout, redirect to Login |
| 🔁 Logout success | Clears token, emits `Unauthenticated` |
| 🔁 Remember login | Rehydrates cached user and token on restart |

### 🈶 Kanji Feature
| Scenario | Expected Result |
|-----------|----------------|
| ✅ Fetch Kanji success | Show Kanji list grid |
| ❌ API 404 | Show “No Kanji Found” |
| ❌ Timeout | Show retry button |
| ❌ Parsing error | Log gracefully, show error state |
| 🧩 Stroke animation load fail | Show placeholder instead |
| 🌐 Offline mode | Load Kanji from local cache |
| ✅ Favorite toggle | Updates immediately, persists offline |

### 🧠 Flashcard Feature
| Scenario | Expected Result |
|-----------|----------------|
| ✅ Load flashcards | Show card swiper |
| ❌ Empty list | Show “No flashcards yet” |
| ✅ Flip animation | Works smoothly |
| ❌ Animation fails | UI fallback with message |
| ✅ Study session done | Save progress |
| ❌ Storage full | Handle gracefully without crash |

### 🧩 Quiz Feature
| Scenario | Expected Result |
|-----------|----------------|
| ✅ Quiz start | Moves to first question |
| ✅ Answer correct | Increases score |
| ❌ Answer wrong | Shows feedback |
| 🧩 Timeout | Auto submit answer |
| ❌ Network lost mid-quiz | Pause with reconnect button |
| ✅ Submit results | Saves to backend |
| ❌ Submit fail | Retries until success |

### 👤 Profile Feature
| Scenario | Expected Result |
|-----------|----------------|
| ✅ Load profile | Show user info |
| ❌ Token expired | Auto logout |
| ✅ Update name/avatar | Shows success message |
| ❌ Upload failed | Error snackbar |
| 🧩 Offline mode | Load cached data |
| ❌ Corrupted cache | Clears and refetches |

### 🧭 Navigation Flow
- [ ] Test Login → Home → Kanji Detail → Flashcard → Quiz → Profile → Logout  
- [ ] Test deep link routes and app restart persistence  
- [ ] Prevent unauthorized access to protected pages  
- [ ] Verify bottom navigation and back stack restoration  

### 🎨 UI & Theme
- [ ] Test black background and white text  
- [ ] Verify “Noto Sans JP” renders correctly  
- [ ] Check layout on tablet / landscape  
- [ ] Test button tap animations  
- [ ] Accessibility labels and readable contrast  

---

## 🧪 Coverage Requirements
- **Minimum 95% logic coverage**
- **All UI states tested**
- **Every Bloc event/state transition validated**
- **All navigation paths confirmed**
- **All API endpoints mocked and tested**

---

## 📂 Deliverable Example

🧪 Kanji Master Full System Test Plan
1️⃣ Unit Tests
 Test LoginUseCase with success/failure/invalid params

 Test GetProfileUseCase with expired token

 Test Spaced Repetition Algorithm (SM2)

2️⃣ Integration Tests
 Test Dio API client error handling

 Test Repository ↔ Bloc flow for Auth & Kanji

3️⃣ Bloc Tests
 AuthBloc emits Authenticated after login success

 AuthBloc emits AuthError on 401 response

 KanjiBloc handles empty response gracefully

4️⃣ Widget Tests
 Flashcard flip works

 Kanji detail renders all fields

 Quiz page transitions properly

5️⃣ Navigation Tests
 Authenticated user can go Home → Profile → Logout

 Unauthenticated user redirected to Login

6️⃣ E2E Tests
 Full login → study → quiz → logout flow

 Test with network off / back online

 Handle token refresh and relogin

✅ Target coverage: 95%

yaml
Copy code

---

## 🚀 Expected Copilot Output
Copilot must:
1. Generate a **file named `TODO_TEST_FULL.md`** with every scenario above.  
2. Include **mock setup**, **expected results**, and **test file naming convention**.  
3. Ensure **each feature has complete test coverage**, including all possible failures.  
4. Follow **Clean Architecture** and **BLoC best practices** for test isolation.  
5. Suggest **structured test hierarchy** under `/test/features/...` folders.  
