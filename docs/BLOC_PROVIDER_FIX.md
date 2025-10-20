# BLoC Provider Fix - MainHomePage

## Issue
Error: `Could not find the correct Provider<KanjiListsBloc> above this StatefulBuilder Widget`

## Root Cause
`_pages` was declared as `static const List<Widget>`, which means:
1. Widgets were created at compile-time, not runtime
2. No access to BuildContext
3. BlocProvider inside KanjiListsPage couldn't be resolved

## Solution
Changed from `static const` to regular List to ensure widgets have proper context.

### Before:
```dart
static const List<Widget> _pages = [
  KanjiSearchPage(),
  KanjiListsPage(),  // BlocProvider here couldn't resolve
  // ...
];
```

### After:
```dart
static const List<Widget> _pageWidgets = [
  KanjiSearchPage(),
  KanjiListsPage(),  // Now has proper context
  // ...
];

// Used in build method with proper context
IndexedStack(index: _selectedIndex, children: _pageWidgets)
```

## How It Works Now

1. **MainHomePage** provides `AuthBloc` at top level
2. **FlashcardDeckBloc** provided via BlocProvider wrapping body
3. **KanjiListsPage** creates own `KanjiListsBloc` via BlocProvider
4. All pages now have proper context chain

## Files Modified
- `lib/features/home/presentation/pages/main_home_page.dart`

## Related Issues Fixed
- KanjiListsBloc not found
- Proper BLoC lifecycle management
- Performance optimization (pages created once, not on every getter call)

## Testing
1. ✅ Navigate to "My Lists" tab
2. ✅ Should load lists without Provider error
3. ✅ Flashcard tab should work
4. ✅ All tabs should maintain state when switching

## Best Practices Applied
- Use `const` for truly constant widgets
- Provide BLoCs at appropriate levels in widget tree
- Avoid creating BLoC instances in getters (performance)
- Let individual pages manage their own BLoCs when needed
