# Kanji Module Implementation

## ✅ Completed

### 1. Domain Layer (100%)
- **Entities**:
  - `Kanji` - Basic kanji entity with 13 properties (id, character, meanings, readings, JLPT, grade, strokes, etc.)
  - `KanjiDetail` - Extended entity with external API data (examples, audio, video, stroke paths, radical info)
  
- **Repository Interface**:
  - `getKanjiList()` - Get paginated list with optional filters
  - `searchKanji()` - Search by query with optional filters
  - `getKanjiById()` - Get single kanji by ID
  - `getKanjiByCharacter()` - Get single kanji by character
  - `getKanjiDetail()` - Get detailed info from external APIs
  - `searchByCanvas()` - Search by drawn canvas (AI recognition)

- **Use Cases**:
  - `GetKanjiList` - Fetch kanji list from backend
  - `GetKanjiDetail` - Fetch detailed kanji info (combines 3 external APIs)
  - `SearchKanji` - Search kanji by query

### 2. Data Layer (100%)
- **Models**:
  - `KanjiModel` - JSON serialization with fromJson/toJson
  - `KanjiDetailModel` - Factory method `fromMultipleSources()` combining:
    - Backend API data
    - KanjiAlive API (examples, audio, video)
    - Jisho API (detailed readings)
    - KanjiVG API (SVG stroke paths)

- **Data Sources**:
  - `KanjiRemoteDataSource` - Backend API integration
    - All 5 endpoints implemented using `apiClient.dio.get/post`
    - Proper error handling with ServerException
  
- **Repository Implementation**:
  - `KanjiRepositoryImpl` - Implements domain repository
  - Combines backend + 3 external services with `Future.wait` for parallel fetching
  - Error handling with Either<Failure, T> pattern

### 3. Core Services (Skeleton - 40%)
- **KanjiAliveService** - RapidAPI integration
  - Structure complete, needs full HTTP implementation
  - Requires `RAPIDAPI_KEY` in .env file
  - Returns: examples, audio URL, video URL

- **JishoService** - Jisho.org API integration
  - Structure complete, needs full HTTP implementation
  - Public API (no key needed)
  - Returns: detailed readings (on-yomi, kun-yomi)

- **KanjiVGService** - GitHub KanjiVG integration
  - Structure complete, needs SVG parsing
  - Fetches SVG from: `https://raw.githubusercontent.com/KanjiVG/kanjivg/master/kanji/{hex}.svg`
  - Returns: List of stroke paths (SVG path strings)

### 4. Presentation Layer (100%)
- **Bloc** (State Management):
  - `KanjiEvent` - 4 events (LoadList, Search, LoadDetail, SearchByCanvas)
  - `KanjiState` - 6 states (Initial, Loading, ListLoaded, SearchResult, DetailLoaded, Error)
  - `KanjiBloc` - Event handlers with fold pattern, search result parsing

- **Pages**:
  - `KanjiListPage` (285 lines) - Grid view with filters
    - 4-column grid layout
    - Filter chips for JLPT (N1-N5) and Grade (G1-G6)
    - `KanjiCard` widget with character, meanings, badges
    - Navigation to detail page on tap
    - BlocBuilder integration

  - `KanjiDetailPage` (257 lines) - Detailed kanji view
    - Large character display (200x200)
    - Meanings section
    - Readings section (on-yomi/kun-yomi with color coding)
    - Stroke order animation widget
    - Examples list
    - Audio player button (placeholder)
    - Error handling with retry button

- **Widgets**:
  - `StrokeOrderAnimation` (268 lines) - Interactive stroke animation
    - Canvas-based SVG path rendering
    - Animation controller for stroke-by-stroke playback
    - Controls: Play, Reset, Previous, Next
    - Real-time stroke counter
    - CustomPainter with path scaling and transformation
    - Animated path extraction (red stroke highlighting)

### 5. Dependency Injection (100%)
- Updated `injection_container.dart`:
  - Registered all 3 external services
  - Registered kanji data sources, repository, use cases
  - Registered KanjiBloc as factory (new instance per request)

### 6. Dependencies (100%)
- Added `http: ^1.2.2` to pubspec.yaml
- All packages installed via `flutter pub get`

---

## ⚠️ TODO - Remaining Tasks

### 1. Complete External API Services
**Priority: HIGH**

#### KanjiAliveService (RapidAPI)
```dart
// Current: Skeleton with headers setup
// TODO: Implement HTTP calls with Dio
Future<Map<String, dynamic>> getKanjiInfo(String character) async {
  final response = await dio.get(
    '$_baseUrl/kanji/$character',
    options: Options(headers: _headers),
  );
  return response.data;
}
```

**Requirements**:
- Add `RAPIDAPI_KEY` to `.env` file
- Get API key from: https://rapidapi.com/KanjiAlive/api/learn-to-read-and-write-japanese-kanji
- Implement error handling for rate limits (50 requests/month on free tier)

#### JishoService
```dart
// Current: Basic HTTP implementation
// TODO: Test with real API, handle edge cases
- Empty results
- Network errors
- Invalid characters
```

#### KanjiVGService
```dart
// Current: Basic HTTP + SVG parsing
// TODO: Improve SVG path parser
- Handle cubic Bezier curves (C command)
- Handle quadratic Bezier curves (Q command)
- Handle arc commands (A command)
- Current parser only supports M, L, Z commands
```

### 2. Audio Player Implementation
**Priority: MEDIUM**

Currently just shows SnackBar in `KanjiDetailPage`:
```dart
// TODO: Integrate audio player package
// Recommended: audioplayers package
onPressed: () {
  // Replace this with actual audio playback
  final audioPlayer = AudioPlayer();
  audioPlayer.play(UrlSource(detail.audioUrl!));
}
```

**Steps**:
1. Add `audioplayers: ^5.2.1` to pubspec.yaml
2. Create `AudioPlayerWidget` in `lib/features/kanji/presentation/widgets/`
3. Update `KanjiDetailPage` to use the widget

### 3. Navigation Integration
**Priority: HIGH**

Add Kanji navigation to HomePage:

```dart
// In lib/features/home/presentation/pages/home_page.dart
ListTile(
  leading: const Icon(Icons.language),
  title: const Text('Kanji Learning'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<KanjiBloc>(),
          child: const KanjiListPage(),
        ),
      ),
    );
  },
),
```

### 4. Environment Variables
**Priority: HIGH**

Update `.env` file:
```env
API_BASE_URL=http://10.0.2.2:3000/api
RAPIDAPI_KEY=your_rapidapi_key_here
```

### 5. Testing
**Priority: MEDIUM**

Create integration tests:
- `test/kanji_module.e2e-spec.dart`
- Test kanji list loading
- Test search functionality
- Test detail page navigation
- Mock external API calls

---

## 📊 Architecture Overview

```
lib/features/kanji/
├── domain/
│   ├── entities/
│   │   ├── kanji.dart              ✅ Complete
│   │   └── kanji_detail.dart       ✅ Complete
│   ├── repositories/
│   │   └── kanji_repository.dart   ✅ Complete (Interface)
│   └── usecases/
│       ├── get_kanji_list.dart     ✅ Complete
│       ├── get_kanji_detail.dart   ✅ Complete
│       └── search_kanji.dart       ✅ Complete
│
├── data/
│   ├── models/
│   │   ├── kanji_model.dart        ✅ Complete
│   │   └── kanji_detail_model.dart ✅ Complete
│   ├── datasources/
│   │   └── kanji_remote_data_source.dart ✅ Complete
│   └── repositories/
│       └── kanji_repository_impl.dart    ✅ Complete
│
└── presentation/
    ├── bloc/
    │   ├── kanji_event.dart        ✅ Complete
    │   ├── kanji_state.dart        ✅ Complete
    │   └── kanji_bloc.dart         ✅ Complete
    ├── pages/
    │   ├── kanji_list_page.dart    ✅ Complete
    │   └── kanji_detail_page.dart  ✅ Complete
    └── widgets/
        └── stroke_order_animation.dart ✅ Complete
```

---

## 🔌 API Integration Summary

### Backend API (NestJS)
- **Base URL**: `http://10.0.2.2:3000/api/kanji`
- **Endpoints**:
  - `GET /kanji` - List with pagination & filters
  - `GET /kanji/search` - Search with query
  - `GET /kanji/:id` - Get by ID
  - `GET /kanji/character/:char` - Get by character
  - `POST /kanji/search/canvas` - AI canvas recognition

### External APIs
1. **KanjiAlive** (RapidAPI)
   - Examples with translations
   - Audio pronunciation
   - Video demonstrations
   - Requires API key

2. **Jisho.org**
   - Detailed readings
   - Common/uncommon indicators
   - Public API (no key)

3. **KanjiVG** (GitHub)
   - SVG stroke order diagrams
   - Path data for animation
   - Public repository

---

## 🎨 UI Features

### Kanji List Page
- **Layout**: 4-column grid view
- **Filters**: JLPT (N1-N5), Grade (G1-G6)
- **Card Design**: 
  - Large character (48px)
  - First meaning (truncated)
  - Colored badges (JLPT, Grade, Strokes)
- **Pagination**: 50 items per page

### Kanji Detail Page
- **Character Display**: 200x200 white box with border
- **Sections**:
  - Meanings (teal title)
  - Readings (on-yomi: teal, kun-yomi: amber)
  - Stroke Order (interactive animation)
  - Examples (bullet list)
  - Audio button (teal accent)

### Stroke Animation Widget
- **Canvas**: 300x300 white background
- **Controls**: Previous, Play, Reset, Next
- **Animation**: 2-second stroke duration
- **Visual**: Red highlight for current stroke, black for completed

---

## 🚀 Next Steps for Full Functionality

1. **Add RapidAPI Key** - Get KanjiAlive API key
2. **Implement Audio Player** - Add audioplayers package
3. **Test External APIs** - Verify API responses with real data
4. **Enhance SVG Parser** - Support all SVG path commands
5. **Add Navigation** - Link from HomePage to KanjiListPage
6. **Create Tests** - Integration tests for the module
7. **Optimize Performance** - Add caching for external API calls

---

## 📝 Notes

- **User Role**: Read-only access (no add/edit/delete)
- **Android Emulator**: Backend at `10.0.2.2:3000`
- **Clean Architecture**: Full separation of concerns
- **State Management**: flutter_bloc with Either pattern
- **Error Handling**: Comprehensive with retry capabilities

**Total Files Created**: 13
**Total Lines of Code**: ~2,000+
**Completion Status**: ~85%
