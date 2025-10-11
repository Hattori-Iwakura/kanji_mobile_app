# Kanji Mobile App - Hybrid Offline/Online Database

## Tổng quan

App Kanji này được thiết kế với kiến trúc hybrid database cho phép hoạt động cả offline và online:

- **Online mode**: Dữ liệu được sync từ API server (PostgreSQL backend)
- **Offline mode**: Dữ liệu được lưu trữ local sử dụng Drift (SQLite)
- **Hybrid sync**: Tự động fallback giữa remote và local data

## Kiến trúc

### 1. Clean Architecture + BLoC Pattern
```
lib/
├── domain/           # Business logic layer
│   ├── entities/     # Core business objects
│   └── repositories/ # Abstract interfaces
├── data/            # Data access layer
│   ├── datasources/  # Local database (Drift)
│   ├── remote/       # Remote API client
│   ├── repositories/ # Implementation
│   └── extensions/   # Helper extensions
└── presentation/    # UI layer
    ├── blocs/       # State management
    ├── pages/       # Screens
    └── widgets/     # Reusable components
```

### 2. Database Strategy

#### Remote Database (PostgreSQL)
- Primary data source
- Accessed via REST API
- Server: Express.js
- CRUD operations: GET, POST, PUT, DELETE

#### Local Database (Drift/SQLite)
- Offline storage
- Auto-generated code
- Schema sync với remote
- Tracking sync status

#### Hybrid Repository
- **KanjiRepositoryHybrid**: Implements fallback strategy
- Online-first approach
- Automatic offline fallback
- Bidirectional sync

## Tính năng chính

### 1. Offline-First Experience
```dart
// Try remote first, fallback to local
Future<List<Kanji>> getAll() async {
  try {
    final remote = await remoteDataSource.fetchAllKanjis();
    await _syncLocalWithRemote(remote);
    return remote;
  } catch (e) {
    final local = await localDatabase.getAllKanjis();
    return local.toEntityList();
  }
}
```

### 2. Smart Sync System
- **Sync từ Remote**: Download data mới từ server
- **Sync tới Remote**: Upload local changes to server
- **Conflict Resolution**: Simple last-write-wins
- **Pending Changes**: Track local-only changes with negative IDs

### 3. Search Functionality
- Remote search khi online
- Local search khi offline
- Full-text search trên character, meanings, readings

## Cách sử dụng

### 1. Basic Operations

#### Load Kanjis
```dart
// BLoC automatically handles online/offline
bloc.add(LoadKanjis());
```

#### Add Kanji
```dart
// Tries remote first, fallback to local with temp ID
bloc.add(AddKanjiEvent(newKanji));
```

#### Search
```dart
// Smart search across online/offline data
bloc.add(SearchKanjiEvent("漢字"));
```

### 2. Sync Management

#### Check Status
```dart
final isOnline = await repository.isOnline();
final localCount = await repository.getLocalKanjiCount();
final pending = await repository.getPendingSyncCount();
```

#### Manual Sync
```dart
// Download từ server
await repository.syncFromRemote();

// Upload local changes
await repository.syncToRemote();
```

### 3. UI Components

#### Sync Status Widget
- Hiển thị trạng thái online/offline
- Button sync manual
- Counter cho pending changes
- Real-time status updates

#### Search Bar
- Debounced search input
- Clear functionality
- Loading states

## Database Schema

### Local (Drift)
```dart
class KanjiTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get character => text()();
  TextColumn get meanings => text()();
  TextColumn get onyomi => text().nullable()();
  TextColumn get kunyomi => text().nullable()();
  IntColumn get strokeCount => integer().nullable()();
  IntColumn get jlpt => integer().nullable()();
  IntColumn get grade => integer().nullable()();
  IntColumn get frequency => integer().nullable()();
  TextColumn get radicals => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

### Remote API Endpoints
```
GET    /api/kanjis     - Get all kanjis
POST   /api/kanjis     - Create kanji
PUT    /api/kanjis/:id - Update kanji
DELETE /api/kanjis/:id - Delete kanji
```

## Best Practices

### 1. Error Handling
- Graceful degradation khi network issues
- User feedback cho sync failures
- Retry mechanisms cho critical operations

### 2. Performance
- Pagination cho large datasets
- Efficient search indexing
- Background sync operations

### 3. Data Consistency
- Timestamp-based conflict resolution
- Atomic transactions
- Rollback on failures

## Troubleshooting

### Common Issues

1. **Build errors**: Run `dart run build_runner build`
2. **Sync failures**: Check network connectivity
3. **Data inconsistency**: Manual sync from remote
4. **Performance**: Clear local database and re-sync

### Development Tips

1. **Generated Code**: Drift requires code generation
2. **Database Migration**: Handle schema changes carefully
3. **Testing**: Mock both remote and local data sources
4. **Debugging**: Use sync status widget for monitoring

## Next Steps

1. **Incremental Sync**: Only sync changed records
2. **Conflict Resolution**: More sophisticated merging
3. **Background Sync**: Periodic automatic sync
4. **Offline Indicators**: Better UX for connectivity states
5. **Caching Strategy**: Smart cache invalidation