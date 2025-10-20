# 🎯 Filter by JLPT/Grade Implementation Plan

**Feature:** Filter Progress Dashboard by JLPT Level (N1-N5) and School Grade (1-6)

**Priority:** 1 (Quick Win)  
**Estimated Time:** 2 hours

---

## Backend Requirements

### Current Status
✅ Kanji table already has `jlpt` and `grade` fields
✅ Progress endpoint exists: GET /kanji/progress

### Modifications Needed
Update progress endpoint to accept query parameters:

```typescript
// kanji.controller.ts
@Get('progress')
@ApiOperation({ summary: 'Get user kanji learning progress' })
@ApiQuery({ name: 'jlpt', required: false, enum: ['N1', 'N2', 'N3', 'N4', 'N5'] })
@ApiQuery({ name: 'grade', required: false, type: Number, minimum: 1, maximum: 6 })
async getProgress(
  @Req() req,
  @Query('jlpt') jlpt?: string,
  @Query('grade') grade?: string,
) {
  const userId = req.user?.id || 1;
  const gradeNum = grade ? parseInt(grade) : undefined;
  return this.kanjiService.getProgress(userId, { jlpt, grade: gradeNum });
}
```

```typescript
// kanji.service.ts
async getProgress(userId: number, filters?: { jlpt?: string; grade?: number }) {
  return this.repo.getProgress(userId, filters);
}
```

```typescript
// kanji.repo.ts
async getProgress(userId: number, filters?: { jlpt?: string; grade?: number }) {
  // Build where clause with filters
  const kanjiWhere: any = {};
  if (filters?.jlpt) {
    kanjiWhere.jlpt = filters.jlpt;
  }
  if (filters?.grade) {
    kanjiWhere.grade = filters.grade;
  }

  // Count kanji by status with filters
  const [newCount, learningCount, knownCount, masteredCount] = await Promise.all([
    this.dbClient.flashcardCard.count({
      where: {
        Deck: { user_id: userId },
        is_new: true,
        Kanji: kanjiWhere,
      },
    }),
    // ... similar for other statuses
  ]);

  return {
    newCount,
    learningCount,
    knownCount,
    masteredCount,
  };
}
```

---

## Flutter Implementation

### 1. Update ProgressBloc

**Add Events:**
```dart
// lib/features/kanji/presentation/bloc/progress_event.dart

class FilterProgressByJLPTEvent extends ProgressEvent {
  final String? jlptLevel; // 'N1', 'N2', etc. or null for all
  
  const FilterProgressByJLPTEvent(this.jlptLevel);
  
  @override
  List<Object?> get props => [jlptLevel];
}

class FilterProgressByGradeEvent extends ProgressEvent {
  final int? grade; // 1-6 or null for all
  
  const FilterProgressByGradeEvent(this.grade);
  
  @override
  List<Object?> get props => [grade];
}

class ClearProgressFiltersEvent extends ProgressEvent {
  const ClearProgressFiltersEvent();
  
  @override
  List<Object?> get props => [];
}
```

**Update State:**
```dart
// lib/features/kanji/presentation/bloc/progress_state.dart

class ProgressLoaded extends ProgressState {
  final ProgressSummary summary;
  final String? activeJLPTFilter;
  final int? activeGradeFilter;
  
  const ProgressLoaded({
    required this.summary,
    this.activeJLPTFilter,
    this.activeGradeFilter,
  });
  
  @override
  List<Object?> get props => [summary, activeJLPTFilter, activeGradeFilter];
}
```

**Update BLoC:**
```dart
// lib/features/kanji/presentation/bloc/progress_bloc.dart

on<FilterProgressByJLPTEvent>((event, emit) async {
  if (state is ProgressLoaded) {
    emit(ProgressLoading());
    
    final result = await getProgressUseCase(ProgressFilters(
      jlpt: event.jlptLevel,
      grade: (state as ProgressLoaded).activeGradeFilter,
    ));
    
    result.fold(
      (failure) => emit(ProgressError(message: failure.message)),
      (summary) => emit(ProgressLoaded(
        summary: summary,
        activeJLPTFilter: event.jlptLevel,
        activeGradeFilter: (state as ProgressLoaded).activeGradeFilter,
      )),
    );
  }
});

// Similar for FilterProgressByGradeEvent and ClearProgressFiltersEvent
```

### 2. Update UI (progress_dashboard_page.dart)

**Add Filter Chips:**
```dart
Widget _buildFilterSection(BuildContext context) {
  return Card(
    margin: const EdgeInsets.all(16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // JLPT Filter
          const Text('JLPT Level:', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                context,
                'All',
                isSelected: state.activeJLPTFilter == null,
                onTap: () {
                  context.read<ProgressBloc>().add(
                    const FilterProgressByJLPTEvent(null),
                  );
                },
              ),
              ...['N5', 'N4', 'N3', 'N2', 'N1'].map((level) {
                return _buildFilterChip(
                  context,
                  level,
                  isSelected: state.activeJLPTFilter == level,
                  onTap: () {
                    context.read<ProgressBloc>().add(
                      FilterProgressByJLPTEvent(level),
                    );
                  },
                );
              }),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Grade Filter
          const Text('School Grade:', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                context,
                'All',
                isSelected: state.activeGradeFilter == null,
                onTap: () {
                  context.read<ProgressBloc>().add(
                    const FilterProgressByGradeEvent(null),
                  );
                },
              ),
              ...[1, 2, 3, 4, 5, 6].map((grade) {
                return _buildFilterChip(
                  context,
                  'Grade $grade',
                  isSelected: state.activeGradeFilter == grade,
                  onTap: () {
                    context.read<ProgressBloc>().add(
                      FilterProgressByGradeEvent(grade),
                    );
                  },
                );
              }),
            ],
          ),
          
          if (state.activeJLPTFilter != null || state.activeGradeFilter != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
              onPressed: () {
                context.read<ProgressBloc>().add(
                  const ClearProgressFiltersEvent(),
                );
              },
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _buildFilterChip(
  BuildContext context,
  String label, {
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return FilterChip(
    label: Text(label),
    selected: isSelected,
    onSelected: (_) => onTap(),
    selectedColor: Colors.blue,
    backgroundColor: Colors.grey[800],
    labelStyle: TextStyle(
      color: isSelected ? Colors.white : Colors.grey[300],
    ),
  );
}
```

**Update Layout:**
```dart
// Insert filter section after summary card
if (state is ProgressLoaded) ...[
  _buildSummaryCard(state.summary),
  _buildFilterSection(context),  // NEW
  _buildProgressChart(state.summary),
  // ... rest of UI
]
```

### 3. Update Data Layer

**Update UseCase:**
```dart
// lib/features/kanji/domain/usecases/get_progress.dart

class ProgressFilters {
  final String? jlpt;
  final int? grade;
  
  const ProgressFilters({this.jlpt, this.grade});
}

class GetProgressUseCase implements UseCase<ProgressSummary, ProgressFilters> {
  final KanjiRepository repository;
  
  GetProgressUseCase(this.repository);
  
  @override
  Future<Either<Failure, ProgressSummary>> call(ProgressFilters filters) {
    return repository.getProgress(filters);
  }
}
```

**Update Repository:**
```dart
// lib/features/kanji/domain/repositories/kanji_repository.dart

abstract class KanjiRepository {
  Future<Either<Failure, ProgressSummary>> getProgress(ProgressFilters? filters);
}
```

**Update DataSource:**
```dart
// lib/features/kanji/data/datasources/kanji_remote_datasource.dart

Future<ProgressSummaryModel> getProgress({String? jlpt, int? grade}) async {
  final queryParams = <String, dynamic>{};
  if (jlpt != null) queryParams['jlpt'] = jlpt;
  if (grade != null) queryParams['grade'] = grade.toString();
  
  final response = await apiClient.get(
    Endpoints.kanjiProgress,
    queryParameters: queryParams,
  );
  
  final data = response.data['data'];
  return ProgressSummaryModel.fromJson(data);
}
```

---

## UI Mockup

```
┌─────────────────────────────────────┐
│      Progress Summary Card          │
│  ┌──────┐  ┌──────┐  ┌──────┐      │
│  │  50  │  │  30  │  │  20  │      │
│  │  New │  │Learn.│  │ Known│      │
│  └──────┘  └──────┘  └──────┘      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  Filter Progress                     │
│                                      │
│  JLPT Level:                         │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐│
│  │All │ │ N5 │ │ N4 │ │ N3 │ │ N2 ││
│  └────┘ └────┘ └────┘ └────┘ └────┘│
│  ┌────┐                              │
│  │ N1 │                              │
│  └────┘                              │
│                                      │
│  School Grade:                       │
│  ┌────┐ ┌───────┐ ┌───────┐ ┌──────┐│
│  │All │ │Grade 1│ │Grade 2│ │Grade3││
│  └────┘ └───────┘ └───────┘ └──────┘│
│  ┌───────┐ ┌───────┐ ┌───────┐      │
│  │Grade 4│ │Grade 5│ │Grade 6│      │
│  └───────┘ └───────┘ └───────┘      │
│                                      │
│  [Clear Filters]                     │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│      Progress Chart                  │
│      (filtered data)                 │
└─────────────────────────────────────┘
```

---

## Implementation Steps

1. **Backend (15 min)**
   - [ ] Update kanji.controller.ts with @ApiQuery decorators
   - [ ] Update kanji.service.ts to accept filters
   - [ ] Update kanji.repo.ts to build filtered queries
   - [ ] Test with Postman/Swagger

2. **Flutter Domain (15 min)**
   - [ ] Create ProgressFilters class
   - [ ] Update GetProgressUseCase
   - [ ] Update KanjiRepository interface

3. **Flutter Data (15 min)**
   - [ ] Update kanji_remote_datasource.dart
   - [ ] Update kanji_repository_impl.dart

4. **Flutter Presentation (45 min)**
   - [ ] Add new events to progress_event.dart
   - [ ] Update ProgressLoaded state
   - [ ] Update progress_bloc.dart with event handlers
   - [ ] Create _buildFilterSection widget
   - [ ] Create _buildFilterChip widget
   - [ ] Update progress_dashboard_page.dart layout

5. **Testing (30 min)**
   - [ ] Test filter by each JLPT level
   - [ ] Test filter by each grade
   - [ ] Test combined filters (JLPT + Grade)
   - [ ] Test clear filters
   - [ ] Verify API calls
   - [ ] Check UI responsiveness

---

## Success Criteria

- [ ] User can filter by JLPT level (N1-N5)
- [ ] User can filter by Grade (1-6)
- [ ] Filters can be combined (e.g., N3 + Grade 4)
- [ ] "Clear Filters" resets to show all kanji
- [ ] Selected filters are visually highlighted
- [ ] Progress summary updates when filters change
- [ ] API calls include correct query parameters
- [ ] No "coming soon" messages

---

**Status:** Ready to implement  
**Next:** Start with backend modifications
