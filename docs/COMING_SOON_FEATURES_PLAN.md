# 🚀 Coming Soon Features - Implementation Plan

**Date:** October 17, 2025  
**Status:** Ready for Development

---

## Overview

This document outlines all "coming soon" features found in the app and provides implementation plan.

---

## 📋 Feature Inventory

### 1. Progress Dashboard Features
- [ ] **Study Session from Progress** - Quick start study based on progress
- [ ] **Review List** - List of kanji needing review
- [ ] **Filter by JLPT Level** (N1-N5) - Filter progress by JLPT level
- [ ] **Filter by Grade** (1-6) - Filter progress by school grade

### 2. App Drawer Features
- [ ] **Achievements System** - Badges, milestones, rewards
- [ ] **Settings Page** - App preferences, notifications, study settings
- [ ] **Theme Toggle** - Light/Dark mode switch

### 3. Quiz Features
- [ ] **Create Custom Quiz** - User can create custom quizzes

---

## 🎯 Priority Classification

### Priority 1: High Impact, Quick Win
1. **Settings Page** - Essential for user preferences
2. **Theme Toggle** - Improve UX
3. **Filter by JLPT/Grade** - Already have data, just need filtering

### Priority 2: Core Features
4. **Study Session from Progress** - Link to existing flashcard
5. **Review List** - Show due kanji
6. **Create Custom Quiz** - Enhance quiz module

### Priority 3: Advanced Features
7. **Achievements System** - Gamification (requires backend)

---

## 📐 Implementation Details

### 1. Settings Page (Priority 1)

**Backend:** ✅ Already have NotificationPreference model

**Flutter Implementation:**
- Create `SettingsPage` with sections:
  - Account settings (email, password)
  - Notification preferences
  - Study preferences (daily goal, reminder time)
  - App preferences (language, theme)
- BLoC: `SettingsBloc` with events (Load, Update, Reset)
- Repository: Use existing NotificationPreference endpoints

**Files to Create:**
```
lib/features/settings/
  domain/
    entities/
      settings.dart
      notification_preferences.dart
    repositories/
      settings_repository.dart
  data/
    models/
      settings_model.dart
      notification_preferences_model.dart
    datasources/
      settings_remote_datasource.dart
    repositories/
      settings_repository_impl.dart
  presentation/
    bloc/
      settings_bloc.dart
      settings_event.dart
      settings_state.dart
    pages/
      settings_page.dart
    widgets/
      settings_section.dart
```

**Backend Endpoints Needed:**
- ✅ GET /user/notification-preferences (already have)
- ✅ PATCH /user/notification-preferences (already have)
- ⏳ GET /user/settings
- ⏳ PATCH /user/settings

**Estimated Time:** 4 hours

---

### 2. Theme Toggle (Priority 1)

**Implementation:** Using Provider/Riverpod for theme state

**Files to Create/Modify:**
```
lib/core/theme/
  theme_provider.dart
  app_themes.dart (light + dark themes)

lib/main.dart - wrap with ThemeProvider
```

**Features:**
- Toggle between light/dark mode
- Save preference to local storage
- Apply theme app-wide
- Use Material Design 3 theming

**Estimated Time:** 2 hours

---

### 3. Filter by JLPT/Grade (Priority 1)

**Backend:** ✅ Already have jlpt and grade fields in Kanji table

**Flutter Implementation:**
- Add filter state to `ProgressBloc`
- Update UI to show filter chips
- Filter kanji list by selected JLPT/Grade
- API call: GET /kanji/progress?jlpt=N3 or ?grade=5

**Backend Endpoint:**
- Modify existing GET /kanji/progress to accept query params

**Files to Modify:**
```
lib/features/kanji/presentation/pages/progress_dashboard_page.dart
lib/features/kanji/presentation/bloc/progress_bloc.dart
lib/features/kanji/data/datasources/kanji_remote_datasource.dart
```

**Estimated Time:** 2 hours

---

### 4. Study Session from Progress (Priority 2)

**Implementation:** Navigate to flashcard study session

**Logic:**
1. Create temporary deck from filtered kanji
2. Start study session
3. Option: "Study New", "Review Due", "Practice All"

**Files to Modify:**
```
lib/features/kanji/presentation/pages/progress_dashboard_page.dart
```

**API Flow:**
1. POST /flashcard/decks (create temp deck)
2. POST /flashcard/decks/:id/cards/bulk (add kanji)
3. POST /flashcard/decks/:id/study (start session)

**Estimated Time:** 3 hours

---

### 5. Review List (Priority 2)

**Backend Endpoint:**
- GET /kanji/due - Return kanji needing review (next_review_at <= now)

**Flutter Implementation:**
- Create `KanjiReviewListPage`
- Show kanji sorted by due date (oldest first)
- Display: character, meaning, due time, difficulty
- Actions: Quick review, Start study session

**Files to Create:**
```
lib/features/kanji/presentation/pages/kanji_review_list_page.dart
lib/features/kanji/domain/entities/kanji_due.dart
lib/features/kanji/data/models/kanji_due_model.dart
```

**Backend Implementation:**
```typescript
// src/modules/kanji/kanji.controller.ts
@Get('due')
async getKanjiDue(@Req() req, @Query('limit') limit?: string) {
  const userId = req.user?.id || 1;
  const maxResults = limit ? parseInt(limit) : 50;
  return this.kanjiService.getKanjiDue(userId, maxResults);
}

// src/modules/kanji/kanji.service.ts
async getKanjiDue(userId: number, limit: number) {
  return this.repo.getKanjiDue(userId, limit);
}

// src/modules/kanji/kanji.repo.ts
async getKanjiDue(userId: number, limit: number) {
  const now = new Date();
  
  // Get from flashcard cards (has SRS data)
  const dueCards = await this.dbClient.flashcardCard.findMany({
    where: {
      Deck: { user_id: userId },
      is_new: false,
      next_review_at: { lte: now },
    },
    include: {
      Kanji: true,
      Deck: { select: { id: true, name: true } },
    },
    orderBy: { next_review_at: 'asc' },
    take: limit,
  });

  return dueCards.map(card => ({
    id: card.kanji_id,
    character: card.Kanji.character,
    meanings: card.Kanji.meanings,
    jlpt: card.Kanji.jlpt,
    grade: card.Kanji.grade,
    nextReviewAt: card.next_review_at,
    difficulty: card.difficulty,
    interval: card.interval_days,
    deckId: card.deck_id,
    deckName: card.Deck.name,
  }));
}
```

**Estimated Time:** 4 hours

---

### 6. Create Custom Quiz (Priority 2)

**Backend:** ✅ Already have Quiz module

**Flutter Implementation:**
- Create `CreateQuizPage` with form:
  - Quiz name
  - Description
  - Select kanji (from list or deck)
  - Quiz settings (questions count, time limit, question types)
- Generate quiz questions automatically based on selected kanji

**Backend Endpoint:**
- POST /quiz/create-custom

**Files to Create:**
```
lib/features/quiz/presentation/pages/create_quiz_page.dart
lib/features/quiz/presentation/widgets/kanji_selector.dart
lib/features/quiz/domain/entities/quiz_settings.dart
```

**Backend Implementation:**
```typescript
// DTO
export class CreateCustomQuizDto {
  @ApiProperty()
  @IsString()
  name: string;

  @ApiProperty()
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({ type: [Number] })
  @IsArray()
  @IsInt({ each: true })
  kanjiIds: number[];

  @ApiProperty()
  @IsInt()
  @Min(5)
  @Max(100)
  questionsCount: number;

  @ApiProperty()
  @IsInt()
  @IsOptional()
  timeLimitMinutes?: number;

  @ApiProperty({ enum: ['multiple_choice', 'reading', 'meaning', 'mixed'] })
  @IsString()
  questionType: string;
}

// Controller
@Post('create-custom')
async createCustomQuiz(@Req() req, @Body() dto: CreateCustomQuizDto) {
  const userId = req.user?.id || 1;
  return this.quizService.createCustomQuiz(userId, dto);
}

// Service logic: Generate questions based on kanji + settings
```

**Estimated Time:** 5 hours

---

### 7. Achievements System (Priority 3)

**Backend Models:**
```prisma
model Achievement {
  id              Int      @id @default(autoincrement())
  key             String   @unique // "first_kanji", "100_reviews"
  name            String
  description     String
  icon            String
  category        String   // "study", "quiz", "streak"
  requirement     Json     // { type: "review_count", target: 100 }
  points          Int      @default(0)
  created_at      DateTime @default(now())
}

model UserAchievement {
  id              Int      @id @default(autoincrement())
  user_id         Int
  achievement_id  Int
  progress        Int      @default(0)
  completed       Boolean  @default(false)
  completed_at    DateTime?
  created_at      DateTime @default(now())

  User            User     @relation(fields: [user_id], references: [id])
  Achievement     Achievement @relation(fields: [achievement_id], references: [id])

  @@unique([user_id, achievement_id])
}
```

**Features:**
- Automatic achievement tracking
- Categories: Study, Quiz, Streak, Collection, Master
- Progress tracking with notifications
- Achievement display in profile

**Achievement Examples:**
- 🎯 First Steps - Complete first kanji
- 📚 Bookworm - Study 100 kanji
- 🔥 Week Warrior - 7 day streak
- 💯 Perfect Score - Get 100% on quiz
- 🌟 JLPT Ready - Master all N5 kanji
- ⚡ Speed Demon - Complete 50 cards in 10 minutes
- 🏆 Quiz Master - Complete 50 quizzes

**Estimated Time:** 8 hours (full implementation)

---

## 📅 Implementation Timeline

### Week 1 (Priority 1)
- Day 1-2: Settings Page (4h)
- Day 3: Theme Toggle (2h)
- Day 4: Filter by JLPT/Grade (2h)

### Week 2 (Priority 2)
- Day 1-2: Study Session from Progress (3h)
- Day 3: Review List (4h)
- Day 4-5: Create Custom Quiz (5h)

### Week 3 (Priority 3)
- Day 1-5: Achievements System (8h)

**Total Estimated Time:** 28 hours

---

## 🔧 Technical Requirements

### Backend
- NestJS 10+
- Prisma ORM
- PostgreSQL 14+
- TypeScript 5+

### Flutter
- Flutter 3.24+
- Dart 3.5+
- flutter_bloc 8+
- Provider/Riverpod for theme

### Packages Needed
```yaml
# Flutter
provider: ^6.1.1
shared_preferences: ^2.2.2
fl_chart: ^0.68.0 # For achievement progress charts

# Backend (already installed)
```

---

## ✅ Success Criteria

### Settings Page
- [ ] User can view/edit notification preferences
- [ ] User can change study settings
- [ ] User can toggle theme
- [ ] Settings persist across sessions

### Theme Toggle
- [ ] Light/dark mode works app-wide
- [ ] Preference saved to local storage
- [ ] Smooth theme transition

### Filters
- [ ] Filter by JLPT level (N1-N5)
- [ ] Filter by Grade (1-6)
- [ ] Filter persists during session
- [ ] Clear filter option

### Study Session
- [ ] Navigate to study from progress
- [ ] Create temp deck from current view
- [ ] Support all study modes

### Review List
- [ ] Show kanji needing review
- [ ] Sort by due date
- [ ] Quick actions available

### Create Quiz
- [ ] Select kanji from list/deck
- [ ] Configure quiz settings
- [ ] Auto-generate questions
- [ ] Preview before starting

### Achievements
- [ ] Track user progress automatically
- [ ] Show achievement list
- [ ] Display progress bars
- [ ] Notifications on unlock

---

## 📊 Current Progress

- [x] Identified all "coming soon" features
- [x] Created implementation plan
- [ ] Settings Page (0%)
- [ ] Theme Toggle (0%)
- [ ] Filter by JLPT/Grade (0%)
- [ ] Study Session from Progress (0%)
- [ ] Review List (0%)
- [ ] Create Custom Quiz (0%)
- [ ] Achievements System (0%)

---

**Next Step:** Start with Priority 1 features (Settings, Theme, Filters)

*Last Updated: October 17, 2025*
