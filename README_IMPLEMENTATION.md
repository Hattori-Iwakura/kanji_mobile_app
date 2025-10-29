# Kanji Mobile App - Clean Architecture Implementation

## 📁 Cấu trúc dự án (Feature-based Clean Architecture)

```
lib/
├── core/                          # Core utilities cho toàn app
│   ├── error/                     # Error handling
│   │   ├── exceptions.dart        # Custom exceptions
│   │   └── failures.dart          # Failure types
│   ├── network/                   # Network layer
│   │   └── api_client.dart        # Dio API client
│   └── storage/                   # Storage layer
│       └── secure_storage.dart    # Secure storage wrapper
│
├── features/                      # Features (mỗi feature có clean arch riêng)
│   └── auth/                      # Auth feature
│       ├── data/                  # Data layer
│       │   ├── datasources/       # Data sources (remote, local)
│       │   │   ├── auth_local_data_source.dart
│       │   │   └── auth_remote_data_source.dart
│       │   ├── models/            # Data models
│       │   │   └── user_model.dart
│       │   └── repositories/      # Repository implementations
│       │       └── auth_repository_impl.dart
│       ├── domain/                # Domain layer (business logic)
│       │   ├── entities/          # Domain entities
│       │   │   └── user.dart
│       │   ├── repositories/      # Repository interfaces
│       │   │   └── auth_repository.dart
│       │   └── usecases/          # Use cases
│       │       ├── check_auth_status.dart
│       │       ├── get_profile.dart
│       │       ├── login.dart
│       │       └── logout.dart
│       └── presentation/          # Presentation layer (UI)
│           ├── bloc/              # State management (BLoC)
│           │   ├── auth_bloc.dart
│           │   ├── auth_event.dart
│           │   └── auth_state.dart
│           └── pages/             # UI pages
│               └── login_page.dart
│
├── src/presentation/              # Global presentation components
│   ├── app.dart                   # App root widget
│   ├── pages/
│   │   └── home_page.dart         # Home page
│   └── widgets/
│       ├── fancy_bottom_app_bar.dart
│       └── main_drawer.dart       # Drawer với auth integration
│
├── injection_container.dart       # Dependency Injection setup
└── main.dart                      # App entrypoint

```

## 🏗️ Clean Architecture Layers

### 1. **Domain Layer** (Business Logic)
- **Entities**: Pure Dart objects (User)
- **Repositories**: Interfaces định nghĩa contracts
- **Use Cases**: Business logic cụ thể (Login, Logout, GetProfile)

### 2. **Data Layer** (Implementation)
- **Models**: Data models extend entities
- **Data Sources**: Remote (API) và Local (Storage)
- **Repository Implementations**: Implement domain repositories

### 3. **Presentation Layer** (UI)
- **BLoC**: State management
- **Pages**: UI screens
- **Widgets**: Reusable UI components

## 🚀 Cách chạy

### Prerequisites
- Flutter SDK
- Backend NestJS đang chạy trên `http://localhost:3000`

### Setup & Run

```bash
# 1. Cài đặt dependencies
flutter pub get

# 2. Chạy app
flutter run

# 3. (Optional) Analyze code
flutter analyze
```

## 🔐 Authentication Flow

### 1. **App Startup**
- App khởi động → `CheckAuthStatusEvent` được trigger
- Kiểm tra token trong secure storage
- Nếu có token → auto login và hiển thị thông tin user
- Nếu không → hiển thị trạng thái unauthenticated

### 2. **Login Flow**
- User mở drawer → tap "Đăng nhập"
- Nhập email/password → submit form
- `LoginEvent` → `AuthBloc` xử lý
- Success → token được lưu → navigate về home
- Error → hiển thị snackbar lỗi

### 3. **Logout Flow**
- User tap "Đăng xuất" trong drawer
- `LogoutEvent` → xóa token khỏi storage
- State chuyển về `Unauthenticated`
- Drawer tự động cập nhật hiển thị "Đăng nhập"

## 📡 API Endpoints sử dụng

```
POST /api/auth/login       - Login
POST /api/auth/register    - Register
GET  /api/auth/profile     - Get profile
```

## 🔧 Config

### API Base URL
Trong `lib/core/network/api_client.dart`:
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

**Note**: Đổi sang IP thực nếu test trên thiết bị thật:
- Android emulator: `http://10.0.2.2:3000/api`
- iOS simulator: `http://localhost:3000/api`
- Physical device: `http://YOUR_COMPUTER_IP:3000/api`

## 📦 Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.6           # State management
  equatable: ^2.0.5              # Value equality
  dio: ^5.7.0                    # HTTP client
  flutter_secure_storage: ^9.2.2 # Secure token storage
  shared_preferences: ^2.3.3     # Local preferences
  get_it: ^8.0.2                 # Dependency injection
  dartz: ^0.10.1                 # Functional programming (Either)
```

## 🎨 UI Features

### HomePage
- Gradient dark background
- Horizontal scrolling cards (Học Kanji, Flashcards, Quiz)
- Grid features (Danh sách, Lịch sử, Thống kê, Cài đặt)
- FAB ở giữa bottom bar

### Drawer
- Hiển thị thông tin user (nếu đã login)
- Menu navigation
- **Login button** (nếu chưa login)
- **Logout button** (nếu đã login)

### LoginPage
- Form validation
- Email/password fields
- Loading state
- Error handling với snackbar
- Dark theme UI

## 🧪 Dependency Injection

File `injection_container.dart` sử dụng **GetIt** để quản lý dependencies:

```dart
// Sử dụng
final authBloc = sl<AuthBloc>();
```

## 🔜 Next Steps

Để mở rộng app, có thể thêm:

1. **Register Page** - Đăng ký tài khoản mới
2. **Forgot Password Flow** - Quên mật khẩu
3. **Kanji Feature** - List, detail, search kanji
4. **Flashcard Feature** - Study với spaced repetition
5. **Quiz Feature** - Practice quiz
6. **Profile Page** - Xem và chỉnh sửa profile
7. **Offline Support** - Cache data locally

## 📝 Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage
```

## 🐛 Troubleshooting

### Connection refused
- Kiểm tra backend đang chạy
- Kiểm tra API base URL
- Nếu dùng physical device, dùng IP thay vì localhost

### Token not persisting
- Kiểm tra Flutter Secure Storage đã setup đúng platform
- Android: Cần minSdkVersion >= 18
- iOS: Tự động hoạt động

## 📄 License

MIT License
