# Kanji Create Bug Report - Authentication Token Missing

**Ngày:** October 21, 2025  
**Người báo cáo:** User  
**Mức độ:** 🔴 **CRITICAL** - Chức năng tạo kanji không hoạt động

## Triệu chứng

Khi Admin đăng nhập và bấm nút "Add Kanji" trong Dictionary page, form tạo kanji hiện lên đầy đủ. Tuy nhiên khi điền thông tin và bấm "Create", **không có gì xảy ra** - không có thông báo thành công, không có lỗi hiển thị, kanji không được tạo.

## Root Cause Analysis

### 1. **Authentication Token Không Được Gửi Trong Request** ✅ CONFIRMED

**Evidence từ integration tests:**
```
╔╣ DioError ║ Status: 401 Unauthorized ║ Time: 44 ms
║  http://10.0.2.2:3000/api/kanji
╚═══════════════════════════════════════════════════════
╔ DioExceptionType.badResponse
║    {
║         "statusCode": 401,
║         "timestamp": "2025-10-21T07:48:10.129Z",
║         "error": "Unauthorized"
║    }
```

**Phân tích:**
- Admin login thành công → nhận token
- Request POST /kanji được gửi
- Server trả về **401 Unauthorized** thay vì 403 Forbidden
- **401 = "Không có token"** vs **403 = "Có token nhưng không đủ quyền"**

### 2. **ApiClient Token Management Issue**

**File:** `lib/core/network/api_client.dart`

ApiClient có method `setAuthToken()`:
```dart
void setAuthToken(String token) {
  dio.options.headers['Authorization'] = 'Bearer $token';
}
```

**Vấn đề:** Token được set vào `dio.options.headers` nhưng có thể bị mất trong các trường hợp:
- App restart
- Page navigation tạo instance mới của bloc
- Memory cleanup

### 3. **Dependency Injection Problem**

**File:** `lib/features/kanji/presentation/pages/kanji_create_page.dart` Line 100-102

```dart
return BlocProvider(
  create: (_) => di.sl<KanjiBloc>(),  // ❌ Tạo bloc mới mỗi lần
  child: Scaffold(
```

**Vấn đề:**
- Mỗi lần navigate đến KanjiCreatePage, một **KanjiBloc instance mới** được tạo
- Bloc mới sử dụng **KanjiRepository mới**
- Repository mới sử dụng **ApiClient mới hoặc chưa có token**

### 4. **Test Results Confirming Issue**

**Tests Failed:** 16 out of 22 tests
**Pass Rate:** 27%

**Failed Test Categories:**
1. ❌ Create kanji API (401 Unauthorized)
2. ❌ Update kanji API (401 Unauthorized)  
3. ❌ Delete kanji API (401 Unauthorized)
4. ❌ Admin create flow (Dio already registered)
5. ❌ Detail page (meanings field type mismatch)

**Passed Tests:** ✅
- Dictionary load
- JLPT/Grade filtering
- Regular user blocked from create (correctly returns 401)

## Architecture Issues Found

### Issue 1: Token Persistence
**Current Flow:**
```
Login → Get Token → Store in SecureStorage → ❌ NOT automatically loaded
```

**Expected Flow:**
```
Login → Get Token → Store in SecureStorage → Set in ApiClient → ✅ All requests include token
App Start → Load token from SecureStorage → Set in ApiClient → ✅ Auto-authenticated
```

### Issue 2: ApiClient Instance Management
**Current:** Multiple ApiClient instances created via DI
**Problem:** Token set in one instance không affect other instances
**Solution:** ApiClient should be **singleton** with shared state

### Issue 3: BlocProvider Creates New Instance
**Current:** `BlocProvider(create: (_) => di.sl<KanjiBloc>())`
**Problem:** Tạo bloc mới = repository mới = API client mới = lose token
**Solution:** Sử dụng `BlocProvider.value()` để reuse existing bloc

## Backend Response Format

**Successful Login:**
```json
{
  "statusCode": 201,
  "data": {
    "user": {
      "id": 11,
      "email": "admin@example.com",
      "role": "ADMIN"
    },
    "accessToken": "eyJhbGciOiJIUzI1..."
  },
  "timestamp": "2025-10-21T07:48:10.072Z"
}
```

**Create Request (Without Token):**
```json
// Headers: Content-Type, Accept, X-Platform
// ❌ Missing: Authorization: Bearer <token>
Body: {
  "character": "編",
  "onyomi": ["ヘン"],
  "kunyomi": ["あ.む"],
  "meanings": ["compilation", "knit", "editing"],
  "strokeCount": 15,
  "jlptLevel": "N2"
}
```

**Backend Response:**
```json
{
  "statusCode": 401,
  "timestamp": "2025-10-21T07:48:10.129Z",
  "error": "Unauthorized"
}
```

## Why User Sees Nothing Happen

### UI Behavior Analysis

**File:** `kanji_create_page.dart` Lines 113-152

```dart
BlocConsumer<KanjiBloc, KanjiState>(
  listener: (context, state) {
    if (state is KanjiCreated) {  // ✅ Would show success
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
    if (state is KanjiError) {  // ❌ Error state never reached
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  },
```

**Problem Flow:**
1. User fills form and clicks "Create"
2. `_handleSubmit()` validates form ✅
3. Dispatches `CreateKanjiEvent` to bloc ✅
4. Bloc calls repository → API POST /kanji
5. API request **without token** → 401 response
6. Error thrown in ApiClient
7. ❌ **Error NOT properly caught by bloc**
8. ❌ **KanjiError state NOT emitted**
9. ❌ **UI shows nothing** - no error message, no feedback

## Fixes Required

### Fix 1: Token Interceptor (RECOMMENDED)
**File:** `lib/core/network/api_client.dart`

Add Dio interceptor to automatically inject token:

```dart
// Add this in ApiClient constructor
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    // Load token from secure storage
    final token = await _secureStorage.read(key: 'auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
));
```

**Pros:**
- ✅ Automatic token injection for all requests
- ✅ No manual token management needed
- ✅ Works across app restarts
- ✅ Single source of truth

**Cons:**
- Async interceptor may slow down requests slightly

### Fix 2: Singleton ApiClient with Persistent Token
**File:** `lib/injection_container.dart`

```dart
// Change from factory to singleton
sl.registerLazySingleton<ApiClient>(() => ApiClient());

// After login, load token
final apiClient = sl<ApiClient>();
final token = await secureStorage.read(key: 'auth_token');
if (token != null) {
  apiClient.setAuthToken(token);
}
```

### Fix 3: Fix KanjiBloc Error Handling
**File:** `lib/features/kanji/presentation/bloc/kanji_bloc.dart`

Ensure all repository exceptions emit `KanjiError` state:

```dart
on<CreateKanjiEvent>((event, emit) async {
  emit(KanjiLoading());
  try {
    final kanji = await _kanjiRepository.createKanji(event.kanjiData);
    emit(KanjiCreated(kanji));
  } catch (e) {
    emit(KanjiError(e.toString()));  // ✅ Must catch ALL errors
  }
});
```

### Fix 4: Use BlocProvider.value for Existing Bloc
**File:** `kanji_create_page.dart`

```dart
// Instead of creating new bloc:
return BlocProvider(
  create: (_) => di.sl<KanjiBloc>(),  // ❌
  
// Use existing bloc from parent:
return BlocProvider.value(
  value: context.read<KanjiBloc>(),  // ✅
```

### Fix 5: Backend API Field Names
**Issue:** Backend uses `jlpt` (integer) but app sends `jlptLevel` (string)

**Evidence:**
```json
// Backend returns:
"jlpt": 5,  // integer
"grade": 1

// App sends:
"jlptLevel": "N2",  // string
"grade": 4
```

**Fix:** Check backend DTO to confirm field names and types

## Testing Strategy

### Unit Tests Needed
1. ✅ ApiClient token injection
2. ✅ Token persistence across app restart
3. ✅ KanjiBloc error handling
4. ✅ Create kanji with valid token

### Integration Tests Needed
1. ✅ Full create flow: Login → Navigate → Fill form → Submit → Success
2. ✅ Create without token → Show error
3. ✅ Regular user create → 403 Forbidden
4. ✅ Invalid data → Validation error

### Manual Testing Steps
1. Login as admin
2. Navigate to Dictionary
3. Click Add button
4. Fill form with test data
5. Submit
6. **Expected:** Success message + navigate back + kanji appears in list
7. **Actual (before fix):** Nothing happens

## Priority & Impact

**Priority:** 🔴 **P0 - Critical**
**Impact:** 🔥 **HIGH**
- Admin không thể tạo kanji mới
- Chức năng core bị broken
- No error feedback = bad UX

**Users Affected:** All admins

**Workaround:** None - feature completely broken

## Next Steps

1. ✅ Implement Fix 1 (Token Interceptor) - HIGHEST PRIORITY
2. ✅ Implement Fix 3 (Error Handling) - CRITICAL
3. ✅ Fix backend field name mismatch
4. ✅ Update integration tests
5. ✅ Run full test suite
6. ✅ Manual testing with admin account
7. ✅ Document fix in session notes

## Related Issues

- Similar issue may exist in:
  - Update kanji flow
  - Delete kanji flow
  - Admin quiz create
  - Admin category create

**Action:** Audit all admin-only operations for same token issue.
