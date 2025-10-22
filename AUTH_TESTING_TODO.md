# 🧪 Auth Feature Testing TODO

## Status: Ready for Testing ✅

**Backend Required:** kanji-web-be (NestJS + PostgreSQL)  
**Frontend:** Auth UI fully implemented  
**Test Guide:** See `AUTH_UI_TESTING_GUIDE.md`

---

## Pre-Test Setup Checklist

### Backend Setup
- [ ] Navigate to `d:\workspace\kanji-web-be`
- [ ] Start PostgreSQL: `docker-compose up -d`
- [ ] Start NestJS: `npm run start:dev`
- [ ] Verify server running: http://localhost:3000
- [ ] Check API docs: http://localhost:3000/api
- [ ] Ensure database has seed data (at least 1 test user)

### Frontend Setup
- [ ] Navigate to `d:\workspace\kanji_mobile_v1`
- [ ] Run `flutter pub get` (if not done)
- [ ] Run `flutter analyze` (ensure no errors)
- [ ] Start emulator/simulator (Android/iOS/Chrome)
- [ ] Run `flutter run`
- [ ] App opens on LoginPage

---

## Manual Testing Checklist

### 🔐 Test 1: Login Flow
#### Happy Path
- [ ] Enter valid account: `testuser`
- [ ] Enter valid password: `Test@123456`
- [ ] Tap "Login" button
- [ ] ✅ Loading widget shows "Logging in..."
- [ ] ✅ Navigate to HomePage after success
- [ ] ✅ Bottom navigation shows 5 tabs
- [ ] ✅ Kanji tab is active by default

#### Error Cases
- [ ] Empty form → Tap "Login"
  - ✅ Validation errors show under fields
- [ ] Invalid email format → Tap "Login"
  - ✅ "Please enter a valid email" error
- [ ] Wrong password → Tap "Login"
  - ✅ Red SnackBar: "Invalid credentials"
- [ ] Backend offline → Tap "Login"
  - ✅ Red SnackBar: "Network error" or "Cannot connect"

#### UI/UX
- [ ] ✅ Fade + slide animations smooth (800ms)
- [ ] ✅ Password visibility toggle works
- [ ] ✅ "Forgot Password?" link navigates to ForgotPasswordPage
- [ ] ✅ "Register" link navigates to RegisterPage
- [ ] ✅ Social login buttons show "Coming Soon" alert

---

### 📝 Test 2: Register Flow
#### Happy Path
- [ ] From LoginPage → Tap "Register"
- [ ] Enter username: `newuser_$(timestamp)`
- [ ] Enter email: `newuser_$(timestamp)@test.com`
- [ ] Enter password: `NewPass@2025`
- [ ] Enter confirm password: `NewPass@2025`
- [ ] Tap "Create Account"
- [ ] ✅ Loading widget shows "Creating account..."
- [ ] ✅ Navigate to HomePage after success
- [ ] ✅ User is auto-logged in

#### Error Cases
- [ ] Duplicate username → Tap "Create Account"
  - ✅ Red SnackBar: "Account already exists"
- [ ] Invalid email → Tap "Create Account"
  - ✅ Validation error
- [ ] Weak password (e.g., "pass") → Tap "Create Account"
  - ✅ Validation error: "Password must be at least 8 characters"
- [ ] Password mismatch → Tap "Create Account"
  - ✅ Validation error: "Passwords do not match"

#### UI/UX
- [ ] ✅ Password requirements box displays checkmarks
- [ ] ✅ Both password fields have visibility toggles
- [ ] ✅ "Already have an account? Login" link works
- [ ] ✅ Back button in AppBar navigates to LoginPage

---

### 🔑 Test 3: Forgot Password Flow
#### Happy Path
- [ ] From LoginPage → Tap "Forgot Password?"
- [ ] Enter registered email: `testuser@example.com`
- [ ] Tap "Send Reset Link"
- [ ] ✅ Loading widget shows "Sending reset link..."
- [ ] ✅ Green SnackBar: "Password reset link sent!"
- [ ] ✅ Info box visible: "Check your spam folder..."
- [ ] ✅ Auto-redirect to LoginPage after 2 seconds

#### Error Cases
- [ ] Unregistered email → Tap "Send Reset Link"
  - ✅ Red SnackBar: "User not found"
- [ ] Invalid email format → Tap "Send Reset Link"
  - ✅ Validation error

#### UI/UX
- [ ] ✅ Lock reset icon (large, primary color)
- [ ] ✅ "Back to Login" button works
- [ ] ✅ Info box with blue border and icon

---

### 🏠 Test 4: Home Page Navigation
#### Bottom Navigation
- [ ] Tap "Kanji" tab
  - ✅ Welcome card with gradient visible
  - ✅ "Welcome to Kanji Master! 🎌" text
  - ✅ Quick actions: "Browse Kanji", "AI Recognition"
  - ✅ Stats card: Day Streak (0), Learned (0), Quiz Score (0)
  
- [ ] Tap "Search" tab
  - ✅ Placeholder: "Search Feature Coming Soon"
  
- [ ] Tap "Flashcards" tab
  - ✅ Placeholder: "Flashcards Feature Coming Soon"
  
- [ ] Tap "Quiz" tab
  - ✅ Placeholder: "Quiz Feature Coming Soon"
  
- [ ] Tap "Profile" tab
  - ✅ Avatar placeholder visible
  - ✅ "User Name" + "user@email.com" displayed
  - ✅ Menu items: Edit Profile, Learning History, Achievements, Settings, Help & Support
  - ✅ Logout button (red color)

#### AppBar Actions
- [ ] Tap Notifications icon
  - ✅ SnackBar: "Notifications - Coming Soon"
  
- [ ] Tap Settings icon
  - ✅ SnackBar: "Settings - Coming Soon"

#### Quick Actions
- [ ] Tap "Browse Kanji" card
  - ✅ SnackBar: "Kanji Dictionary - Coming Soon"
  
- [ ] Tap "AI Recognition" card
  - ✅ SnackBar: "AI Recognition - Coming Soon"

---

### 🚪 Test 5: Logout Flow
#### Happy Path
- [ ] Navigate to Profile tab
- [ ] Scroll to bottom → Tap "Logout" (red)
- [ ] AlertDialog appears: "Are you sure you want to logout?"
- [ ] Tap "Logout" (red text in dialog)
- [ ] ✅ Navigate to LoginPage
- [ ] ✅ Close app and reopen → Still on LoginPage (not auto-login)

#### Cancel Path
- [ ] Tap "Logout" → Dialog appears
- [ ] Tap "Cancel"
- [ ] ✅ Dialog dismisses, stay on Profile tab

---

### 🔄 Test 6: Auth Redirect Logic
#### Unauthenticated User
- [ ] Open app (not logged in)
- [ ] ✅ App opens on LoginPage automatically
- [ ] Try to navigate to `/` via deep link (if possible)
- [ ] ✅ Redirect back to LoginPage

#### Authenticated User
- [ ] Login successfully → HomePage
- [ ] Try to navigate to `/login` via back button (if possible)
- [ ] ✅ Redirect back to HomePage

#### Token Refresh (Advanced)
- [ ] Login with short-lived token (backend config: 5min expiry)
- [ ] Wait 6 minutes (token expires)
- [ ] Make any API call (e.g., get profile)
- [ ] ✅ DioClient auto-refreshes token
- [ ] ✅ Original request retried with new token
- [ ] ✅ No logout occurs

#### Token Refresh Failure
- [ ] Login → Manually delete refresh token from storage (debug only)
- [ ] Wait for access token expiry
- [ ] Make API call
- [ ] ✅ Refresh fails → User logged out → Navigate to LoginPage

---

## Automated Testing TODO (Future)

### Unit Tests
- [ ] Test `Validators` class (email, password, username, etc.)
- [ ] Test `AuthRepository` with mocked data sources
- [ ] Test Use Cases (LoginUseCase, RegisterUseCase, etc.)
- [ ] Test `DioClient` interceptors (auth, logging, error)

### BLoC Tests
- [ ] Test `AuthBloc` events and state transitions
  - [ ] LoginEvent → AuthLoading → LoginSuccess
  - [ ] LoginEvent → AuthLoading → AuthError
  - [ ] RegisterEvent → AuthLoading → RegisterSuccess
  - [ ] LogoutEvent → LogoutSuccess
  - [ ] ForgotPasswordEvent → AuthLoading → ForgotPasswordSuccess

### Widget Tests
- [ ] Test LoginPage UI
  - [ ] Form validation errors display
  - [ ] Password visibility toggle
  - [ ] Navigation to Register/ForgotPassword
- [ ] Test RegisterPage UI
  - [ ] Password requirements box
  - [ ] Confirm password matching
- [ ] Test ForgotPasswordPage UI
  - [ ] Email validation
  - [ ] Success message display
- [ ] Test HomePage UI
  - [ ] Bottom navigation switching tabs
  - [ ] Logout dialog functionality

### Integration Tests
- [ ] E2E: Login → Navigate tabs → Logout
- [ ] E2E: Register → Auto-login → HomePage
- [ ] E2E: Forgot Password → Receive email (mock)
- [ ] E2E: Token refresh scenario

---

## Performance Testing TODO

### Load Time
- [ ] Measure app startup time: `flutter run --profile`
- [ ] Target: < 2 seconds to LoginPage

### Animation Performance
- [ ] Check FPS during fade/slide animations
- [ ] Target: 60 FPS (use Flutter DevTools)

### Network Performance
- [ ] Measure API response times
  - [ ] Login: < 500ms
  - [ ] Register: < 1s
  - [ ] Profile: < 300ms

### Memory Usage
- [ ] Check memory leaks with Flutter DevTools
- [ ] Ensure BLoC streams are closed properly

---

## Security Testing TODO

### Token Storage
- [ ] Verify tokens stored in FlutterSecureStorage (encrypted)
- [ ] Verify tokens NOT in SharedPreferences (plain text)
- [ ] Verify tokens cleared on logout

### Password Handling
- [ ] Verify password NOT logged in console
- [ ] Verify password NOT cached anywhere
- [ ] Verify password sent via HTTPS only (check Dio logs)

### Session Management
- [ ] Verify session invalidated on logout (backend check)
- [ ] Verify refresh token rotated on refresh (backend check)

---

## Bug Reporting Template

```markdown
## Bug Report

**Title:** [Short description]

**Severity:** [Critical / High / Medium / Low]

**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happened]

**Screenshots/Logs:**
[Attach if available]

**Environment:**
- Device: [Android Emulator / iPhone 14 Simulator / Chrome]
- Flutter Version: 3.9.2
- Backend: kanji-web-be (version)
- OS: Windows / macOS / Linux

**Additional Notes:**
[Any other relevant info]
```

---

## Test Results Summary (To Be Filled)

### Manual Tests
- [ ] Login Flow: ✅ PASS / ❌ FAIL
- [ ] Register Flow: ✅ PASS / ❌ FAIL
- [ ] Forgot Password: ✅ PASS / ❌ FAIL
- [ ] Home Navigation: ✅ PASS / ❌ FAIL
- [ ] Logout Flow: ✅ PASS / ❌ FAIL
- [ ] Auth Redirects: ✅ PASS / ❌ FAIL

### Issues Found
- [ ] Issue #1: [Description]
- [ ] Issue #2: [Description]
- [ ] Issue #3: [Description]

### Overall Status
- [ ] ✅ All tests passed - Ready for production
- [ ] ⚠️ Minor issues - Can proceed with fixes
- [ ] ❌ Major issues - Requires rework

---

## Next Steps After Testing

### If All Tests Pass ✅
1. Commit all changes to Git
2. Create release branch: `release/auth-feature-v1.0`
3. Update version in `pubspec.yaml`: `1.0.0+1`
4. Proceed to implement Kanji Dictionary feature

### If Tests Fail ❌
1. Document all bugs in GitHub Issues
2. Prioritize by severity (Critical → High → Medium → Low)
3. Fix critical/high bugs first
4. Re-test after fixes
5. Repeat until all tests pass

---

**Testing Start Date:** _________  
**Testing End Date:** _________  
**Tested By:** _________  
**Status:** 🔄 Pending / ✅ Complete / ❌ Failed

---

**Related Docs:**
- `AUTH_UI_TESTING_GUIDE.md` - Detailed test cases with expected results
- `AUTH_FEATURE_COMPLETE_SUMMARY.md` - Implementation overview
- `IMPLEMENTATION_PROGRESS.md` - Overall project progress
