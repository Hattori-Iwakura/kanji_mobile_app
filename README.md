# 📱 Kanji Learning Mobile App - Flutter Frontend

Ứng dụng học tiếng Nhật Kanji trên nền tảng di động, xây dựng bằng **Flutter** với kiến trúc **Clean Architecture** và quản lý state bằng **Bloc Pattern**.

---

## � Tài liệu Code (Code Documentation)

**🎯 Quan trọng**: Để dễ dàng đọc hiểu code trong project này, vui lòng xem:

### 📚 [CODE_DOCUMENTATION.md](CODE_DOCUMENTATION.md)

Document này giải thích chi tiết:
- ✅ **Clean Architecture**: 3 layers (Domain, Data, Presentation)
- ✅ **Design Patterns**: Either, Equatable, BLoC, Repository, UseCase
- ✅ **Data Flow**: Chi tiết flow từ UI → BLoC → UseCase → Repository → API
- ✅ **Error Handling**: Exception vs Failure, try-catch patterns
- ✅ **Dependency Injection**: GetIt setup và cách sử dụng
- ✅ **Coding Conventions**: Naming, file organization, import order
- ✅ **Code Examples**: Ví dụ code cho mỗi layer với comment chi tiết

**Tất cả các file trong project đều có comment chi tiết giải thích:**
- Mục đích của class/function
- Tham số và return values
- Flow hoạt động
- Cách sử dụng
- Ví dụ thực tế

---

## �📋 Mục lục

- [Tổng quan](#-tổng-quan)
- [Kiến trúc hệ thống](#-kiến-trúc-hệ-thống)
- [Cấu trúc thư mục](#-cấu-trúc-thư-mục)
- [Các tính năng chính](#-các-tính-năng-chính)
- [Flow dữ liệu](#-flow-dữ-liệu)
- [Công nghệ sử dụng](#-công-nghệ-sử-dụng)
- [Cài đặt và chạy](#-cài-đặt-và-chạy)
- [Build và Deploy](#-build-và-deploy)
- [Kiểm thử](#-kiểm-thử)

---

## 🎯 Tổng quan

### Mục tiêu
Xây dựng ứng dụng di động học Kanji toàn diện với các tính năng:
- Học Kanji qua flashcard và quiz
- Nhận diện chữ viết tay Kanji bằng AI (CNN)
- Theo dõi tiến độ học tập
- Quản lý danh sách Kanji cá nhân

### Framework & Kiến trúc
- **Framework**: Flutter 3.x (Dart 3.x)
- **Architecture**: Clean Architecture (3 layers)
- **State Management**: Bloc/Cubit Pattern
- **Dependency Injection**: GetIt
- **API Communication**: Dio (REST API)
- **Local Storage**: Shared Preferences + Flutter Secure Storage

### Luồng hoạt động
```
User Interface (Flutter)
       ↓
Backend API (NestJS:3000)
       ↓
AI Service (FastAPI:8000)
       ↓
CNN Model (Kanji Recognition)
```

---

## 🏗️ Kiến trúc hệ thống

Ứng dụng được xây dựng theo **Clean Architecture** với 3 tầng độc lập:

### 1. Presentation Layer (UI)
- **Vai trò**: Hiển thị giao diện và tương tác người dùng
- **Components**:
  - `Pages`: Các màn hình chính
  - `Widgets`: Components UI tái sử dụng
  - `Bloc/Cubit`: Quản lý state và business logic của UI

### 2. Domain Layer (Business Logic)
- **Vai trò**: Chứa logic nghiệp vụ và các quy tắc của ứng dụng
- **Components**:
  - `Entities`: Các object model thuần túy
  - `Use Cases`: Các hành động nghiệp vụ cụ thể
  - `Repositories (Abstract)`: Interface cho data layer

### 3. Data Layer (Data Access)
- **Vai trò**: Xử lý dữ liệu từ các nguồn khác nhau
- **Components**:
  - `Models`: Data models với JSON serialization
  - `Data Sources`: Remote (API) và Local (Cache/Storage)
  - `Repositories (Implementation)`: Triển khai interface từ domain layer

### Ưu điểm của Clean Architecture
✅ **Tách biệt rõ ràng**: Mỗi layer có trách nhiệm riêng  
✅ **Dễ test**: Có thể test độc lập từng layer  
✅ **Scalable**: Dễ mở rộng và bảo trì  
✅ **Independence**: UI không phụ thuộc vào framework/database cụ thể  

---

## 📁 Cấu trúc thư mục

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # Material App configuration
├── injection_container.dart           # Dependency Injection setup (GetIt)
│
├── core/                              # Core utilities & shared code
│   ├── network/
│   │   ├── api_client.dart           # Dio HTTP client wrapper
│   │   └── api_endpoints.dart        # API endpoint constants
│   ├── storage/
│   │   └── secure_storage.dart       # Secure token storage
│   ├── services/
│   │   ├── cache_service.dart        # Caching service
│   │   ├── kanji_alive_service.dart  # External API: KanjiAlive
│   │   ├── jisho_service.dart        # External API: Jisho
│   │   └── kanji_vg_service.dart     # Kanji SVG diagrams
│   ├── constants/
│   │   └── app_constants.dart        # App-wide constants
│   ├── theme/
│   │   └── app_theme.dart            # Theme configuration
│   └── utils/
│       ├── error_handler.dart        # Error handling utilities
│       └── validators.dart           # Form validators
│
├── features/                          # Feature modules (Clean Architecture)
│   │
│   ├── auth/                         # 🔐 Authentication Module
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_data_source.dart      # API calls
│   │   │   │   └── auth_local_data_source.dart       # Local storage
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart                   # JSON ↔ Dart
│   │   │   │   └── login_response_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart         # Repository implementation
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart                         # Pure business object
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart              # Abstract repository
│   │   │   └── usecases/
│   │   │       ├── login.dart                        # Login use case
│   │   │       ├── register.dart                     # Register use case
│   │   │       ├── logout.dart
│   │   │       ├── get_profile.dart
│   │   │       ├── forgot_password.dart
│   │   │       ├── reset_password.dart
│   │   │       └── change_password.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart                    # State management
│   │       │   ├── auth_event.dart                   # User actions
│   │       │   └── auth_state.dart                   # UI states
│   │       ├── pages/
│   │       │   ├── login_page.dart                   # Login screen
│   │       │   ├── register_page.dart                # Register screen
│   │       │   ├── forgot_password_page.dart
│   │       │   └── profile_page.dart
│   │       └── widgets/
│   │           ├── custom_text_field.dart
│   │           └── auth_button.dart
│   │
│   ├── kanji/                        # 🈂️ Kanji Management Module
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── kanji_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── kanji_model.dart
│   │   │   └── repositories/
│   │   │       └── kanji_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── kanji.dart                        # character, meanings, readings
│   │   │   ├── repositories/
│   │   │   │   └── kanji_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_kanji_list.dart              # Fetch all kanji
│   │   │       ├── get_kanji_detail.dart            # Get single kanji
│   │   │       ├── search_kanji.dart                # Search by text/filters
│   │   │       └── create_kanji.dart                # Admin only
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── kanji_bloc.dart
│   │       │   ├── kanji_event.dart
│   │       │   └── kanji_state.dart
│   │       ├── pages/
│   │       │   ├── kanji_list_page.dart             # Browse kanji
│   │       │   ├── kanji_detail_page.dart           # Detail view
│   │       │   └── kanji_search_page.dart           # Search interface
│   │       └── widgets/
│   │           ├── kanji_card.dart                   # Kanji display card
│   │           ├── kanji_stroke_animation.dart      # SVG animation
│   │           └── kanji_filter_bottom_sheet.dart
│   │
│   ├── kanji_table/                  # 📊 Kanji Lists (Custom Collections)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── kanji_table_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── kanji_table_model.dart
│   │   │   └── repositories/
│   │   │       └── kanji_table_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── kanji_table.dart
│   │   │   ├── repositories/
│   │   │   │   └── kanji_table_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_tables.dart
│   │   │       ├── create_table.dart
│   │   │       ├── add_kanji_to_table.dart
│   │   │       └── delete_table.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── kanji_table_bloc.dart
│   │       └── pages/
│   │           ├── kanji_table_list_page.dart
│   │           └── kanji_table_detail_page.dart
│   │
│   ├── flashcard/                    # 🃏 Flashcard Study System
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── flashcard_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── flashcard_deck_model.dart
│   │   │   │   ├── flashcard_card_model.dart
│   │   │   │   └── study_session_model.dart
│   │   │   └── repositories/
│   │   │       └── flashcard_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── flashcard_deck.dart
│   │   │   │   ├── flashcard_card.dart
│   │   │   │   └── study_session.dart
│   │   │   ├── repositories/
│   │   │   │   └── flashcard_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_decks.dart
│   │   │       ├── create_deck.dart
│   │   │       ├── start_session.dart               # Start study session
│   │   │       ├── get_next_card.dart               # Get next card to study
│   │   │       ├── review_card.dart                 # Submit card review
│   │   │       ├── complete_session.dart            # Finish session
│   │   │       └── get_deck_statistics.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── flashcard_bloc.dart
│   │       ├── pages/
│   │       │   ├── flashcard_deck_list_page.dart    # All decks
│   │       │   ├── flashcard_deck_detail_page.dart  # Deck info + cards
│   │       │   └── study_session_page.dart          # Active study session
│   │       └── widgets/
│   │           ├── flip_card_widget.dart            # Animated flip card
│   │           ├── rating_buttons.dart              # Quality rating (1-5)
│   │           └── progress_indicator.dart
│   │
│   ├── quiz/                         # 📝 Quiz & Testing Module
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── quiz_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── quiz_model.dart
│   │   │   │   ├── question_model.dart
│   │   │   │   └── quiz_attempt_model.dart
│   │   │   └── repositories/
│   │   │       └── quiz_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── quiz.dart
│   │   │   │   ├── question.dart
│   │   │   │   └── quiz_attempt.dart
│   │   │   ├── repositories/
│   │   │   │   └── quiz_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_quizzes.dart
│   │   │       ├── start_quiz_attempt.dart
│   │   │       ├── submit_quiz_attempt.dart
│   │   │       └── get_quiz_attempts.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── quiz_bloc.dart
│   │       ├── pages/
│   │       │   ├── quiz_list_page.dart
│   │       │   ├── quiz_detail_page.dart
│   │       │   ├── quiz_attempt_page.dart           # Take quiz
│   │       │   └── quiz_result_page.dart            # Show results
│   │       └── widgets/
│   │           ├── question_card.dart
│   │           ├── multiple_choice_widget.dart
│   │           └── drawing_question_widget.dart     # Canvas for drawing
│   │
│   └── ai_recognition/               # 🤖 AI Kanji Recognition (CNN)
│       ├── data/
│       │   ├── datasources/
│       │   │   └── ai_remote_data_source.dart       # Call FastAPI
│       │   ├── models/
│       │   │   └── prediction_model.dart            # AI prediction result
│       │   └── repositories/
│       │       └── ai_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── prediction.dart                  # character, confidence
│       │   ├── repositories/
│       │   │   └── ai_repository.dart
│       │   └── usecases/
│       │       └── predict_kanji.dart               # Send image to AI
│       └── presentation/
│           ├── bloc/
│           │   └── ai_recognition_bloc.dart
│           ├── pages/
│           │   ├── drawing_canvas_page.dart         # Draw kanji
│           │   └── prediction_result_page.dart      # Show AI result
│           └── widgets/
│               ├── canvas_painter.dart              # Custom painter
│               ├── drawing_tools.dart               # Pen/eraser controls
│               └── prediction_list.dart             # Top 5 predictions
│
└── shared/                            # Shared widgets & utilities
    ├── widgets/
    │   ├── custom_app_bar.dart
    │   ├── loading_widget.dart
    │   ├── error_widget.dart
    │   └── empty_state_widget.dart
    └── extensions/
        ├── string_extensions.dart
        └── context_extensions.dart
```

---

## ✨ Các tính năng chính

### 1. 🔐 Xác thực người dùng (Authentication)
**Màn hình**: `login_page.dart`, `register_page.dart`, `profile_page.dart`

#### Chức năng:
- ✅ Đăng ký tài khoản mới (email, password, name)
- ✅ Đăng nhập với JWT authentication
- ✅ Quên mật khẩu & đặt lại mật khẩu
- ✅ Xem và chỉnh sửa profile
- ✅ Đổi mật khẩu
- ✅ Đăng xuất

#### Flow đăng nhập:
```dart
User Input (Email/Password)
    ↓
LoginEvent → AuthBloc
    ↓
LoginUseCase → AuthRepository
    ↓
AuthRemoteDataSource → API (POST /auth/login)
    ↓
Save JWT Token → SecureStorage
    ↓
AuthState.Authenticated → Navigate to Home
```

#### Code mẫu:
```dart
// Event
context.read<AuthBloc>().add(LoginEvent(
  email: emailController.text,
  password: passwordController.text,
));

// State handling
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    }
    return LoginForm();
  },
);
```

---

### 2. 🈂️ Học Kanji (Kanji Learning)
**Màn hình**: `kanji_list_page.dart`, `kanji_detail_page.dart`

#### Chức năng:
- ✅ Xem danh sách Kanji (lọc theo JLPT, grade, stroke count)
- ✅ Tìm kiếm Kanji theo ký tự, nghĩa, âm đọc
- ✅ Xem chi tiết Kanji:
  - Chữ Kanji lớn
  - Onyomi (音読み) - Âm Hán
  - Kunyomi (訓読み) - Âm Nhật
  - Meanings (ý nghĩa tiếng Anh)
  - Stroke count (số nét)
  - Ví dụ từ vựng
  - Hình ảnh minh họa (từ KanjiAlive API)
  - Hoạt ảnh viết nét (từ KanjiVG)

#### Tích hợp API ngoài:
```dart
// KanjiAlive Service - Lấy ví dụ và hình ảnh
final examples = await kanjiAliveService.getKanjiDetails('学');

// Jisho Service - Từ điển Nhật-Anh
final jishoData = await jishoService.searchWord('学生');

// KanjiVG Service - SVG stroke animation
final svgData = await kanjiVGService.getKanjiSvg('学');
```

---

### 3. 🃏 Flashcard - Học với thẻ ghi nhớ
**Màn hình**: `flashcard_deck_list_page.dart`, `study_session_page.dart`

#### Chức năng:
- ✅ Tạo bộ flashcard (deck) tùy chỉnh
- ✅ Thêm Kanji vào deck
- ✅ Bắt đầu phiên học (study session)
- ✅ Lật thẻ xem mặt trước/sau
- ✅ Đánh giá độ khó (1-5) theo thuật toán **Spaced Repetition (SM-2)**
- ✅ Xem thống kê học tập (cards reviewed, accuracy, time spent)

#### Thuật toán SM-2 (SuperMemo 2):
```
Công thức tính interval:
- Quality < 3: Reset interval = 1
- Quality >= 3: 
    New interval = Old interval × Easiness Factor
    Easiness Factor = EF + (0.1 - (5 - Quality) × (0.08 + (5 - Quality) × 0.02))
```

#### Flow học flashcard:
```
Start Session → Get Next Card → Show Front
    ↓
User taps card → Flip to Back
    ↓
User rates quality (1-5) → ReviewCardEvent
    ↓
Update card stats (SM-2 algorithm) → Backend
    ↓
Get Next Card → Repeat
    ↓
No more cards → Complete Session → Show Statistics
```

#### Code mẫu:
```dart
// Start session
context.read<FlashcardBloc>().add(StartSessionEvent(
  deckId: widget.deckId,
  maxNewCards: 20,
  maxReviewCards: 50,
  reviewType: ReviewType.ALL,
));

// Review card with quality rating
context.read<FlashcardBloc>().add(ReviewCardEvent(
  sessionId: session.id,
  cardId: currentCard.id,
  quality: 4, // 1-5 rating
  timeSpent: timeSpent,
));
```

---

### 4. 📝 Quiz - Kiểm tra kiến thức
**Màn hình**: `quiz_list_page.dart`, `quiz_attempt_page.dart`, `quiz_result_page.dart`

#### Các loại câu hỏi:
- ✅ **Multiple Choice**: Chọn đáp án đúng
- ✅ **True/False**: Đúng/Sai
- ✅ **Fill in the Blank**: Điền từ còn thiếu
- ✅ **Drawing**: Vẽ Kanji (tích hợp AI recognition)

#### Flow làm bài quiz:
```
Select Quiz → Start Attempt
    ↓
Answer Questions (one by one)
    ↓
Submit Attempt → Backend grades answers
    ↓
Show Results (score, correct/total, time spent)
    ↓
Review wrong answers
```

---

### 5. 🎨 Vẽ và nhận diện Kanji bằng AI
**Màn hình**: `drawing_canvas_page.dart`, `prediction_result_page.dart`

#### Chức năng:
- ✅ Vẽ Kanji trên canvas bằng tay
- ✅ Xóa/reset canvas
- ✅ Gửi ảnh tới AI server (FastAPI)
- ✅ Nhận kết quả dự đoán từ mô hình CNN
- ✅ Hiển thị top 5 predictions với confidence score

#### Flow nhận diện:
```
User draws on Canvas
    ↓
Convert canvas to PNG image
    ↓
Send image to AI API (POST /api/v1/predict-base64)
    ↓
FastAPI → CNN Model (3036 classes)
    ↓
Return predictions: [
  {character: '学', confidence: 0.98},
  {character: '字', confidence: 0.01},
  ...
]
    ↓
Display results in Flutter UI
```

#### Code mẫu:
```dart
// Capture canvas as image
final image = await canvasPainter.toImage();
final byteData = await image.toByteData(format: ImageByteFormat.png);
final imageBytes = byteData!.buffer.asUint8List();
final base64Image = base64Encode(imageBytes);

// Send to AI
context.read<AiRecognitionBloc>().add(PredictKanjiEvent(
  base64Image: base64Image,
));

// Handle result
BlocListener<AiRecognitionBloc, AiRecognitionState>(
  listener: (context, state) {
    if (state is PredictionSuccess) {
      // state.prediction.character
      // state.prediction.confidence
      // state.prediction.top5
    }
  },
);
```

---

### 6. 📊 Thống kê & Theo dõi tiến độ
**Màn hình**: `statistics_page.dart`

#### Hiển thị:
- ✅ Tổng số Kanji đã học
- ✅ Số thẻ flashcard đã ôn
- ✅ Độ chính xác (accuracy)
- ✅ Thời gian học tổng cộng
- ✅ Biểu đồ tiến độ theo ngày/tuần/tháng
- ✅ Cards due today (cần ôn hôm nay)

---

## 🔄 Flow dữ liệu (Data Flow)

### Luồng dữ liệu theo Clean Architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐          │
│  │  Pages   │ ───▶ │   Bloc   │ ───▶ │  Widgets │          │
│  └──────────┘      └──────────┘      └──────────┘          │
│                          │                                   │
│                          │ Events                            │
│                          ▼                                   │
│                    ┌──────────┐                              │
│                    │  States  │                              │
│                    └──────────┘                              │
└─────────────────────────────────────────────────────────────┘
                           │ ▲
                  Dispatch │ │ Emit State
                    Events │ │
                           ▼ │
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌──────────────┐      ┌──────────────┐                     │
│  │  Use Cases   │ ───▶ │ Repositories │ (Abstract)          │
│  │              │      │  Interface   │                     │
│  └──────────────┘      └──────────────┘                     │
│  - GetKanjiList              │                               │
│  - CreateDeck                │ Call methods                  │
│  - PredictKanji              ▼                               │
│  - StartSession        ┌──────────────┐                     │
│                        │   Entities   │                     │
│                        └──────────────┘                     │
└─────────────────────────────────────────────────────────────┘
                           │
                  Implements Interface
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌──────────────────────────────────────────────┐           │
│  │         Repository Implementation            │           │
│  │  (Decides: use cache or fetch from remote)   │           │
│  └──────────────────────────────────────────────┘           │
│            │                            │                    │
│            ▼                            ▼                    │
│  ┌──────────────────┐        ┌──────────────────┐          │
│  │ Remote DataSource│        │ Local DataSource │          │
│  │  (API Client)    │        │  (Cache/Storage) │          │
│  └──────────────────┘        └──────────────────┘          │
│            │                            │                    │
│            ▼                            ▼                    │
│  ┌──────────────────┐        ┌──────────────────┐          │
│  │  Backend API     │        │ SharedPreferences│          │
│  │  (NestJS:3000)   │        │ SecureStorage    │          │
│  └──────────────────┘        └──────────────────┘          │
│            │                                                 │
│            ▼                                                 │
│  ┌──────────────────┐                                       │
│  │   AI Service     │                                       │
│  │  (FastAPI:8000)  │                                       │
│  └──────────────────┘                                       │
└─────────────────────────────────────────────────────────────┘
```

### Ví dụ cụ thể: Tìm kiếm Kanji

```dart
// 1. USER ACTION (Presentation)
TextField(
  onSubmitted: (query) {
    context.read<KanjiBloc>().add(SearchKanjiEvent(query));
  },
)

// 2. BLOC receives event
class KanjiBloc extends Bloc<KanjiEvent, KanjiState> {
  Future<void> _onSearchKanji(SearchKanjiEvent event, emit) async {
    emit(KanjiLoading());
    
    // 3. Call USE CASE (Domain)
    final result = await searchKanjiUseCase(query: event.query);
    
    // 4. Handle result
    result.fold(
      (failure) => emit(KanjiError(failure.message)),
      (kanjiList) => emit(KanjiLoaded(kanjiList)),
    );
  }
}

// 5. USE CASE (Domain)
class SearchKanjiUseCase {
  final KanjiRepository repository;
  
  Future<Either<Failure, List<Kanji>>> call({required String query}) {
    return repository.searchKanji(query);
  }
}

// 6. REPOSITORY IMPLEMENTATION (Data)
class KanjiRepositoryImpl implements KanjiRepository {
  final KanjiRemoteDataSource remoteDataSource;
  final CacheService cacheService;
  
  @override
  Future<Either<Failure, List<Kanji>>> searchKanji(String query) async {
    try {
      // Check cache first
      final cachedData = await cacheService.get('kanji_$query');
      if (cachedData != null) {
        return Right(cachedData);
      }
      
      // Fetch from API
      final kanjiModels = await remoteDataSource.searchKanji(query);
      
      // Map to entities
      final kanjiEntities = kanjiModels.map((model) => model.toEntity()).toList();
      
      // Cache result
      await cacheService.set('kanji_$query', kanjiEntities);
      
      return Right(kanjiEntities);
    } catch (e) {
      return Left(ServerFailure('Failed to search kanji'));
    }
  }
}

// 7. REMOTE DATA SOURCE (Data)
class KanjiRemoteDataSourceImpl implements KanjiRemoteDataSource {
  final ApiClient apiClient;
  
  @override
  Future<List<KanjiModel>> searchKanji(String query) async {
    final response = await apiClient.get('/kanji/search', queryParameters: {
      'query': query,
    });
    
    return (response.data['data'] as List)
        .map((json) => KanjiModel.fromJson(json))
        .toList();
  }
}

// 8. API CLIENT (Core)
class ApiClient {
  final Dio dio;
  
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final token = await secureStorage.getToken();
    
    return dio.get(
      'https://api.kanji-app.com$path',
      queryParameters: queryParameters,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }
}

// 9. UI UPDATES (Presentation)
BlocBuilder<KanjiBloc, KanjiState>(
  builder: (context, state) {
    if (state is KanjiLoading) {
      return CircularProgressIndicator();
    } else if (state is KanjiLoaded) {
      return ListView.builder(
        itemCount: state.kanjiList.length,
        itemBuilder: (context, index) {
          return KanjiCard(kanji: state.kanjiList[index]);
        },
      );
    } else if (state is KanjiError) {
      return Text('Error: ${state.message}');
    }
    return Container();
  },
)
```

---

## 🛠️ Công nghệ sử dụng

### Core Framework
- **Flutter** 3.24+: Cross-platform UI framework
- **Dart** 3.5+: Programming language

### State Management
- **flutter_bloc** ^8.1.6: Business Logic Component pattern
- **equatable** ^2.0.5: Value equality for Bloc states/events

### Dependency Injection
- **get_it** ^8.0.2: Service locator for DI

### Networking
- **dio** ^5.7.0: HTTP client
- **pretty_dio_logger** ^1.4.0: Network logging

### Storage
- **shared_preferences** ^2.3.2: Simple key-value storage
- **flutter_secure_storage** ^9.2.2: Encrypted storage for tokens

### UI Components
- **flip_card** ^0.7.0: Flashcard flip animation
- **flutter_svg** ^2.0.10: SVG rendering (kanji strokes)
- **cached_network_image** ^3.4.1: Image caching
- **shimmer** ^3.0.0: Loading skeleton effect

### Canvas & Drawing
- **signature** ^5.5.0: Canvas drawing for kanji recognition
- **image** ^4.2.0: Image processing

### Utilities
- **intl** ^0.19.0: Internationalization
- **collection** ^1.18.0: Collection utilities
- **flutter_dotenv** ^5.1.0: Environment variables

### Testing
- **flutter_test**: Widget testing
- **bloc_test** ^9.1.7: Bloc testing utilities
- **mockito** ^5.4.4: Mocking for unit tests

---

## 🚀 Cài đặt và chạy

### Yêu cầu hệ thống
- Flutter SDK: 3.24.0 trở lên
- Dart SDK: 3.5.0 trở lên
- Android Studio / VS Code
- Android SDK (cho Android) hoặc Xcode (cho iOS)

### Bước 1: Clone project
```bash
git clone https://github.com/your-repo/kanji_mobile_app.git
cd kanji_mobile_app
```

### Bước 2: Cài đặt dependencies
```bash
flutter pub get
```

### Bước 3: Cấu hình môi trường
Tạo file `.env` trong thư mục root:

```env
# Backend API
API_BASE_URL=https://your-backend-api.com/api
# Hoặc local: http://localhost:3000/api

# AI Service
AI_SERVICE_URL=http://localhost:8000

# App Configuration
APP_NAME=Kanji Learning
DEBUG_MODE=true
```

### Bước 4: Khởi tạo Dependency Injection
File `injection_container.dart` đã được setup sẵn, không cần config thêm.

### Bước 5: Chạy app
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Chọn device cụ thể
flutter run -d <device-id>

# List devices
flutter devices
```

### Bước 6: Hot Reload trong development
Trong khi app đang chạy:
- Press `r` để hot reload (UI changes)
- Press `R` để hot restart (full restart)
- Press `q` để quit

---

## 📦 Build và Deploy

### Build APK (Android)
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APK theo ABI (giảm kích thước)
flutter build apk --split-per-abi
```

File output: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (Android - recommended for Play Store)
```bash
flutter build appbundle --release
```

File output: `build/app/outputs/bundle/release/app-release.aab`

### Build iOS
```bash
# Yêu cầu macOS + Xcode
flutter build ios --release

# Build IPA
flutter build ipa
```

### Build Web
```bash
flutter build web --release
```

File output: `build/web/`

---

## 🧪 Kiểm thử

### Unit Tests
```bash
# Chạy tất cả unit tests
flutter test

# Chạy test với coverage
flutter test --coverage

# Xem coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Widget Tests
```bash
# Test một file cụ thể
flutter test test/features/auth/presentation/pages/login_page_test.dart
```

### Integration Tests
```bash
# Chạy integration tests
flutter test test/integration/flashcard_api_integration_test.dart

# Với device
flutter drive --target=test_driver/app.dart
```

### Ví dụ Unit Test:
```dart
// test/features/auth/domain/usecases/login_test.dart
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  test('should return User when login is successful', () async {
    // Arrange
    final user = User(id: 1, email: 'test@example.com', name: 'Test User');
    when(mockRepository.login(any, any))
        .thenAnswer((_) async => Right(user));

    // Act
    final result = await useCase(email: 'test@example.com', password: 'password');

    // Assert
    expect(result, Right(user));
    verify(mockRepository.login('test@example.com', 'password'));
  });
}
```

---

## 🐛 Troubleshooting

### Lỗi thường gặp:

#### 1. Dio connection error
```
DioException [connection error]: The connection was interrupted
```
**Giải pháp**: Kiểm tra backend API đang chạy, sửa `API_BASE_URL` trong `.env`

#### 2. JWT token expired
```
401 Unauthorized
```
**Giải pháp**: Token hết hạn, logout và login lại

#### 3. Plugin flutter_secure_storage error in tests
```
MissingPluginException: No implementation found
```
**Giải pháp**: Mock SecureStorage trong tests:
```dart
class MockSecureStorage extends SecureStorage {
  final Map<String, String> _storage = {};
  
  @override
  Future<void> saveToken(String token) async {
    _storage['auth_token'] = token;
  }
  
  @override
  Future<String?> getToken() async {
    return _storage['auth_token'];
  }
}
```

#### 4. Canvas drawing không hoạt động
**Giải pháp**: Kiểm tra AI service đang chạy tại port 8000

---

## 📚 Tài liệu tham khảo

### Clean Architecture
- [The Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture Guide](https://resocoder.com/flutter-clean-architecture-tdd/)

### Bloc Pattern
- [Bloc Library Documentation](https://bloclibrary.dev/)
- [Flutter Bloc Best Practices](https://bloclibrary.dev/#/architecture)

### Flutter
- [Flutter Official Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

### External APIs
- [KanjiAlive API](https://app.kanjialive.com/api/docs)
- [Jisho API](https://jisho.org/forum/54fefc1f6e73340b1f160000-is-there-any-kind-of-search-api)
- [KanjiVG SVG Data](https://kanjivg.tagaini.net/)

---

## 👥 Đóng góp

Contributions are welcome! Please follow these steps:

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is proprietary. All rights reserved.

---

## 📞 Liên hệ & Support

For issues, questions, or contributions:
- Create an issue on GitHub
- Email: support@kanji-app.com

---

**Built with ❤️ using Flutter & Clean Architecture**
