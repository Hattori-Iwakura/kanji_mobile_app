# Hướng dẫn chi tiết về Architecture

## Clean Architecture Overview

Dự án này được xây dựng theo mô hình **Clean Architecture** của Uncle Bob, chia thành 3 layers chính:

```
┌─────────────────────────────────────────┐
│        Presentation Layer               │
│  (UI, BLoC, Pages, Widgets)            │
└─────────────────┬───────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────┐
│          Domain Layer                   │
│  (Entities, Use Cases, Repositories)   │
└─────────────────┬───────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────┐
│           Data Layer                    │
│  (Models, Data Sources, Repository     │
│   Implementations)                      │
└─────────────────────────────────────────┘
```

## Layer Details

### 1. Domain Layer (Business Logic)
**Không phụ thuộc vào bất kỳ layer nào khác**

#### Entities (`domain/entities/`)
- Đại diện cho business objects
- Chỉ chứa properties và business rules
- Ví dụ: `Kanji` entity

```dart
class Kanji extends Equatable {
  final int id;
  final String character;
  final int strokes;
  // ... other properties
}
```

#### Repositories (`domain/repositories/`)
- Abstract interface định nghĩa contract
- Không implement, chỉ định nghĩa methods
- Data layer sẽ implement các interface này

```dart
abstract class KanjiRepository {
  Future<Either<Failure, List<Kanji>>> getAllKanji();
  Future<Either<Failure, Kanji>> getKanjiById(int id);
  // ... other methods
}
```

#### Use Cases (`domain/usecases/`)
- Chứa business logic của ứng dụng
- Mỗi use case thực hiện một nhiệm vụ cụ thể
- Single Responsibility Principle

```dart
class GetAllKanji implements UseCase<List<Kanji>, NoParams> {
  final KanjiRepository repository;
  
  @override
  Future<Either<Failure, List<Kanji>>> call(NoParams params) {
    return repository.getAllKanji();
  }
}
```

### 2. Data Layer (Data Management)
**Phụ thuộc vào Domain Layer**

#### Models (`data/models/`)
- Extend từ domain entities
- Thêm methods: `fromJson()`, `toJson()`
- Xử lý serialization/deserialization

```dart
class KanjiModel extends Kanji {
  factory KanjiModel.fromJson(Map<String, dynamic> json) {
    // Parse JSON to model
  }
  
  Map<String, dynamic> toJson() {
    // Convert model to JSON
  }
}
```

#### Data Sources (`data/datasources/`)
- Xử lý việc lấy data từ nguồn cụ thể
- Local: Database, SharedPreferences
- Remote: API calls

```dart
abstract class KanjiLocalDataSource {
  Future<List<KanjiModel>> getAllKanji();
}

class KanjiLocalDataSourceImpl implements KanjiLocalDataSource {
  final DatabaseHelper databaseHelper;
  // Implementation
}
```

#### Repository Implementations (`data/repositories/`)
- Implement abstract repositories từ domain
- Coordinate giữa data sources
- Convert models thành entities

```dart
class KanjiRepositoryImpl implements KanjiRepository {
  final KanjiLocalDataSource localDataSource;
  
  @override
  Future<Either<Failure, List<Kanji>>> getAllKanji() async {
    try {
      final kanji = await localDataSource.getAllKanji();
      return Right(kanji);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }
}
```

### 3. Presentation Layer (UI & State Management)
**Phụ thuộc vào Domain Layer**

#### BLoC (`presentation/bloc/`)
- Quản lý state của UI
- Xử lý events từ UI
- Emit states cho UI

**Events**: User actions
```dart
abstract class KanjiEvent extends Equatable {}

class LoadAllKanjiEvent extends KanjiEvent {}
class SearchKanjiEvent extends KanjiEvent {
  final String query;
}
```

**States**: UI states
```dart
abstract class KanjiState extends Equatable {}

class KanjiInitial extends KanjiState {}
class KanjiLoading extends KanjiState {}
class KanjiLoaded extends KanjiState {
  final List<Kanji> kanjiList;
}
class KanjiError extends KanjiState {
  final String message;
}
```

**BLoC**: Business Logic Component
```dart
class KanjiBloc extends Bloc<KanjiEvent, KanjiState> {
  final GetAllKanji getAllKanji;
  
  KanjiBloc({required this.getAllKanji}) : super(KanjiInitial()) {
    on<LoadAllKanjiEvent>(_onLoadAllKanji);
  }
  
  Future<void> _onLoadAllKanji(event, emit) async {
    emit(KanjiLoading());
    final result = await getAllKanji(NoParams());
    result.fold(
      (failure) => emit(KanjiError(message: 'Error')),
      (kanji) => emit(KanjiLoaded(kanjiList: kanji)),
    );
  }
}
```

#### Pages (`presentation/pages/`)
- UI components
- Listen to BLoC states
- Dispatch events to BLoC

```dart
BlocBuilder<KanjiBloc, KanjiState>(
  builder: (context, state) {
    if (state is KanjiLoading) {
      return CircularProgressIndicator();
    } else if (state is KanjiLoaded) {
      return ListView(children: [...]);
    }
    return Container();
  },
)
```

## Dependency Injection

Sử dụng **GetIt** để quản lý dependencies:

```dart
// injection_container.dart
final sl = GetIt.instance;

Future<void> init() async {
  // BLoC
  sl.registerFactory(() => KanjiBloc(
    getAllKanji: sl(),
    getKanjiByGrade: sl(),
    searchKanji: sl(),
  ));
  
  // Use Cases
  sl.registerLazySingleton(() => GetAllKanji(sl()));
  
  // Repositories
  sl.registerLazySingleton<KanjiRepository>(
    () => KanjiRepositoryImpl(localDataSource: sl()),
  );
  
  // Data Sources
  sl.registerLazySingleton<KanjiLocalDataSource>(
    () => KanjiLocalDataSourceImpl(databaseHelper: sl()),
  );
  
  // Core
  sl.registerLazySingleton(() => DatabaseHelper.instance);
}
```

## Data Flow

### Read Flow (Get Kanji)
```
User Action
    ↓
UI dispatches Event
    ↓
BLoC receives Event
    ↓
BLoC calls Use Case
    ↓
Use Case calls Repository
    ↓
Repository calls Data Source
    ↓
Data Source queries Database
    ↓
Data returns through layers
    ↓
BLoC emits State
    ↓
UI rebuilds
```

### Write Flow (Future: Add/Update/Delete)
```
User Action
    ↓
UI dispatches Event
    ↓
BLoC receives Event
    ↓
BLoC calls Use Case
    ↓
Use Case calls Repository
    ↓
Repository calls Data Source
    ↓
Data Source updates Database
    ↓
Success/Failure returns
    ↓
BLoC emits State
    ↓
UI shows result
```

## Error Handling

Sử dụng **Either** từ package `dartz`:

```dart
// Success case
return Right(data);

// Failure case
return Left(DatabaseFailure());
```

### Failure Types
```dart
abstract class Failure extends Equatable {}

class DatabaseFailure extends Failure {}
class NetworkFailure extends Failure {}
class CacheFailure extends Failure {}
```

## Testing Strategy

### Unit Tests
- Test Use Cases
- Test Repository Implementations
- Test BLoC logic

### Widget Tests
- Test individual widgets
- Test page layouts

### Integration Tests
- Test complete flows
- Test database operations

## Best Practices

1. **Single Responsibility**: Mỗi class chỉ làm một việc
2. **Dependency Inversion**: Depend on abstractions, not concretions
3. **Separation of Concerns**: Các layers không biết về implementation của nhau
4. **Testability**: Dễ dàng test từng component riêng biệt
5. **Scalability**: Dễ dàng thêm features mới

## Adding New Features

### Example: Add Favorite Kanji Feature

1. **Domain Layer**:
```dart
// entities/favorite_kanji.dart
class FavoriteKanji extends Equatable { }

// repositories/favorite_repository.dart
abstract class FavoriteRepository {
  Future<Either<Failure, void>> addFavorite(int kanjiId);
}

// usecases/add_favorite.dart
class AddFavorite implements UseCase<void, FavoriteParams> { }
```

2. **Data Layer**:
```dart
// models/favorite_kanji_model.dart
class FavoriteKanjiModel extends FavoriteKanji { }

// datasources/favorite_local_data_source.dart
abstract class FavoriteLocalDataSource { }

// repositories/favorite_repository_impl.dart
class FavoriteRepositoryImpl implements FavoriteRepository { }
```

3. **Presentation Layer**:
```dart
// bloc/favorite_event.dart
class AddFavoriteEvent extends FavoriteEvent { }

// bloc/favorite_state.dart
class FavoriteAdded extends FavoriteState { }

// bloc/favorite_bloc.dart
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> { }

// pages/favorites_page.dart
class FavoritesPage extends StatelessWidget { }
```

4. **Dependency Injection**:
```dart
// injection_container.dart
sl.registerFactory(() => FavoriteBloc(...));
sl.registerLazySingleton(() => AddFavorite(sl()));
sl.registerLazySingleton<FavoriteRepository>(...);
```

---

**Lợi ích của Clean Architecture:**
- ✅ Dễ maintain và scale
- ✅ Code có tổ chức, dễ đọc
- ✅ Dễ test
- ✅ Độc lập với framework/database
- ✅ Nhiều developer có thể làm việc song song
