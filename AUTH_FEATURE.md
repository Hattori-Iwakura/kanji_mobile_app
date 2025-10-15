# Auth Feature - Kanji Learning App

## 📋 Tổng quan

Feature xác thực (Authentication) được xây dựng theo **Clean Architecture** với **BLoC Pattern**, tích hợp với backend NestJS API.

## 🏗️ Kiến trúc

```
features/auth/
├── data/
│   ├── datasources/
│   │   └── auth_remote_datasource.dart      # API calls
│   ├── models/
│   │   ├── user_model.dart                  # User data model
│   │   └── auth_response_model.dart         # Auth response model
│   ├── repositories/
│   │   └── auth_repository_impl.dart        # Repository implementation
│   └── auth_service.dart                    # Token & session management
│
├── domain/
│   ├── entities/
│   │   ├── user.dart                        # User entity
│   │   └── auth_response.dart               # Auth response entity
│   ├── repositories/
│   │   └── auth_repository.dart             # Repository interface
│   └── usecases/
│       ├── login_usecase.dart               # Login use case
│       ├── logout_usecase.dart              # Logout use case
│       └── refresh_token_usecase.dart       # Refresh token use case
│
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart                   # Business logic
    │   ├── auth_event.dart                  # Events
    │   └── auth_state.dart                  # States
    └── pages/
        └── login_page.dart                  # Login UI
```

## 🔑 Tính năng

### ✅ Đã hoàn thành

1. **Login**
   - Đăng nhập với account/email và password
   - Lưu trữ access token, refresh token, session ID
   - Tự động set Authorization header cho API calls

2. **Token Management**
   - Lưu trữ an toàn với `flutter_secure_storage`
   - Tự động refresh token khi hết hạn
   - Clear token khi logout

3. **Session Management**
   - Quản lý session ID
   - Kiểm tra authentication state
   - Persist login state

4. **Error Handling**
   - Xử lý network errors
   - Xử lý server errors
   - Xử lý authentication errors
   - Hiển thị thông báo lỗi thân thiện

## 🔌 API Endpoints

### Backend (NestJS)

```typescript
POST /api/auth/login
Body: {
  "account": "string",
  "password": "string"
}
Response: {
  "accessToken": "string",
  "refreshToken": "string",
  "sessionId": "string",
  "user": {
    "id": number,
    "account": "string",
    "email": "string",
    "profile_image": "string?",
    "is_first_login": boolean,
    "create_at": "datetime"
  },
  "expiresAt": "datetime"
}

POST /api/auth/refresh/mobile
Body: {
  "sessionId": "string",
  "refreshToken": "string"
}
Response: {
  "accessToken": "string",
  "refreshToken": "string",
  "expiresAt": "datetime"
}

POST /api/auth/logout
Body: {
  "sessionId": "string"
}
Response: {
  "ok": true
}
```

## 🎯 BLoC Events & States

### Events

```dart
- AuthCheckRequested()       // Check if user is authenticated
- LoginRequested(account, password)
- RefreshTokenRequested()
- LogoutRequested()
```

### States

```dart
- AuthInitial()              // Initial state
- AuthLoading()              // Processing
- AuthAuthenticated(user, accessToken)
- AuthUnauthenticated()      // Not logged in
- AuthError(message)         // Error occurred
```

## 🚀 Sử dụng

### 1. Khởi tạo Dependency Injection

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize dependencies
  runApp(const MyApp());
}
```

### 2. Sử dụng trong Widget

```dart
// Login Page
BlocProvider(
  create: (_) => di.sl<AuthBloc>(),
  child: BlocConsumer<AuthBloc, AuthState>(
    listener: (context, state) {
      if (state is AuthAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      }
      if (state is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
    },
    builder: (context, state) {
      // Build UI based on state
    },
  ),
)

// Login action
context.read<AuthBloc>().add(
  LoginRequested(account, password),
);

// Logout action
context.read<AuthBloc>().add(
  const LogoutRequested(),
);
```

### 3. Check Authentication

```dart
// App startup or protected pages
context.read<AuthBloc>().add(
  const AuthCheckRequested(),
);
```

## 🔧 Configuration

### API Endpoint

Cập nhật trong `lib/core/network/endpoint.dart`:

```dart
class ApiEndpoints {
  static const baseUrl = "http://10.0.2.2:3000/api"; // Android emulator
  // static const baseUrl = "http://localhost:3000/api"; // iOS simulator
  // static const baseUrl = "https://your-api.com/api"; // Production
}
```

### Backend Setup

Backend phải thêm header check để phân biệt mobile/web:

```typescript
// auth.controller.ts
const isMobile = req.headers['x-platform'] === 'mobile';
```

Flutter app tự động gửi header `X-Platform: mobile` trong mọi request.

## 📦 Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.7
  get_it: ^7.6.4
  dio: ^5.9.0
  flutter_secure_storage: ^9.2.4
  pretty_dio_logger: ^1.3.1
  dartz: ^0.10.1
```

## 🐛 Xử lý lỗi thường gặp

### 1. "Connection refused"
- Kiểm tra backend có đang chạy không
- Kiểm tra URL endpoint đúng chưa
- Android emulator: dùng `10.0.2.2` thay vì `localhost`

### 2. "Unauthorized"
- Kiểm tra account/password
- Kiểm tra token có hết hạn không
- Thử logout và login lại

### 3. "Session expired"
- Token hết hạn, refresh token thất bại
- Cần logout và login lại

## 🔜 Tính năng sắp tới

- [ ] Register user
- [ ] Forgot password
- [ ] Change password
- [ ] Update profile
- [ ] Social login (Google, Facebook)
- [ ] Biometric authentication
- [ ] Remember me option

## 📝 Notes

- Access token có thời gian sống ngắn (15 phút - 1 giờ)
- Refresh token có thời gian sống dài (30 ngày)
- Session được quản lý ở backend
- Token được lưu an toàn với `flutter_secure_storage`
- Mỗi request tự động thêm Authorization header nếu có token

## 🎨 UI/UX

- Loading indicator khi đang xử lý
- Error messages dễ hiểu
- Form validation
- Password visibility toggle
- Responsive design
- Material Design 3

---

**Author**: Kanji Learning Team  
**Last Updated**: 2025-10-15
