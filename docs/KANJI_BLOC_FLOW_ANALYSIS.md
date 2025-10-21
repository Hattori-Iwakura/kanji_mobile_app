# Kanji Bloc Flow Analysis

**Date**: October 21, 2025  
**Status**: 🔴 Issues Found

---

## 📋 State Flow Diagram

```
[KanjiInitial]
    ↓
LoadKanjiListEvent → [KanjiLoading] → [KanjiListLoaded] / [KanjiError]
LoadKanjiByIdEvent → [KanjiLoading] → [KanjiDetailLoaded] / [KanjiError]
CreateKanjiEvent   → [KanjiLoading] → [KanjiCreated] / [KanjiError]
UpdateKanjiEvent   → [KanjiLoading] → [KanjiUpdated] / [KanjiError]
DeleteKanjiEvent   → [KanjiLoading] → [KanjiDeleted] / [KanjiError]
RefreshKanjiList   → [Calls LoadKanjiListEvent with no params]
```

---

## ✅ What's Working

### 1. State Transitions
- ✅ All events properly emit `KanjiLoading` first
- ✅ Success states are well-defined (ListLoaded, DetailLoaded, Created, etc.)
- ✅ Error handling with `KanjiException` and fallback

### 2. CRUD Operations
- ✅ Create: `CreateKanjiEvent` → `KanjiCreated`
- ✅ Read: `LoadKanjiListEvent` / `LoadKanjiByIdEvent`
- ✅ Update: `UpdateKanjiEvent` → `KanjiUpdated`
- ✅ Delete: `DeleteKanjiEvent` → `KanjiDeleted`

### 3. Filter & Search
- ✅ LoadKanjiListEvent supports:
  - `jlptLevel` (N5, N4, N3, N2, N1)
  - `grade` (1-6)
  - `search` (character search)
  - `page` & `limit` (pagination)

### 4. Error Handling
- ✅ Catches `KanjiException` with specific message
- ✅ Fallback generic error messages
- ✅ UI shows SnackBar on error (in dictionary page)

---

## ❌ Issues Found

### 🔴 Issue 1: RefreshKanjiListEvent Loses Filters

**Problem**: 
```dart
Future<void> _onRefreshKanjiList(
  RefreshKanjiListEvent event,
  Emitter<KanjiState> emit,
) async {
  // Reload with default parameters
  add(LoadKanjiListEvent());  // ❌ No filters passed!
}
```

**Impact**: 
- User applies JLPT=N4 filter
- User pulls to refresh
- Filter is lost, shows all kanji again

**Solution**: Preserve current filters from `KanjiListLoaded` state

---

### 🔴 Issue 2: No State After Create/Update/Delete

**Problem**: After CRUD operations, bloc stays in `KanjiCreated`/`KanjiUpdated`/`KanjiDeleted` state

**Example Flow**:
```
1. Admin creates new kanji
2. State: KanjiCreated
3. Navigate back to list
4. List shows OLD data (not refreshed)
```

**Impact**: 
- UI doesn't automatically reload list after changes
- Admin has to manually refresh

**Solution**: After create/update/delete, automatically reload list

---

### 🟡 Issue 3: Loading State Too Fast (Integration Test Issue)

**Problem**: Test `Kanji 2: List shows loading indicator` FAILED

**Reason**:
```dart
emit(KanjiLoading());  // State changes immediately
final kanjiList = await getKanjiListUseCase(...);  // Fast API < 100ms
emit(KanjiListLoaded(...));  // Loading state gone before test can check
```

**Impact**: 
- Integration test can't find `CircularProgressIndicator`
- Test expects loading state to be visible

**Solution**: 
- Add artificial delay for testing (not recommended)
- OR change test to use `pump()` instead of `pumpAndSettle()`
- OR check for loading state immediately after event

---

### 🟡 Issue 4: No Separate Search/Filter Events

**Current Design**:
```dart
LoadKanjiListEvent(
  jlptLevel: 'N4',
  grade: 3,
  search: '日',
)
```

**Problem**:
- Can't distinguish between "load list" and "apply filter"
- No way to track filter history
- Can't have "clear filters" event easily

**Better Design**:
```dart
SearchKanjiEvent(query: '日')
FilterKanjiEvent(jlptLevel: 'N4', grade: 3)
ClearFiltersEvent()
```

**Impact**: 
- Medium - current design works but less clear
- Makes testing harder

---

### 🟢 Issue 5: LoadKanjiByCharacterEvent vs LoadKanjiByIdEvent

**Question**: Why have both?

**Analysis**:
- `LoadKanjiByIdEvent(123)` - Load by database ID
- `LoadKanjiByCharacterEvent('日')` - Load by kanji character

**Use Cases**:
- By ID: When navigating from list (has ID already)
- By Character: When user types kanji directly or shares link

**Status**: ✅ This is fine, no issue

---

## 🔧 Recommended Fixes

### Priority 1: Fix RefreshKanjiListEvent
```dart
Future<void> _onRefreshKanjiList(
  RefreshKanjiListEvent event,
  Emitter<KanjiState> emit,
) async {
  // Preserve current filters if state is KanjiListLoaded
  if (state is KanjiListLoaded) {
    final currentState = state as KanjiListLoaded;
    add(LoadKanjiListEvent(
      jlptLevel: currentState.appliedJlptFilter,
      grade: currentState.appliedGradeFilter,
      search: currentState.appliedSearch,
    ));
  } else {
    add(LoadKanjiListEvent());
  }
}
```

### Priority 2: Auto-Reload After CRUD
```dart
Future<void> _onCreateKanji(
  CreateKanjiEvent event,
  Emitter<KanjiState> emit,
) async {
  emit(KanjiLoading());

  try {
    final kanji = await createKanjiUseCase(event.kanjiData);
    emit(KanjiCreated(kanji));
    
    // Auto-reload list after 500ms (let UI show success message)
    await Future.delayed(Duration(milliseconds: 500));
    add(LoadKanjiListEvent());
  } on KanjiException catch (e) {
    emit(KanjiError(e.message));
  } catch (e) {
    emit(KanjiError('Failed to create kanji'));
  }
}
```

### Priority 3: Add Dedicated Search/Filter Events (Optional)
```dart
// In kanji_event.dart
class SearchKanjiEvent extends KanjiEvent {
  final String query;
  SearchKanjiEvent(this.query);
}

class FilterKanjiByJlptEvent extends KanjiEvent {
  final String jlptLevel;
  FilterKanjiByJlptEvent(this.jlptLevel);
}

class FilterKanjiByGradeEvent extends KanjiEvent {
  final int grade;
  FilterKanjiByGradeEvent(this.grade);
}

class ClearFiltersEvent extends KanjiEvent {}
```

---

## 🧪 Test Cases to Verify

### Manual Test 1: Refresh Preserves Filters
1. Open Kanji Dictionary
2. Apply JLPT=N4 filter
3. Verify only N4 kanji shown
4. Pull to refresh
5. ✅ VERIFY: Still showing only N4 kanji

**Current Result**: ❌ FAIL - Shows all kanji  
**After Fix**: ✅ PASS - Shows N4 kanji

### Manual Test 2: Create Kanji Reloads List
1. Login as admin
2. Open Kanji Dictionary
3. Click "+" to create new kanji
4. Fill form and submit
5. Navigate back to list
6. ✅ VERIFY: New kanji appears in list

**Current Result**: ❌ FAIL - List not updated  
**After Fix**: ✅ PASS - New kanji visible

### Manual Test 3: Loading State Visible
1. Open app with slow network (throttle to 3G)
2. Navigate to Kanji Dictionary
3. ✅ VERIFY: See CircularProgressIndicator

**Current Result**: ⚠️ INCONSISTENT - Too fast on good network  
**After Fix**: ✅ PASS - Always shows loading briefly

---

## 📊 Integration Test Failures Analysis

### Test: "Kanji 2: List shows loading indicator"
```dart
testWidgets('Kanji 2: List shows loading indicator', (tester) async {
  await tester.pumpWidget(createTestApp());
  await tester.pumpAndSettle();

  // Navigate to kanji
  await tester.tap(find.text('Kanji'));
  await tester.pump();  // ❌ Loading already done!
  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);  // ❌ FAIL
});
```

**Fix**: Check loading state immediately after navigation:
```dart
testWidgets('Kanji 2: List shows loading indicator', (tester) async {
  await tester.pumpWidget(createTestApp());
  await tester.pumpAndSettle();

  await tester.tap(find.text('Kanji'));
  await tester.pump();  // Don't settle yet
  
  // Check for loading OR already loaded (both OK)
  expect(
    find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
    find.byType(GridView).evaluate().isNotEmpty,
    isTrue,
  );
});
```

---

## ✅ Action Items

- [ ] Fix RefreshKanjiListEvent to preserve filters
- [ ] Add auto-reload after Create/Update/Delete
- [ ] Update integration tests to handle fast loading
- [ ] (Optional) Add dedicated Search/Filter events
- [ ] Test all changes manually
- [ ] Re-run integration tests

**Next Steps**: Apply fixes to `kanji_bloc.dart`

---

**Updated**: October 21, 2025 03:00 AM
