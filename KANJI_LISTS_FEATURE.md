# Tính năng Danh sách Kanji Tùy chỉnh

## 📋 Tổng quan

Tính năng danh sách kanji cho phép người dùng tạo và quản lý các danh sách học tập tùy chỉnh dựa trên nhiều tiêu chí khác nhau:
- **JLPT Level** (N5 - N1)
- **Grade/Lớp học** (Lớp 1-6)
- **Frequency/Độ phổ biến** (Kanji thường gặp)
- **Custom/Tùy chỉnh** (Thêm kanji thủ công)

### 🎁 **Danh sách có sẵn**

Khi khởi động app lần đầu, hệ thống tự động tạo **11 danh sách mặc định**:

#### JLPT Lists (5 lists):
1. **JLPT N5** - 80 kanji cơ bản nhất
2. **JLPT N4** - 103 kanji sơ cấp
3. **JLPT N3** - 181 kanji trung cấp
4. **JLPT N2** - 367 kanji trung cao
5. **JLPT N1** - 1235 kanji cao nhất

#### Kyōiku Kanji Lists (6 lists):
6. **Lớp 1** - 80 kanji cơ bản
7. **Lớp 2** - 160 kanji
8. **Lớp 3** - 200 kanji
9. **Lớp 4** - 202 kanji
10. **Lớp 5** - 193 kanji
11. **Lớp 6** - 191 kanji

**Tổng: 11 danh sách với 2,556 kanji được tổ chức sẵn!**

## ✨ Tính năng chính

### 1. Tạo danh sách theo JLPT Level
Người dùng có thể tạo danh sách kanji theo cấp độ JLPT (N5, N4, N3, N2, N1). Hệ thống sẽ tự động lọc và thêm tất cả các kanji thuộc level đó.

**Ví dụ:**
- Danh sách "JLPT N5" → 80 kanji
- Danh sách "JLPT N1" → 2000+ kanji

### 2. Tạo danh sách theo lớp học (Grade)
Tạo danh sách dựa trên kanji được dạy ở từng lớp học tiểu học Nhật Bản (1-6).

**Ví dụ:**
- Lớp 1 → 80 kanji cơ bản nhất
- Lớp 6 → Kanji phức tạp hơn

### 3. Tạo danh sách theo độ phổ biến
Lọc kanji dựa trên tần suất xuất hiện trong văn bản tiếng Nhật. Số thứ tự càng nhỏ = kanji càng phổ biến.

**Ví dụ:**
- Top 100 kanji phổ biến nhất (1-100)
- Kanji phổ biến trung bình (101-500)
- Kanji ít gặp (501-2000)

### 4. Danh sách tùy chỉnh
Người dùng có thể tạo danh sách trống và tự thêm kanji theo ý muốn (Coming soon).

## 🏗️ Kiến trúc Implementation

### Database Schema

#### Automatic Seeding on First Launch

Khi app khởi động lần đầu (hoặc upgrade lên version 3), hệ thống tự động:

1. **Tạo 11 danh sách mặc định** trong bảng `kanji_lists`
2. **Populate kanji** vào từng danh sách dựa trên filter criteria
3. **Cập nhật kanji_count** cho mỗi danh sách

```dart
// database_helper.dart - version 3
Future<void> _seedDefaultLists(Database db) async {
  // Create JLPT lists (N5-N1)
  // Create Grade lists (1-6)
  // Insert into kanji_lists table
  await _populateDefaultLists(db);
}

Future<void> _populateDefaultLists(Database db) async {
  // For each list:
  //   - Query kanji by filter_type and filter_value
  //   - Insert into kanji_list_items
  //   - Update kanji_count
}
```

#### Migration Strategy

```sql
-- Version 1: Initial kanji table
-- Version 2: Add kanji_lists and kanji_list_items tables
-- Version 3: Seed default JLPT and Grade lists ✨ NEW!
```

### Domain Layer

#### Entities
```dart
// kanji_list.dart
class KanjiList {
  final int id;
  final String name;
  final String? description;
  final ListFilterType filterType;
  final int? filterValue;
  final int? frequencyMin;
  final int? frequencyMax;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int kanjiCount;
}

enum ListFilterType {
  jlptLevel,
  frequency,
  grade,
  custom,
}
```

#### Repositories
```dart
// kanji_list_repository.dart
abstract class KanjiListRepository {
  Future<Either<Failure, List<KanjiList>>> getAllLists();
  Future<Either<Failure, KanjiList>> createList(KanjiList kanjiList);
  Future<Either<Failure, void>> deleteList(int id);
  Future<Either<Failure, List<int>>> getKanjiIdsInList(int listId);
  // ...
}
```

#### Use Cases
- `CreateKanjiList` - Tạo danh sách mới
- `GetAllKanjiLists` - Lấy tất cả danh sách
- `DeleteKanjiList` - Xóa danh sách
- `GetKanjiByJlptLevel` - Lọc kanji theo JLPT
- `GetKanjiByGrade` - Lọc kanji theo lớp
- `GetKanjiByFrequency` - Lọc kanji theo độ phổ biến

### Data Layer

#### Database Schema

```sql
-- Bảng lưu thông tin danh sách
CREATE TABLE kanji_lists (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  filter_type TEXT NOT NULL,
  filter_value INTEGER,
  frequency_min INTEGER,
  frequency_max INTEGER,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  kanji_count INTEGER DEFAULT 0
);

-- Bảng junction lưu mối quan hệ list-kanji
CREATE TABLE kanji_list_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  list_id INTEGER NOT NULL,
  kanji_id INTEGER NOT NULL,
  added_at TEXT NOT NULL,
  FOREIGN KEY (list_id) REFERENCES kanji_lists (id) ON DELETE CASCADE,
  FOREIGN KEY (kanji_id) REFERENCES kanji (id) ON DELETE CASCADE,
  UNIQUE(list_id, kanji_id)
);
```

#### Data Sources
```dart
// kanji_list_local_data_source.dart
class KanjiListLocalDataSourceImpl {
  Future<List<KanjiListModel>> getAllLists();
  Future<KanjiListModel> createList(KanjiListModel list);
  Future<void> addKanjiToList(int listId, List<int> kanjiIds);
  // ...
}
```

### Presentation Layer

#### BLoC

**Events:**
```dart
- LoadAllListsEvent
- CreateListEvent
- DeleteListEvent
- LoadListDetailEvent
```

**States:**
```dart
- KanjiListInitial
- KanjiListLoading
- KanjiListsLoaded
- KanjiListCreated
- KanjiListError
```

**Bloc Logic:**
```dart
class KanjiListBloc extends Bloc<KanjiListEvent, KanjiListState> {
  // Handles all list management logic
  // Auto-populates lists based on filter type
}
```

#### UI Pages

**1. MyListsPage**
- Hiển thị tất cả danh sách đã tạo
- Grid/List view với card cho mỗi danh sách
- Hiển thị: icon, tên, mô tả, số kanji, loại filter
- Actions: Xem chi tiết, Xóa

**2. CreateListPage**
- Form tạo danh sách mới
- Input: Tên, Mô tả
- Chọn loại filter: JLPT, Grade, Frequency
- Tùy chọn cụ thể cho mỗi loại:
  - JLPT: Chọn N5-N1
  - Grade: Chọn lớp 1-6  
  - Frequency: Range slider 1-2500
- Button "Tạo danh sách"

**3. ListDetailPage** (Coming soon)
- Hiển thị kanji trong danh sách
- Grid view giống trang chủ
- Có thể xem chi tiết từng kanji
- Actions: Thêm/Xóa kanji (với custom list)

## 🔄 Data Flow

### Tạo danh sách mới

```
User nhập thông tin 
    ↓
CreateListPage dispatches CreateListEvent
    ↓
KanjiListBloc receives event
    ↓
Calls CreateKanjiList use case
    ↓
Repository creates list in database
    ↓
Based on filter type, fetch matching kanji
    ↓
Add kanji IDs to junction table
    ↓
Update kanji_count
    ↓
BLoC emits KanjiListCreated state
    ↓
UI shows success message & navigates back
```

### Load danh sách

```
User opens MyListsPage
    ↓
LoadAllListsEvent dispatched
    ↓
GetAllKanjiLists use case called
    ↓
Repository queries kanji_lists table
    ↓
Returns list with kanji_count
    ↓
BLoC emits KanjiListsLoaded
    ↓
UI displays list cards
```

## 📱 UI/UX

### MyListsPage Design

```
╔════════════════════════════════════╗
║  Danh sách của tôi         [+]     ║
╠════════════════════════════════════╣
║                                    ║
║  ┌──────────────────────────────┐  ║
║  │ 📚 JLPT N5                   │  ║
║  │ Kanji cơ bản cho người mới   │  ║
║  │ [JLPT N5] [80 kanji]    [X]  │  ║
║  └──────────────────────────────┘  ║
║                                    ║
║  ┌──────────────────────────────┐  ║
║  │ 📈 Top 500 phổ biến          │  ║
║  │ Kanji thường gặp nhất        │  ║
║  │ [Độ phổ biến] [500 kanji][X] │  ║
║  └──────────────────────────────┘  ║
║                                    ║
╚════════════════════════════════════╝
```

### CreateListPage Design

```
╔════════════════════════════════════╗
║  Tạo danh sách mới          [<]    ║
╠════════════════════════════════════╣
║  ┌─ Thông tin cơ bản ─────────┐   ║
║  │ Tên: [________________]     │   ║
║  │ Mô tả: [_______________]    │   ║
║  └──────────────────────────────┘   ║
║                                    ║
║  ┌─ Chọn loại danh sách ──────┐   ║
║  │ ( ) JLPT Level              │   ║
║  │ (•) Lớp học                 │   ║
║  │ ( ) Độ phổ biến             │   ║
║  └──────────────────────────────┘   ║
║                                    ║
║  ┌─ Tùy chọn lọc ─────────────┐   ║
║  │ Lớp: [1][2][3][4][5][6]    │   ║
║  └──────────────────────────────┘   ║
║                                    ║
║  [    Tạo danh sách    ]           ║
╚════════════════════════════════════╝
```

## 🎨 Color Scheme

- **JLPT**: Purple (Tím) - `Colors.purple`
- **Grade**: Blue (Xanh dương) - `Colors.blue`
- **Frequency**: Orange (Cam) - `Colors.orange`
- **Custom**: Green (Xanh lá) - `Colors.green`

## 📊 Statistics

Mỗi danh sách hiển thị:
- Số lượng kanji trong danh sách
- Loại filter được sử dụng
- Ngày tạo (trong metadata)
- Icon tương ứng với loại

## 🚀 Future Enhancements

### Phase 1 - Completed ✅
- ✅ Tạo danh sách theo JLPT, Grade, Frequency
- ✅ Xem tất cả danh sách
- ✅ Xóa danh sách
- ✅ UI đẹp với card design
- ✅ **Seed 11 danh sách mặc định khi khởi động** ⭐ NEW!

### Phase 2 - Next Sprint
- [ ] Xem chi tiết danh sách với grid kanji
- [ ] Edit danh sách (đổi tên, mô tả)
- [ ] Thêm/xóa kanji thủ công từ danh sách
- [ ] Sort & filter trong danh sách
- [ ] Search kanji trong danh sách

### Phase 3 - Advanced
- [ ] Study mode cho danh sách
- [ ] Progress tracking (đã học bao nhiêu kanji)
- [ ] Quiz mode cho danh sách cụ thể
- [ ] Flashcard mode
- [ ] Share danh sách
- [ ] Export/Import danh sách
- [ ] Duplicate danh sách

### Phase 4 - Smart Features
- [ ] AI suggestions cho danh sách
- [ ] Auto-generate danh sách dựa trên văn bản
- [ ] Spaced repetition algorithm
- [ ] Analytics (kanji nào khó nhớ nhất)

## 📝 Files Created

### Domain Layer (7 files)
1. `domain/entities/kanji_list.dart` - Entity
2. `domain/repositories/kanji_list_repository.dart` - Repository interface
3. `domain/usecases/get_kanji_by_jlpt_level.dart`
4. `domain/usecases/get_kanji_by_frequency.dart`
5. `domain/usecases/create_kanji_list.dart`
6. `domain/usecases/get_all_kanji_lists.dart`
7. `domain/usecases/delete_kanji_list.dart`

### Data Layer (3 files)
8. `data/models/kanji_list_model.dart` - Model
9. `data/datasources/kanji_list_local_data_source.dart` - Data source
10. `data/repositories/kanji_list_repository_impl.dart` - Repository implementation

### Presentation Layer (5 files)
11. `presentation/bloc/kanji_list_event.dart`
12. `presentation/bloc/kanji_list_state.dart`
13. `presentation/bloc/kanji_list_bloc.dart`
14. `presentation/pages/my_lists_page.dart`
15. `presentation/pages/create_list_page.dart`

### Core & Setup (2 files)
16. Updated `core/database/database_helper.dart` - Added new tables
17. Updated `injection_container.dart` - DI setup

**Total: 17 files created/updated**

## 🧪 Testing

### Unit Tests
```dart
// Test create list use case
test('should create list successfully', () async {
  // arrange
  final params = CreateListParams(...);
  
  // act
  final result = await createKanjiList(params);
  
  // assert
  expect(result.isRight(), true);
});
```

### Widget Tests
```dart
// Test MyListsPage UI
testWidgets('should display list of kanji lists', (tester) async {
  // Build widget with mock data
  // Verify cards are displayed
  // Test delete functionality
});
```

## 🎯 Usage Examples

### Tạo danh sách JLPT N5
```dart
context.read<KanjiListBloc>().add(
  CreateListEvent(
    name: 'JLPT N5 - Kanji cơ bản',
    description: 'Tất cả kanji cho kỳ thi N5',
    filterType: ListFilterType.jlptLevel,
    filterValue: 5,
  ),
);
```

### Tạo danh sách top 500 phổ biến
```dart
context.read<KanjiListBloc>().add(
  CreateListEvent(
    name: 'Top 500',
    description: '500 kanji phổ biến nhất',
    filterType: ListFilterType.frequency,
    frequencyMin: 1,
    frequencyMax: 500,
  ),
);
```

## 💡 Tips for Users

1. **Bắt đầu với JLPT N5** - Danh sách dễ nhất cho người mới
2. **Chia nhỏ mục tiêu** - Tạo danh sách nhỏ (50-100 kanji) thay vì học tất cả
3. **Dùng frequency** - Top 500 kanji phủ ~80% văn bản tiếng Nhật
4. **Kết hợp nhiều danh sách** - Học song song JLPT + Frequency

## 🔗 Related Features

- **Kanji Stats** - Xem thống kê tổng thể
- **Search** - Tìm kanji để thêm vào danh sách
- **Detail View** - Xem chi tiết từng kanji

---

**Last Updated**: October 13, 2025
**Version**: 1.0.0
**Status**: ✅ Completed & Tested
