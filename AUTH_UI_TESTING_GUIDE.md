# Auth UI Testing Guide

## Đã hoàn thành: Auth Feature UI Implementation ✅

### 📱 Pages đã tạo:

1. **LoginPage** (`lib/features/auth/presentation/pages/login_page.dart`)
   - ✅ Dark theme (black bg, white text)
   - ✅ Fade + Slide animations (800ms)
   - ✅ Form validation (account/email + password)
   - ✅ Password visibility toggle
   - ✅ BLoC integration (AuthLoading, LoginSuccess, AuthError states)
   - ✅ Navigation: Register, Forgot Password
   - ✅ Social login placeholders (Google, Facebook)

2. **RegisterPage** (`lib/features/auth/presentation/pages/register_page.dart`)
   - ✅ Account, Email, Password, Confirm Password fields
   - ✅ Password requirements display
   - ✅ Form validation với Validators
   - ✅ BLoC integration (RegisterSuccess → Home)
   - ✅ Navigation: Back to Login
   - ✅ Dark theme + animations

3. **ForgotPasswordPage** (`lib/features/auth/presentation/pages/forgot_password_page.dart`)
   - ✅ Email input form
   - ✅ Send reset link functionality
   - ✅ Success message với auto-redirect (2s)
   - ✅ Info box về spam folder
   - ✅ Navigation: Back to Login

4. **HomePage** (`lib/features/dashboard/presentation/pages/home_page.dart`)
   - ✅ Bottom Navigation Bar (5 tabs: Kanji, Search, Flashcards, Quiz, Profile)
   - ✅ Welcome card với gradient
   - ✅ Quick actions (Browse Kanji, AI Recognition)
   - ✅ Learning stats (Day Streak, Learned, Quiz Score)
   - ✅ Profile tab với logout functionality
   - ✅ AppBar với notifications và settings icons

---

## 🚀 Cách test Auth UI

### Bước 1: Khởi động Backend (NestJS)

```bash
cd d:\workspace\kanji-web-be
docker-compose up -d  # Start PostgreSQL
npm run start:dev      # Start NestJS server (http://localhost:3000)
```

**Kiểm tra backend:**
- API Docs: http://localhost:3000/api
- Health check: http://localhost:3000/api/health

### Bước 2: Chạy Flutter App

```bash
cd d:\workspace\kanji_mobile_v1
flutter run
```

**Chọn device:**
- Android Emulator (10.0.2.2:3000 cho localhost)
- iOS Simulator (localhost:3000)
- Chrome (localhost:3000)

### Bước 3: Test Cases

#### Test Case 1: Login Flow ✅

**Precondition:** Backend đang chạy, có tài khoản đã đăng ký

**Steps:**
1. Mở app → LoginPage tự động hiện
2. Nhập account/email: `testuser` (hoặc email đã đăng ký)
3. Nhập password: `Test@123456`
4. Nhấn "Login"

**Expected Results:**
- ✅ Loading widget hiện với message "Logging in..."
- ✅ API call tới `POST /api/auth/login`
- ✅ Response thành công → Navigate tới HomePage
- ✅ Token lưu vào FlutterSecureStorage
- ✅ Bottom navigation hiện với 5 tabs

**Error Cases:**
- Sai account/password → SnackBar màu đỏ với error message
- Không điền form → Validation errors hiện
- Backend offline → "Network error" message

---

#### Test Case 2: Register Flow ✅

**Precondition:** Backend đang chạy

**Steps:**
1. Ở LoginPage → Nhấn "Register" link
2. RegisterPage hiện với fade animation
3. Nhập username: `newuser123`
4. Nhập email: `newuser@test.com`
5. Nhập password: `NewPass@2025` (phải match requirements)
6. Nhập confirm password: `NewPass@2025`
7. Nhấn "Create Account"

**Expected Results:**
- ✅ Password requirements box hiện checkmarks
- ✅ Loading widget: "Creating account..."
- ✅ API call: `POST /api/auth/register`
- ✅ Success → Navigate tới HomePage
- ✅ Auto-login sau register

**Error Cases:**
- Username đã tồn tại → "Account already exists"
- Email invalid → Validation error "Please enter a valid email"
- Password không match requirements → Validation error
- Confirm password khác → "Passwords do not match"

---

#### Test Case 3: Forgot Password Flow ✅

**Precondition:** Backend đang chạy, email đã đăng ký

**Steps:**
1. LoginPage → Nhấn "Forgot Password?" link
2. ForgotPasswordPage hiện với lock reset icon
3. Nhập email: `testuser@example.com`
4. Nhấn "Send Reset Link"

**Expected Results:**
- ✅ Loading: "Sending reset link..."
- ✅ API call: `POST /api/auth/forgot-password`
- ✅ Success → Green SnackBar: "Password reset link sent!"
- ✅ Info box về spam folder
- ✅ Auto-redirect về LoginPage sau 2 giây

**Error Cases:**
- Email không tồn tại → "User not found"
- Email invalid → Validation error

---

#### Test Case 4: Home Page Navigation ✅

**Precondition:** Đã đăng nhập thành công

**Steps:**
1. HomePage hiện với Kanji tab active
2. Nhấn từng tab trong bottom navigation

**Expected Results:**

**Kanji Tab:**
- ✅ Welcome card với gradient (Primary → Secondary)
- ✅ "Welcome to Kanji Master! 🎌"
- ✅ Quick Actions: "Browse Kanji", "AI Recognition" (coming soon snackbar)
- ✅ Stats card: Day Streak, Learned, Quiz Score (all 0)

**Search Tab:**
- ✅ Placeholder: Search icon + "Search Feature Coming Soon"

**Flashcards Tab:**
- ✅ Placeholder: Style icon + "Flashcards Feature Coming Soon"

**Quiz Tab:**
- ✅ Placeholder: Quiz icon + "Quiz Feature Coming Soon"

**Profile Tab:**
- ✅ Avatar placeholder (person icon)
- ✅ "User Name" + "user@email.com" (placeholder)
- ✅ Menu items: Edit Profile, Learning History, Achievements, Settings, Help & Support
- ✅ Logout button (red color)

---

#### Test Case 5: Logout Flow ✅

**Precondition:** Đã đăng nhập, đang ở HomePage

**Steps:**
1. Nhấn Profile tab (bottom nav)
2. Scroll xuống → Nhấn "Logout" (red button)
3. AlertDialog hiện: "Are you sure you want to logout?"
4. Nhấn "Logout" (red text)

**Expected Results:**
- ✅ AuthBloc.add(LogoutEvent()) được gọi
- ✅ API call: `POST /api/auth/logout` (clear session)
- ✅ FlutterSecureStorage.clearAuthData()
- ✅ Navigate về LoginPage
- ✅ Nếu quay lại app → LoginPage vẫn hiện (không auto-login)

---

#### Test Case 6: Auth Redirect Logic ✅

**Test 6.1: Unauthenticated → Protected Route**
- Mở app lần đầu (chưa login)
- Expected: Tự động redirect về LoginPage
- Không thể access HomePage bằng deep link

**Test 6.2: Authenticated → Login Route**
- Đã login, thử navigate về `/login`
- Expected: Redirect về HomePage (không cho vào login)

**Test 6.3: Token Refresh**
- Access token hết hạn (401 error)
- Expected: DioClient tự động refresh token
- Nếu refresh success → Retry request
- Nếu refresh fail → Logout + redirect về LoginPage

---

## 🐛 Known Issues & Warnings

### 1. Deprecation Warnings (Flutter 3.9.2)
```
'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss
```
**Impact:** None (chỉ là warning, app vẫn chạy bình thường)
**Fix:** Có thể upgrade Flutter version hoặc replace `withOpacity` → `withValues()` sau

### 2. BuildContext Async Gap
```
Don't use 'BuildContext's across async gaps - forgot_password_page.dart:92:19
```
**Location:** ForgotPasswordPage - auto-redirect sau 2s
**Impact:** Minor (có thể gây crash nếu user back ngay lập tức)
**Fix đã áp dụng:** Check `if (mounted)` trước khi `context.pop()`

### 3. Super Parameters
```
Parameter 'message' could be a super parameter - failures.dart
```
**Impact:** None (style suggestion)
**Fix:** Thay `this.message` → `super.message` trong constructors

---

## 📊 Test Backend API Responses

### Login Success Response
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "account": "testuser",
      "email": "test@example.com",
      "profileImage": null,
      "isFirstLogin": false,
      "createdAt": "2025-01-01T00:00:00.000Z",
      "role": "USER"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    },
    "sessionId": "uuid-session-id"
  },
  "message": "Login successful"
}
```

### Register Success Response
```json
{
  "success": true,
  "data": {
    "user": { ... },
    "tokens": { ... },
    "sessionId": "..."
  },
  "message": "User registered successfully"
}
```

### Error Response (401 Unauthorized)
```json
{
  "success": false,
  "statusCode": 401,
  "message": "Invalid credentials",
  "error": "Unauthorized"
}
```

---

## 🔥 Next Steps (Pending Implementation)

### Phase 2: Kanji Dictionary Feature
1. Domain Layer:
   - `Kanji` entity (id, character, meaning, onReading, kunReading, level, examples)
   - `KanjiRepository` interface
   - Use cases: GetKanjiList, GetKanjiDetail, SearchKanji

2. Data Layer:
   - API integration với `GET /api/kanji`
   - Pagination support
   - Search với query params

3. Presentation Layer:
   - KanjiListPage (grid/list view với pagination)
   - KanjiDetailPage (stroke animation, readings, examples)
   - KanjiSearchPage (search bar với filters)

### Phase 3: Flashcard Feature
1. Flashcard system với spaced repetition
2. Flip card animation (front: kanji, back: meaning)
3. Practice modes: Learn, Review, All

### Phase 4: Quiz Feature
1. Multiple choice quiz
2. Writing quiz (canvas drawing + AI recognition)
3. Quiz result tracking

---

## ✅ Checklist Auth UI Implementation

- [x] LoginPage UI
- [x] RegisterPage UI  
- [x] ForgotPasswordPage UI
- [x] HomePage với Bottom Navigation
- [x] Auth BLoC integration
- [x] Form validation
- [x] Navigation với GoRouter
- [x] Dark theme consistency
- [x] Loading states
- [x] Error handling
- [x] Animations (fade + slide)
- [ ] Backend testing (cần start kanji-web-be)
- [ ] E2E test cases
- [ ] Widget tests
- [ ] BLoC tests

---

## 🎯 Testing Priority

**High Priority (P0):**
1. Login flow với valid credentials
2. Register flow với unique account
3. Logout flow

**Medium Priority (P1):**
4. Form validation (empty, invalid email, weak password)
5. Auth redirect logic
6. Token refresh mechanism

**Low Priority (P2):**
7. Forgot password flow
8. Social login placeholders
9. UI animations

---

## 📝 Notes

- **Backend URL:** Hiện tại hardcode `http://10.0.2.2:3000` cho Android Emulator trong `.env`
- **No Firebase:** Không sử dụng Firebase Auth, full custom backend với NestJS + Prisma
- **Token Storage:** FlutterSecureStorage cho access/refresh tokens (encrypted)
- **Password Requirements:** Min 8 chars, 1 uppercase, 1 lowercase, 1 number
- **Dark Theme:** Tuân thủ black (#000000) background, white (#FFFFFF) text, Noto Sans JP font
- **Clean Architecture:** Domain ← Data ← Presentation layers đã setup đầy đủ

---

## 🚦 How to proceed:

1. **Start backend first:**
   ```bash
   cd kanji-web-be
   docker-compose up -d
   npm run start:dev
   ```

2. **Run Flutter app:**
   ```bash
   cd kanji_mobile_v1
   flutter run
   ```

3. **Test từng flow theo test cases ở trên**

4. **Nếu có lỗi backend (404, 500):**
   - Check backend logs: `npm run start:dev` console
   - Verify API endpoints trong Swagger: http://localhost:3000/api
   - Check database connection (PostgreSQL running?)

5. **Nếu có lỗi Flutter:**
   - `flutter analyze` → Fix errors
   - `flutter clean && flutter pub get` → Rebuild
   - Check DioClient logs trong debug console

---

**Status:** ✅ Auth UI Implementation COMPLETE - Ready for Backend Testing
