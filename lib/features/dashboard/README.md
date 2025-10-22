# Dashboard/Home Feature

## 📱 Overview

The Dashboard feature provides the main navigation hub for the Kanji Master app with:
- **Bottom Navigation Bar**: Quick access to 5 main sections
- **Drawer Menu**: Complete app navigation with all features
- **Home Tab**: Welcome screen with quick actions and learning stats

## 🎨 Components

### HomePage (`presentation/pages/home_page.dart`)
Main container with:
- **AppBar**: Title, notifications, settings icons
- **Drawer**: Side navigation menu with all features
- **Bottom Navigation**: 5 tabs (Kanji, Search, Flashcards, Quiz, Profile)
- **Body**: Content area displaying selected tab

### Bottom Navigation Tabs

1. **Kanji Tab** (Index 0)
   - Welcome card with gradient
   - Quick actions: Browse Kanji, AI Recognition
   - Learning stats: Day Streak, Learned Count, Quiz Score

2. **Search Tab** (Index 1)
   - Coming soon placeholder
   - Will integrate CNN model for kanji drawing recognition

3. **Flashcards Tab** (Index 2)
   - Coming soon placeholder
   - Will show flashcard decks and study sessions

4. **Quiz Tab** (Index 3)
   - Coming soon placeholder
   - Will display available quizzes and history

5. **Profile Tab** (Index 4)
   - User avatar and info
   - Menu items: Edit Profile, Learning History, Achievements, Settings, Help
   - Logout button with confirmation dialog

## 📂 Navigation Menu (Drawer)

### Main Features
- 🏠 **Home** - Return to home tab
- 📚 **Kanji Dictionary** - Browse all kanji (navigates to KanjiListPage)
- 🔍 **Search Kanji** - Switch to search tab
- 🎴 **Flashcards** - Switch to flashcards tab
- 🧠 **Quiz** - Switch to quiz tab
- 📋 **Kanji Lists** - Custom kanji collections (coming soon)
- 🌐 **Translation** - JP↔VI↔EN translation (coming soon)

### Settings & Account
- 👤 **Profile** - View/edit user profile
- ⚙️ **Settings** - App preferences (coming soon)
- ❓ **Help & Support** - Help documentation (coming soon)
- 🚪 **Logout** - Sign out with confirmation

## 🎨 Design Features

### Dark Theme
- Black background (#000000)
- White text (#FFFFFF)
- Gradient header (Primary → Secondary colors)
- Semi-transparent cards (white opacity 0.05)

### Animations
- Smooth tab transitions
- Drawer slide-in animation
- Bottom navigation item highlighting

### Responsive UI
- Material 3 design
- Bottom navigation type: fixed (5 items)
- Proper padding and spacing
- Icon size consistency

## 🔄 State Management

Currently uses local state (`setState`) for:
- Current tab index (`_currentIndex`)
- Drawer open/close state

Future: May integrate with BLoC for:
- User profile data
- Learning statistics
- Notification badge counts

## 🚀 Navigation Flow

```
App Start → Login → HomePage (Kanji Tab)
  ├─ Bottom Nav → Switch between tabs
  ├─ Drawer → Navigate to any feature
  ├─ Quick Actions → Direct navigation (e.g., Browse Kanji)
  └─ AppBar Icons → Notifications, Settings
```

## 📝 TODO

- [ ] Integrate real user data from AuthBloc
- [ ] Implement notification badge on bell icon
- [ ] Add settings page
- [ ] Connect to backend for learning stats
- [ ] Add pull-to-refresh on Home tab
- [ ] Implement search functionality in Search tab
- [ ] Create flashcard decks UI
- [ ] Build quiz list and quiz taking UI
- [ ] Add user avatar upload
- [ ] Implement theme customization in settings

## 🔗 Dependencies

- `flutter_bloc`: State management (for AuthBloc integration)
- `go_router`: Navigation routing
- Material 3 Design: UI components

## 📸 Screenshots

*(Screenshots to be added)*

### Bottom Navigation
- 5 tabs with icons and labels
- Active tab highlighted in primary color
- Smooth transitions

### Drawer Menu
- Gradient header with user info
- Categorized menu items
- Clear section dividers
- Logout with confirmation dialog

### Home Tab
- Welcome card with gradient
- Quick action cards (2 columns)
- Stats display (3 metrics)
- Clean, minimal design
