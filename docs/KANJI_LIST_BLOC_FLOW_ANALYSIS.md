# Kanji List Bloc Flow Analysis

**Date**: October 21, 2025  
**Status**: 🔴 Critical Issues Found

---

## 📋 State Flow Diagram

```
[KanjiListInitial]
    ↓
LoadAllListsEvent     → [KanjiListLoading] → [ListsLoaded] / [KanjiListError]
LoadListByIdEvent     → [KanjiListLoading] → [ListDetailLoaded] / [KanjiListError]
CreateListEvent       → [KanjiListLoading] → [ListCreated] / [KanjiListError]
UpdateListEvent       → [KanjiListLoading] → [ListUpdated] / [KanjiListError]
DeleteListEvent       → [KanjiListLoading] → [ListDeleted] / [KanjiListError]
AddKanjiToListEvent   → [KanjiListLoading] → [KanjiAddedToList] / [KanjiListError]
RemoveKanjiFromList   → [KanjiListLoading] → [KanjiRemovedFromList] / [KanjiListError]
RefreshListsEvent     → [KanjiListLoading] → [ListsLoaded] / [KanjiListError]
```

---

## ✅ What's Working

### 1. Comprehensive CRUD Operations
- ✅ Create: `CreateListEvent` with `categoryId` support
- ✅ Read: `LoadAllListsEvent` with search/filter
- ✅ Update: `UpdateListEvent` with `categoryId` support
- ✅ Delete: `DeleteListEvent`

### 2. Kanji Management
- ✅ Add kanji to list: `AddKanjiToListEvent`
- ✅ Remove kanji from list: `RemoveKanjiFromListEvent`

### 3. Publish/Approval System
- ✅ Request publish: `RequestPublishListEvent`
- ✅ Load publish requests: `LoadPublishRequestsEvent`
- ✅ Approve: `ApprovePublishRequestEvent`
- ✅ Reject: `RejectPublishRequestEvent`

### 4. Filter & Search
- ✅ LoadAllListsEvent supports:
  - `search` (text search)
  - `type` (filter by type)
  - `limit` & `offset` (pagination)

### 5. Category Integration
- ✅ `CreateListEvent` has `categoryId` parameter
- ✅ `UpdateListEvent` has `categoryId` parameter
- ✅ Category properly integrated in events

---

## ❌ Critical Issues Found

### 🔴 Issue 1: RefreshListsEvent Loses All Filters

**Problem**: 
```dart
Future<void> _onRefreshLists(
  RefreshListsEvent event,
  Emitter<KanjiListState> emit,
) async {
  emit(KanjiListLoading());
  try {
    final lists = await getAllListsUseCase();  // ❌ No filters!
    emit(ListsLoaded(lists: lists));
  } catch (e) {
    emit(KanjiListError('Failed to refresh lists'));
  }
}
```

**Impact**: 
- User applies search filter "JLPT N5"
- User pulls to refresh
- All filters lost, shows all lists
- **This is the bug user reported: "bloc flow của kanji list còn lỗi"**

**Solution**: Preserve filters from current `ListsLoaded` state

---

### 🔴 Issue 2: No Auto-Reload After CRUD Operations

**Problem**: After create/update/delete, bloc stays in `ListCreated`/`ListUpdated`/`ListDeleted` state

**Example Flow**:
```
1. User creates new list
2. State: ListCreated
3. Navigate back
4. List page shows OLD data (not refreshed)
5. User must manually pull to refresh
```

**Impact**: 
- **This is the bug user reported!**
- UI doesn't show newly created list
- Changes to existing list not visible
- Deleted list still appears

**Solution**: Auto-reload lists after CRUD operations

---

### 🔴 Issue 3: No Auto-Reload After Add/Remove Kanji

**Problem**: After adding/removing kanji, states are:
```dart
emit(KanjiAddedToList());     // ❌ Just a marker state
emit(KanjiRemovedFromList()); // ❌ Just a marker state
```

**Impact**:
- Add kanji to list → list detail not updated
- Remove kanji → still shows in list detail
- User must manually refresh to see changes

**Solution**: Reload list detail after kanji operations

---

### 🔴 Issue 4: RefreshListsEvent Applied Filters Not Preserved

**Problem**: `ListsLoaded` state stores applied filters but refresh doesn't use them:
```dart
ListsLoaded({
  required this.lists,
  this.appliedSearch,      // ✅ Stored
  this.appliedType,        // ✅ Stored
  this.appliedLimit,       // ✅ Stored
  this.appliedOffset,      // ✅ Stored
});

// But refresh doesn't use them! ❌
Future<void> _onRefreshLists(...) {
  final lists = await getAllListsUseCase();  // No params!
}
```

**Impact**: Same as Issue 1 - filters lost on refresh

---

### 🟡 Issue 5: Category Not Shown in ListsLoaded

**Problem**: `ListsLoaded` state doesn't track applied category filter

**Current State**:
```dart
ListsLoaded({
  required this.lists,
  this.appliedSearch,
  this.appliedType,
  // ❌ Missing: this.appliedCategory
});
```

**Impact**: 
- Can't track which category filter is active
- Can't preserve category filter on refresh

**Solution**: Add `appliedCategoryId` to `ListsLoaded` state

---

### 🟡 Issue 6: No Detail State After Add/Remove Kanji

**Problem**: After adding kanji to list:
```dart
emit(KanjiAddedToList());  // State is just a marker
```

**Better Approach**:
```dart
final updatedList = await getListByIdUseCase(event.listId);
emit(ListDetailLoaded(updatedList));  // Show updated list
```

**Impact**: 
- List detail page shows stale data
- Kanji count doesn't update immediately

---

## 🔧 Recommended Fixes

### Priority 1: Fix RefreshListsEvent to Preserve Filters
```dart
Future<void> _onRefreshLists(
  RefreshListsEvent event,
  Emitter<KanjiListState> emit,
) async {
  // Preserve current filters if state is ListsLoaded
  if (state is ListsLoaded) {
    final currentState = state as ListsLoaded;
    add(LoadAllListsEvent(
      search: currentState.appliedSearch,
      type: currentState.appliedType,
      limit: currentState.appliedLimit,
      offset: currentState.appliedOffset,
    ));
  } else {
    add(LoadAllListsEvent());
  }
}
```

### Priority 2: Auto-Reload After Create/Update/Delete
```dart
Future<void> _onCreateList(
  CreateListEvent event,
  Emitter<KanjiListState> emit,
) async {
  emit(KanjiListLoading());
  try {
    final list = await createListUseCase(
      name: event.name,
      description: event.description,
      kanjiIds: event.kanjiIds,
      categoryId: event.categoryId,
    );
    emit(ListCreated(list));
    
    // Auto-reload lists after short delay
    await Future.delayed(const Duration(milliseconds: 500));
    add(LoadAllListsEvent());
  } on KanjiListException catch (e) {
    emit(KanjiListError(e.message));
  } catch (e) {
    emit(KanjiListError('Failed to create list'));
  }
}

// Same for UpdateListEvent and DeleteListEvent
```

### Priority 3: Auto-Reload Detail After Add/Remove Kanji
```dart
Future<void> _onAddKanjiToList(
  AddKanjiToListEvent event,
  Emitter<KanjiListState> emit,
) async {
  emit(KanjiListLoading());
  try {
    await addKanjiToListUseCase(
      listId: event.listId,
      kanjiId: event.kanjiId,
    );
    emit(KanjiAddedToList());
    
    // Reload list detail to show updated kanji count
    await Future.delayed(const Duration(milliseconds: 300));
    add(LoadListByIdEvent(event.listId));
  } on KanjiListException catch (e) {
    emit(KanjiListError(e.message));
  } catch (e) {
    emit(KanjiListError('Failed to add kanji to list'));
  }
}

// Same for RemoveKanjiFromListEvent
```

### Priority 4: Add Category Filter Support
```dart
// In kanji_list_event.dart
class LoadAllListsEvent extends KanjiListEvent {
  final String? search;
  final String? type;
  final int? categoryId;  // ✅ Add this
  final int? limit;
  final int? offset;

  LoadAllListsEvent({
    this.search,
    this.type,
    this.categoryId,  // ✅ Add this
    this.limit,
    this.offset,
  });
}

// In kanji_list_state.dart
class ListsLoaded extends KanjiListState {
  final List<KanjiListEntity> lists;
  final String? appliedSearch;
  final String? appliedType;
  final int? appliedCategoryId;  // ✅ Add this
  final int? appliedLimit;
  final int? appliedOffset;

  ListsLoaded({
    required this.lists,
    this.appliedSearch,
    this.appliedType,
    this.appliedCategoryId,  // ✅ Add this
    this.appliedLimit,
    this.appliedOffset,
  });
}
```

---

## 🧪 Test Cases to Verify

### Manual Test 1: Refresh Preserves Filters
1. Open Kanji Lists page
2. Apply search filter: "JLPT"
3. Verify filtered results
4. Pull to refresh
5. ✅ VERIFY: Still showing filtered results

**Current Result**: ❌ FAIL - All lists shown  
**After Fix**: ✅ PASS - Filtered lists shown

### Manual Test 2: Create List Auto-Reloads
1. Open Kanji Lists page
2. Click "Create List" button
3. Fill name: "Test List", select category
4. Submit form
5. ✅ VERIFY: New list appears immediately in list

**Current Result**: ❌ FAIL - Must manually refresh  
**After Fix**: ✅ PASS - New list visible

### Manual Test 3: Category Filter Works
1. Open Kanji Lists page
2. Filter by category: "JLPT N5"
3. ✅ VERIFY: Only N5 lists shown
4. Pull to refresh
5. ✅ VERIFY: Still showing only N5 lists

**Current Result**: ❌ FAIL - Category filter not implemented  
**After Fix**: ✅ PASS - Category filter working

### Manual Test 4: Add Kanji Updates Detail
1. Open a list detail page
2. Note kanji count: e.g., "5 kanji"
3. Click "Add Kanji" button
4. Select a kanji and confirm
5. ✅ VERIFY: Count updates to "6 kanji" immediately

**Current Result**: ❌ FAIL - Count stays "5 kanji"  
**After Fix**: ✅ PASS - Count updates to "6 kanji"

---

## 📊 Integration Test Failures Analysis

### Test: "List 2: Shows loading while fetching lists"
**Status**: ❌ FAILED

**Reason**: Same as Kanji bloc - loading state too fast

### Test: "List 3: Displays user lists"
**Status**: ❌ FAILED (test hung at login)

**Reason**: Authentication loop issue, not bloc issue

### Test: "Create 10-14: Category tests"
**Status**: ⚠️ NOT TESTED

**Expected Issues**:
- Category dropdown may not load
- Category not shown on list card
- Category filter not working

---

## ✅ Action Items

- [ ] Fix RefreshListsEvent to preserve filters
- [ ] Add auto-reload after Create/Update/Delete
- [ ] Add auto-reload after Add/Remove Kanji
- [ ] Add category filter to LoadAllListsEvent
- [ ] Add appliedCategoryId to ListsLoaded state
- [ ] Update use case to support category filter
- [ ] Test all changes manually
- [ ] Re-run integration tests

**Next Steps**: Apply fixes to `kanji_list_bloc.dart`

---

**Updated**: October 21, 2025 03:15 AM
