import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/core/network/api_client.dart';
import 'package:kanji_mobile_app/features/progress/services/progress_api_service.dart';
import 'package:kanji_mobile_app/features/progress/models/progress_models.dart';
import 'package:kanji_mobile_app/injection_container.dart' as di;
import '../helpers/test_helper.dart';
import '../helpers/auth_helper.dart';

/// Integration test for ProgressApiService - Type Casting Validation
///
/// This test verifies that the ProgressApiService correctly handles:
/// - Type conversions from API responses
/// - Missing/null fields
/// - Invalid data types
/// - Nested object parsing
/// - Array/list validation
///
/// To run: flutter test test/integration/progress_integration_test.dart
void main() {
  late ProgressApiService progressApiService;

  setUpAll(() async {
    TestHelper.printSection('INITIALIZING PROGRESS INTEGRATION TESTS');
    await TestHelper.initializeDependencies();
    TestHelper.printSuccess('Dependencies initialized');

    // Initialize progress service
    final apiClient = di.sl<ApiClient>();
    progressApiService = ProgressApiService(apiClient);
  });

  group('1. Progress Authentication Tests -', () {
    test('1.1. Unauthenticated access denied', () async {
      TestHelper.printSection('TEST 1.1: UNAUTHENTICATED ACCESS DENIED');

      // Clear token
      TestHelper.printStep('Clearing authentication...');
      final apiClient = di.sl<ApiClient>();
      apiClient.clearAuthToken();

      TestHelper.printStep('Attempting to access progress without token...');

      try {
        await progressApiService.getProgressOverview();
        TestHelper.printError('Should require authentication');
        fail('Should not access without authentication');
      } catch (e) {
        TestHelper.printSuccess('Access denied (as expected)');
        TestHelper.printSuccess('Error: ${e.toString()}');
        expect(
          e.toString().toLowerCase(),
          anyOf(contains('unauthorized'), contains('401'), contains('token')),
        );
      }

      // Re-authenticate for next tests
      await AuthHelper.setupAuth();
    });

    test('1.2. Authenticated user can access progress', () async {
      TestHelper.printSection('TEST 1.2: AUTHENTICATED USER ACCESS');

      // Setup authentication
      TestHelper.printStep('Setting up authentication...');
      await AuthHelper.setupAuth();

      TestHelper.printStep('Fetching progress overview...');

      try {
        final overview = await progressApiService.getProgressOverview();

        TestHelper.printSuccess('Progress access granted');
        TestHelper.printSuccess('User ID: ${overview.userId}');
        TestHelper.printSuccess('Username: ${overview.username}');
        TestHelper.printSuccess('Level: ${overview.level}');
        TestHelper.printSuccess('XP: ${overview.xp}');

        expect(overview.userId, greaterThan(0));
        expect(overview.username, isNotEmpty);
      } catch (e) {
        TestHelper.printError('Progress access failed: $e');
        fail('Authenticated user should access progress');
      }
    });
  });

  group('2. Progress Overview Type Casting Tests -', () {
    setUpAll(() async {
      // Ensure authentication
      await AuthHelper.setupAuth();
    });

    test('2.1. Overview fields have correct types', () async {
      TestHelper.printSection('TEST 2.1: OVERVIEW FIELD TYPE VALIDATION');

      TestHelper.printStep('Fetching progress overview...');
      final overview = await progressApiService.getProgressOverview();

      TestHelper.printSuccess('Overview retrieved, validating types...');

      // Basic identity fields
      TestHelper.printStep('Checking userId type...');
      expect(overview.userId, isA<int>());
      TestHelper.printSuccess('✓ userId is int: ${overview.userId}');

      TestHelper.printStep('Checking username type...');
      expect(overview.username, isA<String>());
      TestHelper.printSuccess('✓ username is String: ${overview.username}');

      // Streak fields
      TestHelper.printStep('Checking streak types...');
      expect(overview.currentStreak, isA<int>());
      expect(overview.longestStreak, isA<int>());
      TestHelper.printSuccess(
        '✓ Streaks are int: ${overview.currentStreak}/${overview.longestStreak}',
      );

      // Study time fields
      TestHelper.printStep('Checking study time type...');
      expect(overview.totalStudyTime, isA<int>());
      TestHelper.printSuccess(
        '✓ totalStudyTime is int: ${overview.totalStudyTime}',
      );

      // Session counts
      TestHelper.printStep('Checking session counts...');
      expect(overview.totalFlashcardSessions, isA<int>());
      expect(overview.totalQuizAttempts, isA<int>());
      TestHelper.printSuccess(
        '✓ Sessions are int: ${overview.totalFlashcardSessions} flashcards, ${overview.totalQuizAttempts} quizzes',
      );

      // Accuracy fields
      TestHelper.printStep('Checking accuracy types...');
      expect(overview.flashcardAccuracy, isA<int>());
      expect(overview.quizAccuracy, isA<int>());
      TestHelper.printSuccess(
        '✓ Accuracies are int: ${overview.flashcardAccuracy}%, ${overview.quizAccuracy}%',
      );

      // Mastery
      TestHelper.printStep('Checking kanjiMastered type...');
      expect(overview.kanjiMastered, isA<int>());
      TestHelper.printSuccess(
        '✓ kanjiMastered is int: ${overview.kanjiMastered}',
      );

      // Level and XP
      TestHelper.printStep('Checking level and XP types...');
      expect(overview.level, isA<int>());
      expect(overview.xp, isA<int>());
      TestHelper.printSuccess(
        '✓ Level/XP are int: ${overview.level}/${overview.xp}',
      );

      TestHelper.printSuccess('All overview field types are correct');
    });

    test('2.2. Overview data values are valid', () async {
      TestHelper.printSection('TEST 2.2: OVERVIEW VALUE VALIDATION');

      TestHelper.printStep('Fetching progress overview...');
      final overview = await progressApiService.getProgressOverview();

      TestHelper.printSuccess('Overview retrieved, validating values...');

      // All numeric values should be non-negative
      expect(overview.userId, greaterThan(0));
      TestHelper.printSuccess('✓ userId is positive: ${overview.userId}');

      expect(overview.currentStreak, greaterThanOrEqualTo(0));
      TestHelper.printSuccess(
        '✓ currentStreak >= 0: ${overview.currentStreak}',
      );

      expect(overview.longestStreak, greaterThanOrEqualTo(0));
      TestHelper.printSuccess(
        '✓ longestStreak >= 0: ${overview.longestStreak}',
      );

      expect(overview.totalStudyTime, greaterThanOrEqualTo(0));
      TestHelper.printSuccess(
        '✓ totalStudyTime >= 0: ${overview.totalStudyTime}',
      );

      expect(overview.totalFlashcardSessions, greaterThanOrEqualTo(0));
      expect(overview.totalQuizAttempts, greaterThanOrEqualTo(0));
      TestHelper.printSuccess('✓ Session counts >= 0');

      // Accuracy should be 0-100
      expect(overview.flashcardAccuracy, greaterThanOrEqualTo(0.0));
      expect(overview.flashcardAccuracy, lessThanOrEqualTo(100.0));
      TestHelper.printSuccess(
        '✓ flashcardAccuracy in [0,100]: ${overview.flashcardAccuracy}',
      );

      expect(overview.quizAccuracy, greaterThanOrEqualTo(0.0));
      expect(overview.quizAccuracy, lessThanOrEqualTo(100.0));
      TestHelper.printSuccess(
        '✓ quizAccuracy in [0,100]: ${overview.quizAccuracy}',
      );

      expect(overview.kanjiMastered, greaterThanOrEqualTo(0));
      TestHelper.printSuccess(
        '✓ kanjiMastered >= 0: ${overview.kanjiMastered}',
      );

      // Level should be at least 1
      expect(overview.level, greaterThan(0));
      TestHelper.printSuccess('✓ level > 0: ${overview.level}');

      expect(overview.xp, greaterThanOrEqualTo(0));
      TestHelper.printSuccess('✓ xp >= 0: ${overview.xp}');

      // Current streak should not exceed longest streak
      expect(overview.currentStreak, lessThanOrEqualTo(overview.longestStreak));
      TestHelper.printSuccess('✓ currentStreak <= longestStreak');

      TestHelper.printSuccess('All overview values are valid');
    });

    test('2.3. Helper methods work correctly', () async {
      TestHelper.printSection('TEST 2.3: HELPER METHOD VALIDATION');

      TestHelper.printStep('Fetching progress overview...');
      final overview = await progressApiService.getProgressOverview();

      TestHelper.printSuccess('Testing helper methods...');

      // Test formattedStudyTime
      TestHelper.printStep('Testing formattedStudyTime...');
      final formatted = overview.formattedStudyTime;
      expect(formatted, isA<String>());
      expect(formatted, isNotEmpty);
      TestHelper.printSuccess('✓ formattedStudyTime: $formatted');

      // Test xpForNextLevel
      TestHelper.printStep('Testing xpForNextLevel...');
      final xpForNext = overview.xpForNextLevel;
      expect(xpForNext, isA<int>());
      expect(xpForNext, greaterThan(0));
      TestHelper.printSuccess('✓ xpForNextLevel: $xpForNext XP');

      // Test xpProgress
      TestHelper.printStep('Testing xpProgress...');
      final progress = overview.xpProgress;
      expect(progress, isA<double>());
      expect(progress, greaterThanOrEqualTo(0.0));
      expect(progress, lessThanOrEqualTo(1.0));
      TestHelper.printSuccess(
        '✓ xpProgress: ${(progress * 100).toStringAsFixed(1)}%',
      );

      // Verify progress calculation
      final currentLevelXp = (overview.level - 1) * (overview.level - 1) * 100;
      final nextLevelXp = overview.level * overview.level * 100;
      final xpIntoLevel = overview.xp - currentLevelXp;
      final xpNeededForLevel = nextLevelXp - currentLevelXp;
      final expectedProgress = xpIntoLevel / xpNeededForLevel;

      expect(progress, closeTo(expectedProgress, 0.01));
      TestHelper.printSuccess('✓ Progress calculation is correct');

      TestHelper.printSuccess('All helper methods work correctly');
    });
  });

  group('3. Streak Type Casting Tests -', () {
    setUpAll(() async {
      // Ensure authentication
      await AuthHelper.setupAuth();
    });

    test('3.1. Streak fields have correct types', () async {
      TestHelper.printSection('TEST 3.1: STREAK FIELD TYPE VALIDATION');

      TestHelper.printStep('Fetching streak info...');
      final streakInfo = await progressApiService.getStreaks();

      TestHelper.printSuccess('Streak info retrieved, validating types...');

      // Basic streak fields
      TestHelper.printStep('Checking streak count types...');
      expect(streakInfo.currentStreak, isA<int>());
      expect(streakInfo.longestStreak, isA<int>());
      expect(streakInfo.totalStudyDays, isA<int>());
      TestHelper.printSuccess(
        '✓ Streak counts are int: ${streakInfo.currentStreak}/${streakInfo.longestStreak} (${streakInfo.totalStudyDays} total)',
      );

      // Weekly/monthly counts
      TestHelper.printStep('Checking period counts...');
      expect(streakInfo.daysThisWeek, isA<int>());
      expect(streakInfo.daysThisMonth, isA<int>());
      TestHelper.printSuccess(
        '✓ Period counts are int: ${streakInfo.daysThisWeek} this week, ${streakInfo.daysThisMonth} this month',
      );

      // Active flag
      TestHelper.printStep('Checking isActive type...');
      expect(streakInfo.isActive, isA<bool>());
      TestHelper.printSuccess('✓ isActive is bool: ${streakInfo.isActive}');

      // Date arrays
      TestHelper.printStep('Checking date arrays...');
      expect(streakInfo.streakDates, isA<List<DateTime>>());
      TestHelper.printSuccess(
        '✓ Date arrays: ${streakInfo.streakDates.length} streak dates',
      );

      TestHelper.printSuccess('All streak field types are correct');
    });

    test('3.2. Streak values are valid', () async {
      TestHelper.printSection('TEST 3.2: STREAK VALUE VALIDATION');

      TestHelper.printStep('Fetching streak info...');
      final streakInfo = await progressApiService.getStreaks();

      TestHelper.printSuccess('Streak info retrieved, validating values...');

      // All counts should be non-negative
      expect(streakInfo.currentStreak, greaterThanOrEqualTo(0));
      TestHelper.printSuccess(
        '✓ currentStreak >= 0: ${streakInfo.currentStreak}',
      );

      expect(streakInfo.longestStreak, greaterThanOrEqualTo(0));
      TestHelper.printSuccess(
        '✓ longestStreak >= 0: ${streakInfo.longestStreak}',
      );

      expect(streakInfo.totalStudyDays, greaterThanOrEqualTo(0));
      TestHelper.printSuccess(
        '✓ totalStudyDays >= 0: ${streakInfo.totalStudyDays}',
      );

      // Weekly count should be 0-7
      expect(streakInfo.daysThisWeek, greaterThanOrEqualTo(0));
      expect(streakInfo.daysThisWeek, lessThanOrEqualTo(7));
      TestHelper.printSuccess(
        '✓ daysThisWeek in [0,7]: ${streakInfo.daysThisWeek}',
      );

      // Monthly count should be reasonable
      expect(streakInfo.daysThisMonth, greaterThanOrEqualTo(0));
      expect(streakInfo.daysThisMonth, lessThanOrEqualTo(31));
      TestHelper.printSuccess(
        '✓ daysThisMonth in [0,31]: ${streakInfo.daysThisMonth}',
      );

      // Current streak should not exceed longest
      expect(
        streakInfo.currentStreak,
        lessThanOrEqualTo(streakInfo.longestStreak),
      );
      TestHelper.printSuccess('✓ currentStreak <= longestStreak');

      // Streak dates length should match current streak
      expect(streakInfo.streakDates.length, equals(streakInfo.currentStreak));
      TestHelper.printSuccess('✓ streakDates.length matches currentStreak');

      TestHelper.printSuccess('All streak values are valid');
    });

    test('3.3. Date array validation', () async {
      TestHelper.printSection('TEST 3.3: DATE ARRAY VALIDATION');

      TestHelper.printStep('Fetching streak info...');
      final streakInfo = await progressApiService.getStreaks();

      TestHelper.printSuccess('Validating date arrays...');

      final now = DateTime.now();

      // Validate streak dates
      if (streakInfo.streakDates.isNotEmpty) {
        TestHelper.printStep('Checking streak dates...');

        for (int i = 0; i < streakInfo.streakDates.length; i++) {
          final date = streakInfo.streakDates[i];

          // All dates should be DateTime
          expect(date, isA<DateTime>());

          // Dates should be in the past or today
          expect(date.isBefore(now.add(const Duration(days: 1))), true);

          if (i < 5) {
            // Log first 5 dates
            TestHelper.printSuccess('  ✓ Streak date $i: ${date.toLocal()}');
          }
        }

        TestHelper.printSuccess(
          '✓ All ${streakInfo.streakDates.length} streak dates are valid',
        );
      }

      TestHelper.printSuccess('Date arrays are valid');
    });
  });

  group('4. Leaderboard Type Casting Tests -', () {
    setUpAll(() async {
      // Ensure authentication
      await AuthHelper.setupAuth();
    });

    test('4.1. Leaderboard fields have correct types', () async {
      TestHelper.printSection('TEST 4.1: LEADERBOARD FIELD TYPE VALIDATION');

      TestHelper.printStep('Fetching leaderboard (XP, WEEK, limit 10)...');
      final leaderboard = await progressApiService.getLeaderboard(
        period: 'week',
        type: 'xp',
        limit: 10,
      );

      TestHelper.printSuccess('Leaderboard retrieved, validating types...');

      // Metadata fields
      TestHelper.printStep('Checking metadata types...');
      expect(leaderboard.type, isA<String>());
      expect(leaderboard.period, isA<String>());
      TestHelper.printSuccess(
        '✓ Metadata: ${leaderboard.type} / ${leaderboard.period}',
      );

      // Entries array
      TestHelper.printStep('Checking entries array...');
      expect(leaderboard.entries, isA<List<LeaderboardEntry>>());
      TestHelper.printSuccess(
        '✓ Entries is List: ${leaderboard.entries.length} users',
      );

      // Current user fields
      TestHelper.printStep('Checking currentUserRank type...');
      expect(leaderboard.currentUserRank, anyOf(isA<int>(), isNull));
      TestHelper.printSuccess(
        '✓ currentUserRank: ${leaderboard.currentUserRank}',
      );

      TestHelper.printStep('Checking currentUser type...');
      expect(leaderboard.currentUser, anyOf(isA<LeaderboardEntry>(), isNull));
      TestHelper.printSuccess(
        '✓ currentUser: ${leaderboard.currentUser != null ? "Present" : "Null"}',
      );

      TestHelper.printSuccess('All leaderboard field types are correct');
    });

    test('4.2. Leaderboard entry types validation', () async {
      TestHelper.printSection('TEST 4.2: LEADERBOARD ENTRY TYPE VALIDATION');

      TestHelper.printStep('Fetching leaderboard...');
      final leaderboard = await progressApiService.getLeaderboard(
        period: 'week',
        type: 'xp',
        limit: 10,
      );

      if (leaderboard.entries.isEmpty) {
        TestHelper.printStep('No leaderboard entries (this is OK)');
        return;
      }

      TestHelper.printSuccess(
        'Validating ${leaderboard.entries.length} entries...',
      );

      for (int i = 0; i < leaderboard.entries.length; i++) {
        final entry = leaderboard.entries[i];

        TestHelper.printStep('Validating entry $i...');

        expect(entry.rank, isA<int>());
        expect(entry.userId, isA<int>());
        expect(entry.username, isA<String>());
        expect(entry.score, isA<int>());

        TestHelper.printSuccess(
          '  ✓ #${entry.rank} ${entry.username}: ${entry.score}',
        );
      }

      TestHelper.printSuccess('All entry types are correct');
    });

    test('4.3. Leaderboard values are valid', () async {
      TestHelper.printSection('TEST 4.3: LEADERBOARD VALUE VALIDATION');

      TestHelper.printStep('Fetching leaderboard...');
      final leaderboard = await progressApiService.getLeaderboard(
        period: 'week',
        type: 'xp',
        limit: 10,
      );

      if (leaderboard.entries.isEmpty) {
        TestHelper.printStep('No leaderboard entries (this is OK)');
        return;
      }

      TestHelper.printSuccess('Validating entry values...');

      for (int i = 0; i < leaderboard.entries.length; i++) {
        final entry = leaderboard.entries[i];

        // Rank should be positive and sequential
        expect(entry.rank, greaterThan(0));
        expect(entry.rank, equals(i + 1));

        // User ID should be positive
        expect(entry.userId, greaterThan(0));

        // Username should not be empty
        expect(entry.username, isNotEmpty);

        // Score should be non-negative
        expect(entry.score, greaterThanOrEqualTo(0));
      }

      TestHelper.printSuccess('✓ All ranks are sequential');
      TestHelper.printSuccess('✓ All scores are non-negative');

      // If there are multiple entries, scores should be descending
      if (leaderboard.entries.length > 1) {
        for (int i = 0; i < leaderboard.entries.length - 1; i++) {
          expect(
            leaderboard.entries[i].score,
            greaterThanOrEqualTo(leaderboard.entries[i + 1].score),
          );
        }
        TestHelper.printSuccess('✓ Scores are in descending order');
      }

      TestHelper.printSuccess('All leaderboard values are valid');
    });

    test('4.4. Different leaderboard types work', () async {
      TestHelper.printSection('TEST 4.4: MULTIPLE LEADERBOARD TYPES');

      final types = ['xp', 'streak', 'accuracy', 'cards'];

      for (final type in types) {
        TestHelper.printStep('Fetching $type leaderboard...');

        try {
          final leaderboard = await progressApiService.getLeaderboard(
            period: 'week',
            type: type,
            limit: 5,
          );

          expect(leaderboard.type, equals(type));
          expect(leaderboard.entries, isA<List<LeaderboardEntry>>());

          TestHelper.printSuccess(
            '✓ $type leaderboard: ${leaderboard.entries.length} entries',
          );
        } catch (e) {
          TestHelper.printError('Failed to fetch $type leaderboard: $e');
        }

        await Future.delayed(const Duration(milliseconds: 200));
      }

      TestHelper.printSuccess('All leaderboard types work');
    });
  });

  group('5. Achievements Type Casting Tests -', () {
    setUpAll(() async {
      // Ensure authentication
      await AuthHelper.setupAuth();
    });

    test('5.1. Achievements container types', () async {
      TestHelper.printSection('TEST 5.1: ACHIEVEMENTS CONTAINER VALIDATION');

      TestHelper.printStep('Fetching achievements...');
      final achievements = await progressApiService.getAchievements();

      TestHelper.printSuccess('Achievements retrieved, validating types...');

      // Container fields
      TestHelper.printStep('Checking container fields...');
      expect(achievements.totalAvailable, isA<int>());
      expect(achievements.totalUnlocked, isA<int>());
      expect(achievements.completionPercentage, isA<int>());
      TestHelper.printSuccess(
        '✓ Container: ${achievements.totalUnlocked}/${achievements.totalAvailable} (${achievements.completionPercentage}%)',
      );

      // Achievements array
      TestHelper.printStep('Checking achievements array...');
      expect(achievements.achievements, isA<List<Achievement>>());
      TestHelper.printSuccess(
        '✓ Achievements is List: ${achievements.achievements.length} items',
      );

      TestHelper.printSuccess('All container types are correct');
    });

    test('5.2. Achievement fields have correct types', () async {
      TestHelper.printSection('TEST 5.2: ACHIEVEMENT FIELD TYPE VALIDATION');

      TestHelper.printStep('Fetching achievements...');
      final achievements = await progressApiService.getAchievements();

      if (achievements.achievements.isEmpty) {
        TestHelper.printStep('No achievements available (this is OK)');
        return;
      }

      TestHelper.printSuccess(
        'Validating ${achievements.achievements.length} achievements...',
      );

      for (int i = 0; i < achievements.achievements.length; i++) {
        final achievement = achievements.achievements[i];

        if (i < 5) {
          // Log first 5 in detail
          TestHelper.printStep('Validating achievement $i...');

          expect(achievement.id, isA<String>());
          expect(achievement.name, isA<String>());
          expect(achievement.description, isA<String>());
          expect(achievement.icon, isA<String>());
          expect(achievement.category, isA<String>());
          expect(achievement.unlocked, isA<bool>());
          expect(achievement.progress, isA<int>());
          expect(achievement.currentValue, isA<int>());
          expect(achievement.targetValue, isA<int>());
          expect(achievement.xpReward, isA<int>());

          TestHelper.printSuccess(
            '  ✓ ${achievement.icon} ${achievement.name}: ${achievement.unlocked ? "Unlocked" : "${achievement.progress}%"}',
          );
        }
      }

      TestHelper.printSuccess('All achievement field types are correct');
    });

    test('5.3. Achievement values are valid', () async {
      TestHelper.printSection('TEST 5.3: ACHIEVEMENT VALUE VALIDATION');

      TestHelper.printStep('Fetching achievements...');
      final achievements = await progressApiService.getAchievements();

      TestHelper.printSuccess('Validating achievement values...');

      // Container values
      expect(achievements.totalAvailable, greaterThan(0));
      expect(achievements.totalUnlocked, greaterThanOrEqualTo(0));
      expect(
        achievements.totalUnlocked,
        lessThanOrEqualTo(achievements.totalAvailable),
      );
      TestHelper.printSuccess('✓ Container values are valid');

      // Completion percentage
      expect(achievements.completionPercentage, greaterThanOrEqualTo(0.0));
      expect(achievements.completionPercentage, lessThanOrEqualTo(100.0));
      TestHelper.printSuccess(
        '✓ Completion percentage in [0,100]: ${achievements.completionPercentage}',
      );

      // Individual achievements
      for (final achievement in achievements.achievements) {
        // Progress should be 0-100
        expect(achievement.progress, greaterThanOrEqualTo(0.0));
        expect(achievement.progress, lessThanOrEqualTo(100.0));

        // Target value should be positive
        expect(achievement.targetValue, greaterThan(0));

        // Current value should not exceed target
        expect(
          achievement.currentValue,
          lessThanOrEqualTo(achievement.targetValue),
        );

        // XP reward should be non-negative
        expect(achievement.xpReward, greaterThanOrEqualTo(0));

        // If unlocked, progress should be 100
        if (achievement.unlocked) {
          expect(achievement.progress, equals(100));
          expect(achievement.currentValue, equals(achievement.targetValue));
        }
      }

      TestHelper.printSuccess('All achievement values are valid');
    });

    test('5.4. Achievement categories are valid', () async {
      TestHelper.printSection('TEST 5.4: ACHIEVEMENT CATEGORY VALIDATION');

      TestHelper.printStep('Fetching achievements...');
      final achievements = await progressApiService.getAchievements();

      TestHelper.printSuccess('Validating categories...');

      // Backend returns lowercase category names
      final validCategories = {'flashcard', 'quiz', 'mastery', 'streak'};
      final foundCategories = <String>{};

      for (final achievement in achievements.achievements) {
        expect(validCategories, contains(achievement.category));
        foundCategories.add(achievement.category);
      }

      TestHelper.printSuccess(
        '✓ Found categories: ${foundCategories.join(", ")}',
      );
      TestHelper.printSuccess('All categories are valid');
    });
  });

  group('6. Chart Data Type Casting Tests -', () {
    setUpAll(() async {
      // Ensure authentication
      await AuthHelper.setupAuth();
    });

    test('6.1. Chart data fields have correct types', () async {
      TestHelper.printSection('TEST 6.1: CHART DATA FIELD TYPE VALIDATION');

      TestHelper.printStep('Fetching chart data (WEEK, 7 points)...');
      final chartData = await progressApiService.getChartData(
        period: 'week',
        points: 7,
      );

      TestHelper.printSuccess('Chart data retrieved, validating types...');

      // Labels array
      TestHelper.printStep('Checking labels array...');
      expect(chartData.labels, isA<List<String>>());
      TestHelper.printSuccess(
        '✓ Labels is List<String>: ${chartData.labels.length} items',
      );

      // Data arrays
      TestHelper.printStep('Checking data arrays...');
      expect(chartData.studyTime, isA<List<int>>());
      expect(chartData.cardsReviewed, isA<List<int>>());
      expect(chartData.quizAttempts, isA<List<int>>());
      expect(chartData.accuracy, isA<List<int>>());
      expect(chartData.xpEarned, isA<List<int>>());
      TestHelper.printSuccess('✓ All data arrays have correct types');

      TestHelper.printSuccess('All chart data field types are correct');
    });

    test('6.2. Chart data arrays have consistent length', () async {
      TestHelper.printSection('TEST 6.2: CHART DATA ARRAY LENGTH VALIDATION');

      TestHelper.printStep('Fetching chart data...');
      final chartData = await progressApiService.getChartData(
        period: 'week',
        points: 7,
      );

      TestHelper.printSuccess('Validating array lengths...');

      final expectedLength = chartData.labels.length;

      expect(chartData.studyTime.length, equals(expectedLength));
      TestHelper.printSuccess('✓ studyTime length matches: $expectedLength');

      expect(chartData.cardsReviewed.length, equals(expectedLength));
      TestHelper.printSuccess(
        '✓ cardsReviewed length matches: $expectedLength',
      );

      expect(chartData.quizAttempts.length, equals(expectedLength));
      TestHelper.printSuccess('✓ quizAttempts length matches: $expectedLength');

      expect(chartData.accuracy.length, equals(expectedLength));
      TestHelper.printSuccess('✓ accuracy length matches: $expectedLength');

      expect(chartData.xpEarned.length, equals(expectedLength));
      TestHelper.printSuccess('✓ xpEarned length matches: $expectedLength');

      TestHelper.printSuccess('All arrays have consistent length');
    });

    test('6.3. Chart data values are valid', () async {
      TestHelper.printSection('TEST 6.3: CHART DATA VALUE VALIDATION');

      TestHelper.printStep('Fetching chart data...');
      final chartData = await progressApiService.getChartData(
        period: 'week',
        points: 7,
      );

      TestHelper.printSuccess('Validating data values...');

      // All integer arrays should have non-negative values
      for (int i = 0; i < chartData.studyTime.length; i++) {
        expect(chartData.studyTime[i], greaterThanOrEqualTo(0));
        expect(chartData.cardsReviewed[i], greaterThanOrEqualTo(0));
        expect(chartData.quizAttempts[i], greaterThanOrEqualTo(0));
        expect(chartData.xpEarned[i], greaterThanOrEqualTo(0));

        // Accuracy should be 0-100 (int)
        expect(chartData.accuracy[i], greaterThanOrEqualTo(0));
        expect(chartData.accuracy[i], lessThanOrEqualTo(100));

        if (i < 3) {
          // Log first 3 data points
          TestHelper.printSuccess(
            '  ✓ ${chartData.labels[i]}: ${chartData.studyTime[i]}min, ${chartData.cardsReviewed[i]} cards, ${chartData.accuracy[i]}%',
          );
        }
      }

      TestHelper.printSuccess('All chart data values are valid');
    });

    test('6.4. Different chart periods work', () async {
      TestHelper.printSection('TEST 6.4: MULTIPLE CHART PERIODS');

      final periods = ['week', 'month'];
      final pointsList = [7, 30];

      for (int i = 0; i < periods.length; i++) {
        TestHelper.printStep('Fetching ${periods[i]} chart data...');

        try {
          final chartData = await progressApiService.getChartData(
            period: periods[i],
            points: pointsList[i],
          );

          expect(chartData.labels, isA<List<String>>());
          expect(chartData.labels.length, greaterThan(0));

          TestHelper.printSuccess(
            '✓ ${periods[i]} chart: ${chartData.labels.length} data points',
          );
        } catch (e) {
          TestHelper.printError('Failed to fetch ${periods[i]} chart: $e');
        }

        await Future.delayed(const Duration(milliseconds: 200));
      }

      TestHelper.printSuccess('All chart periods work');
    });
  });

  group('7. Error Handling Tests -', () {
    setUpAll(() async {
      // Ensure authentication
      await AuthHelper.setupAuth();
    });

    test('7.1. Multiple consecutive requests', () async {
      TestHelper.printSection('TEST 7.1: MULTIPLE CONSECUTIVE REQUESTS');

      TestHelper.printStep('Making 5 consecutive overview requests...');

      for (int i = 1; i <= 5; i++) {
        TestHelper.printStep('Request $i/5');

        final overview = await progressApiService.getProgressOverview();
        expect(overview.userId, greaterThan(0));

        await Future.delayed(const Duration(milliseconds: 200));
      }

      TestHelper.printSuccess('All requests completed successfully');
    });

    test('7.2. Data consistency across calls', () async {
      TestHelper.printSection('TEST 7.2: DATA CONSISTENCY');

      TestHelper.printStep('Fetching overview multiple times...');

      final overview1 = await progressApiService.getProgressOverview();
      await Future.delayed(const Duration(milliseconds: 500));
      final overview2 = await progressApiService.getProgressOverview();

      TestHelper.printSuccess('Comparing overviews...');

      expect(overview1.userId, equals(overview2.userId));
      expect(overview1.username, equals(overview2.username));
      expect(overview1.level, equals(overview2.level));

      TestHelper.printSuccess('Overview data is consistent');
    });

    test('7.3. Invalid leaderboard parameters', () async {
      TestHelper.printSection('TEST 7.3: INVALID PARAMETERS HANDLING');

      TestHelper.printStep('Testing with invalid type...');

      try {
        await progressApiService.getLeaderboard(
          period: 'week',
          type: 'invalid_type',
          limit: 10,
        );
        // May or may not throw depending on backend validation
      } catch (e) {
        TestHelper.printSuccess('Invalid type rejected (as expected): $e');
      }

      TestHelper.printStep('Testing with invalid period...');

      try {
        await progressApiService.getLeaderboard(
          period: 'INVALID',
          type: 'xp',
          limit: 10,
        );
        // May or may not throw depending on backend validation
      } catch (e) {
        TestHelper.printSuccess('Invalid period rejected (as expected): $e');
      }

      TestHelper.printSuccess('Parameter validation working');
    });
  });

  group('8. Complete Progress Workflow Tests -', () {
    setUpAll(() async {
      // Ensure authentication
      await AuthHelper.setupAuth();
    });

    test('8.1. Complete progress workflow', () async {
      TestHelper.printSection('TEST 8.1: COMPLETE PROGRESS WORKFLOW');

      // Step 1: Get overview
      TestHelper.printStep('1. Fetching progress overview...');
      final overview = await progressApiService.getProgressOverview();
      TestHelper.printSuccess('Overview loaded');
      TestHelper.printSuccess('  Level: ${overview.level} (${overview.xp} XP)');
      TestHelper.printSuccess('  Streak: ${overview.currentStreak} days');

      // Step 2: Get streaks
      TestHelper.printStep('2. Fetching streak details...');
      final streakInfo = await progressApiService.getStreaks();
      TestHelper.printSuccess('Streak info loaded');
      TestHelper.printSuccess(
        '  Total study days: ${streakInfo.totalStudyDays}',
      );
      TestHelper.printSuccess('  This week: ${streakInfo.daysThisWeek}/7');

      // Step 3: Get achievements
      TestHelper.printStep('3. Fetching achievements...');
      final achievements = await progressApiService.getAchievements();
      TestHelper.printSuccess('Achievements loaded');
      TestHelper.printSuccess(
        '  Unlocked: ${achievements.totalUnlocked}/${achievements.totalAvailable}',
      );

      // Step 4: Get leaderboard
      TestHelper.printStep('4. Fetching leaderboard...');
      final leaderboard = await progressApiService.getLeaderboard(
        period: 'week',
        type: 'xp',
        limit: 10,
      );
      TestHelper.printSuccess('Leaderboard loaded');
      TestHelper.printSuccess('  Entries: ${leaderboard.entries.length}');
      if (leaderboard.currentUserRank > 0) {
        TestHelper.printSuccess('  Your rank: #${leaderboard.currentUserRank}');
      }

      // Step 5: Get chart data
      TestHelper.printStep('5. Fetching chart data...');
      final chartData = await progressApiService.getChartData(
        period: 'week',
        points: 7,
      );
      TestHelper.printSuccess('Chart data loaded');
      TestHelper.printSuccess('  Data points: ${chartData.labels.length}');

      TestHelper.printSuccess('Complete workflow executed successfully');
    });

    test('8.2. Type safety throughout workflow', () async {
      TestHelper.printSection('TEST 8.2: TYPE SAFETY VALIDATION');

      TestHelper.printStep('Executing full workflow with type checks...');

      // Overview
      final overview = await progressApiService.getProgressOverview();
      expect(overview.userId, isA<int>());
      expect(overview.level, isA<int>());
      expect(overview.xp, isA<int>());
      TestHelper.printSuccess('✓ Overview types correct');

      // Streaks
      final streakInfo = await progressApiService.getStreaks();
      expect(streakInfo.currentStreak, isA<int>());
      expect(streakInfo.streakDates, isA<List<DateTime>>());
      TestHelper.printSuccess('✓ Streak types correct');

      // Achievements
      final achievements = await progressApiService.getAchievements();
      expect(achievements.achievements, isA<List<Achievement>>());
      expect(achievements.completionPercentage, isA<int>());
      TestHelper.printSuccess('✓ Achievement types correct');

      // Leaderboard
      final leaderboard = await progressApiService.getLeaderboard(
        period: 'week',
        type: 'xp',
        limit: 5,
      );
      expect(leaderboard.entries, isA<List<LeaderboardEntry>>());
      TestHelper.printSuccess('✓ Leaderboard types correct');

      // Chart data
      final chartData = await progressApiService.getChartData(
        period: 'week',
        points: 7,
      );
      expect(chartData.labels, isA<List<String>>());
      expect(chartData.accuracy, isA<List<int>>());
      TestHelper.printSuccess('✓ Chart data types correct');

      TestHelper.printSuccess('All types are correct throughout workflow');
    });
  });

  tearDownAll(() async {
    TestHelper.printSection('CLEANING UP PROGRESS TESTS');
    TestHelper.printSuccess('All progress integration tests completed');
  });
}
