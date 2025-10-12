# Kanji Mobile - Ứng dụng học Kanji tiếng Nhật

Ứng dụng học Kanji tiếng Nhật được xây dựng với Flutter, sử dụng kiến trúc Clean Architecture và BLoC pattern.

## ✨ Tính năng

- 📚 Thư viện kanji đầy đủ với hơn 2000+ kanji
- 🔍 Tìm kiếm kanji theo ký tự hoặc nghĩa
- 📊 Lọc theo lớp học (Grade 1-6)
- 📖 Hiển thị chi tiết từng kanji:
  - Số nét
  - Nghĩa (tiếng Anh)
  - Âm đọc On (音読み)
  - Âm đọc Kun (訓読み)
  - Cấp độ JLPT
  - Bộ thủ (Radicals)
- 💾 Database SQLite local với seed data từ file JSON

## 🏗️ Kiến trúc

Dự án được xây dựng theo **Clean Architecture** với 3 layers:

### 1. Presentation Layer
- **BLoC**: Quản lý state với `flutter_bloc`
- **Pages**: UI components (KanjiListPage, KanjiDetailPage)
- **Events & States**: Định nghĩa các sự kiện và trạng thái

### 2. Domain Layer
- **Entities**: Kanji entity
- **Repositories**: Abstract repositories
- **Use Cases**: Business logic (GetAllKanji, GetKanjiByGrade, SearchKanji)

### 3. Data Layer
- **Models**: KanjiModel extends Kanji entity
- **Data Sources**: Local data source với SQLite
- **Repository Implementation**: Implement domain repositories

## 📦 Dependencies chính

```yaml
dependencies:
  flutter_bloc: ^8.1.6      # State management
  equatable: ^2.0.5         # Value comparison
  sqflite: ^2.3.3+1         # SQLite database
  get_it: ^7.7.0            # Dependency injection
  dartz: ^0.10.1            # Functional programming
```

## 🚀 Cài đặt và chạy

1. Clone repository
2. Cài đặt dependencies:
```bash
flutter pub get
```

3. Chạy ứng dụng:
```bash
flutter run
```

## 📁 Cấu trúc thư mục

```
lib/
├── core/
│   ├── database/
│   │   └── database_helper.dart
│   ├── error/
│   │   └── failures.dart
│   └── usecases/
│       └── usecase.dart
├── features/
│   └── kanji/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── kanji_local_data_source.dart
│       │   ├── models/
│       │   │   └── kanji_model.dart
│       │   └── repositories/
│       │       └── kanji_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── kanji.dart
│       │   ├── repositories/
│       │   │   └── kanji_repository.dart
│       │   └── usecases/
│       │       ├── get_all_kanji.dart
│       │       ├── get_kanji_by_grade.dart
│       │       └── search_kanji.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── kanji_bloc.dart
│           │   ├── kanji_event.dart
│           │   └── kanji_state.dart
│           └── pages/
│               ├── kanji_list_page.dart
│               └── kanji_detail_page.dart
├── injection_container.dart
└── main.dart
```

## 💡 Cách sử dụng

1. **Trang chủ**: Hiển thị danh sách kanji dạng grid
2. **Tìm kiếm**: Nhập ký tự hoặc nghĩa để tìm kiếm
3. **Lọc theo lớp**: Sử dụng menu filter để chọn lớp (1-6)
4. **Xem chi tiết**: Chạm vào kanji để xem thông tin chi tiết

## 📊 Database

Database SQLite được tự động tạo và seed data từ `assets/kanji-merged.json` khi ứng dụng chạy lần đầu. Dữ liệu bao gồm:
- Hơn 2000+ kanji
- Thông tin đầy đủ về mỗi kanji
- Được index để tìm kiếm nhanh chóng

## 🎨 UI/UX

- Material Design 3
- Responsive grid layout
- Gradient background cho kanji cards
- Smooth navigation
- Loading states
- Error handling

## 📝 License

MIT License

---

This project is licensed under the MIT License - see the LICENSE file for details.
