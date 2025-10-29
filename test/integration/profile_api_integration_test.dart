import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/core/network/api_client.dart';
import 'package:kanji_mobile_app/features/profile/services/profile_api_service.dart';
import 'package:kanji_mobile_app/features/profile/models/profile_models.dart';
import 'package:kanji_mobile_app/injection_container.dart' as di;
import '../helpers/test_helper.dart';
import '../helpers/auth_helper.dart';

/// Integration test for ProfileApiService - Type Casting Validation
///
/// This test verifies that the ProfileApiService correctly handles:
/// - Type conversions from API responses
/// - Missing/null fields
/// - Invalid data types
/// - Nested object parsing
/// - Array/list validation
///
/// To run: flutter test test/integration/profile_api_integration_test.dart
void main() {
  late ProfileApiService profileApiService;

  setUpAll(() async {
    TestHelper.printSection('INITIALIZING PROFILE INTEGRATION TESTS');
    await TestHelper.initializeDependencies();
    TestHelper.printSuccess('Dependencies initialized');

    // Initialize profile service
    final apiClient = di.sl<ApiClient>();
    profileApiService = ProfileApiService(apiClient);
  });

  group('1. Profile Authentication Tests -', () {
    test('1.1. Unauthenticated access denied', () async {
      TestHelper.printSection('TEST 1.1: UNAUTHENTICATED ACCESS DENIED');

      // Clear token
      TestHelper.printStep('Clearing authentication...');
      final apiClient = di.sl<ApiClient>();
      apiClient.clearAuthToken();

      TestHelper.printStep('Attempting to access profile without token...');

      try {
        await profileApiService.getProfile();
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

    test('1.2. Authenticated user can access profile', () async {
      TestHelper.printSection('TEST 1.2: AUTHENTICATED USER ACCESS');

      // Setup authentication
      TestHelper.printStep('Setting up authentication...');
      await AuthHelper.setupAuth();

      TestHelper.printStep('Fetching profile...');

      try {
        final profile = await profileApiService.getProfile();

        TestHelper.printSuccess('Profile access granted');
        TestHelper.printSuccess('User ID: ${profile.id}');
        TestHelper.printSuccess('Email: ${profile.email}');
        TestHelper.printSuccess('Name: ${profile.name}');
        TestHelper.printSuccess('Role: ${profile.role}');

        expect(profile.id, greaterThan(0));
        expect(profile.email, isNotEmpty);
      } catch (e) {
        TestHelper.printError('Profile access failed: $e');
        fail('Authenticated user should access profile');
      }
    });
  });

  group('2. Profile Data Type Casting Tests -', () {
    setUpAll(() async {
      // Ensure authentication
      await AuthHelper.setupAuth();
    });

    test('2.1. Profile fields have correct types', () async {
      TestHelper.printSection('TEST 2.1: PROFILE FIELD TYPE VALIDATION');

      TestHelper.printStep('Fetching profile...');
      final profile = await profileApiService.getProfile();

      TestHelper.printSuccess('Profile retrieved, validating types...');

      // Verify types
      TestHelper.printStep('Checking ID type...');
      expect(profile.id, isA<int>());
      TestHelper.printSuccess('✓ ID is int: ${profile.id}');

      TestHelper.printStep('Checking email type...');
      expect(profile.email, isA<String>());
      TestHelper.printSuccess('✓ Email is String: ${profile.email}');

      TestHelper.printStep('Checking name type...');
      expect(profile.name, anyOf(isA<String>(), isNull));
      TestHelper.printSuccess('✓ Name is String or null: ${profile.name}');

      TestHelper.printStep('Checking role type...');
      expect(profile.role, isA<String>());
      TestHelper.printSuccess('✓ Role is String: ${profile.role}');

      TestHelper.printStep('Checking twoFactorEnabled type...');
      expect(profile.twoFactorEnabled, isA<bool>());
      TestHelper.printSuccess('✓ 2FA is bool: ${profile.twoFactorEnabled}');

      TestHelper.printStep('Checking createdAt type...');
      expect(profile.createdAt, anyOf(isA<DateTime>(), isNull));
      TestHelper.printSuccess('✓ CreatedAt is DateTime or null');

      TestHelper.printSuccess('All profile field types are correct');
    });

    test('2.2. Profile data values are valid', () async {
      TestHelper.printSection('TEST 2.2: PROFILE DATA VALUE VALIDATION');

      TestHelper.printStep('Fetching profile...');
      final profile = await profileApiService.getProfile();

      TestHelper.printSuccess('Profile retrieved, validating values...');

      // Verify valid values
      expect(profile.id, greaterThan(0));
      TestHelper.printSuccess('✓ ID is positive: ${profile.id}');

      expect(profile.email, isNotEmpty);
      expect(profile.email, contains('@'));
      TestHelper.printSuccess('✓ Email is valid: ${profile.email}');

      expect(profile.role, isIn(['USER', 'ADMIN']));
      TestHelper.printSuccess('✓ Role is valid: ${profile.role}');

      if (profile.createdAt != null) {
        expect(profile.createdAt!.isBefore(DateTime.now()), true);
        TestHelper.printSuccess('✓ CreatedAt is in the past');
      }

      TestHelper.printSuccess('All profile values are valid');
    });
  });

  group('3. Profile with Stats Type Casting Tests -', () {
    setUpAll(() async {
      // Ensure authentication
      await AuthHelper.setupAuth();
    });

    test('3.1. Stats fields have correct types', () async {
      TestHelper.printSection('TEST 3.1: STATS FIELD TYPE VALIDATION');

      TestHelper.printStep('Fetching profile with stats...');
      final profile = await profileApiService.getProfileWithStats();

      if (profile.stats == null) {
        TestHelper.printStep('No stats available (this is OK)');
        return;
      }

      final stats = profile.stats!;
      TestHelper.printSuccess('Stats retrieved, validating types...');

      // Verify types for all numeric fields
      TestHelper.printStep('Checking totalKanjiStudied type...');
      expect(stats.totalKanjiStudied, isA<int>());
      TestHelper.printSuccess(
        '✓ totalKanjiStudied is int: ${stats.totalKanjiStudied}',
      );

      TestHelper.printStep('Checking quizzesCompleted type...');
      expect(stats.quizzesCompleted, isA<int>());
      TestHelper.printSuccess(
        '✓ quizzesCompleted is int: ${stats.quizzesCompleted}',
      );

      TestHelper.printStep('Checking flashcardsReviewed type...');
      expect(stats.flashcardsReviewed, isA<int>());
      TestHelper.printSuccess(
        '✓ flashcardsReviewed is int: ${stats.flashcardsReviewed}',
      );

      TestHelper.printStep('Checking currentStreak type...');
      expect(stats.currentStreak, isA<int>());
      TestHelper.printSuccess('✓ currentStreak is int: ${stats.currentStreak}');

      TestHelper.printStep('Checking totalXp type...');
      expect(stats.totalXp, isA<int>());
      TestHelper.printSuccess('✓ totalXp is int: ${stats.totalXp}');

      TestHelper.printStep('Checking averageScore type...');
      expect(stats.averageScore, isA<double>());
      TestHelper.printSuccess(
        '✓ averageScore is double: ${stats.averageScore}',
      );

      TestHelper.printSuccess('All stats field types are correct');
    });

    test('3.2. Stats values are non-negative', () async {
      TestHelper.printSection('TEST 3.2: STATS VALUE VALIDATION');

      TestHelper.printStep('Fetching profile with stats...');
      final profile = await profileApiService.getProfileWithStats();

      if (profile.stats == null) {
        TestHelper.printStep('No stats available (this is OK)');
        return;
      }

      final stats = profile.stats!;
      TestHelper.printSuccess('Stats retrieved, validating values...');

      // All stats should be non-negative
      expect(stats.totalKanjiStudied, greaterThanOrEqualTo(0));
      TestHelper.printSuccess(
        '✓ totalKanjiStudied >= 0: ${stats.totalKanjiStudied}',
      );

      expect(stats.quizzesCompleted, greaterThanOrEqualTo(0));
      TestHelper.printSuccess(
        '✓ quizzesCompleted >= 0: ${stats.quizzesCompleted}',
      );

      expect(stats.flashcardsReviewed, greaterThanOrEqualTo(0));
      TestHelper.printSuccess(
        '✓ flashcardsReviewed >= 0: ${stats.flashcardsReviewed}',
      );

      expect(stats.currentStreak, greaterThanOrEqualTo(0));
      TestHelper.printSuccess('✓ currentStreak >= 0: ${stats.currentStreak}');

      expect(stats.totalXp, greaterThanOrEqualTo(0));
      TestHelper.printSuccess('✓ totalXp >= 0: ${stats.totalXp}');

      expect(stats.averageScore, greaterThanOrEqualTo(0.0));
      expect(stats.averageScore, lessThanOrEqualTo(100.0));
      TestHelper.printSuccess(
        '✓ averageScore in [0,100]: ${stats.averageScore}',
      );

      TestHelper.printSuccess('All stats values are valid');
    });

    test('3.3. Recent activity array type validation', () async {
      TestHelper.printSection('TEST 3.3: RECENT ACTIVITY TYPE VALIDATION');

      TestHelper.printStep('Fetching profile with stats...');
      final profile = await profileApiService.getProfileWithStats();

      if (profile.stats == null) {
        TestHelper.printStep('No stats available (this is OK)');
        return;
      }

      final stats = profile.stats!;
      TestHelper.printSuccess('Stats retrieved, validating activity...');

      // Verify recentActivity is a list
      expect(stats.recentActivity, isA<List<ActivityData>>());
      TestHelper.printSuccess(
        '✓ recentActivity is List: ${stats.recentActivity.length} items',
      );

      // Validate each activity item
      for (var i = 0; i < stats.recentActivity.length && i < 10; i++) {
        final activity = stats.recentActivity[i];

        TestHelper.printStep('Validating activity $i...');

        expect(activity.type, isA<String>());
        expect(activity.title, isA<String>());
        expect(activity.timestamp, isA<DateTime>());
        expect(activity.score, anyOf(isA<int>(), isNull));

        TestHelper.printSuccess(
          '  ✓ ${activity.type}: ${activity.title} (Score: ${activity.score})',
        );
      }

      TestHelper.printSuccess('All activity items have correct types');
    });

    test('3.4. Activity timestamp validation', () async {
      TestHelper.printSection('TEST 3.4: ACTIVITY TIMESTAMP VALIDATION');

      TestHelper.printStep('Fetching profile with stats...');
      final profile = await profileApiService.getProfileWithStats();

      if (profile.stats == null || profile.stats!.recentActivity.isEmpty) {
        TestHelper.printStep('No activity data available (this is OK)');
        return;
      }

      final activities = profile.stats!.recentActivity;
      TestHelper.printSuccess('Validating ${activities.length} activities...');

      final now = DateTime.now();

      for (var activity in activities) {
        // Timestamps should be in the past
        expect(activity.timestamp.isBefore(now), true);
        TestHelper.printSuccess(
          '✓ ${activity.type} timestamp is valid: ${activity.timestamp}',
        );
      }

      TestHelper.printSuccess('All activity timestamps are valid');
    });
  });

  group('4. Profile Update Type Casting Tests -', () {
    setUpAll(() async {
      // Ensure authentication
      await AuthHelper.setupAuth();
    });

    test('4.1. Update profile with valid data', () async {
      TestHelper.printSection('TEST 4.1: UPDATE PROFILE VALIDATION');

      // Get current profile
      TestHelper.printStep('Fetching current profile...');
      final currentProfile = await profileApiService.getProfile();

      TestHelper.printSuccess('Current profile:');
      TestHelper.printSuccess('  Name: ${currentProfile.name}');
      TestHelper.printSuccess('  Email: ${currentProfile.email}');

      // Update with same values (safe test)
      TestHelper.printStep('Updating profile...');
      final request = UpdateProfileRequest(
        name: currentProfile.name ?? 'Test User',
      );

      final updatedProfile = await profileApiService.updateProfile(request);

      TestHelper.printSuccess('Profile updated successfully');
      TestHelper.printSuccess('Updated name: ${updatedProfile.name}');
      TestHelper.printSuccess('Updated email: ${updatedProfile.email}');

      // Verify types in response
      expect(updatedProfile.id, isA<int>());
      expect(updatedProfile.email, isA<String>());
      expect(updatedProfile.name, anyOf(isA<String>(), isNull));
      expect(updatedProfile.role, isA<String>());

      TestHelper.printSuccess('Update response has correct types');
    });

    test('4.2. Updated profile maintains data integrity', () async {
      TestHelper.printSection('TEST 4.2: UPDATE DATA INTEGRITY');

      // Get current profile
      TestHelper.printStep('Fetching current profile...');
      final profile1 = await profileApiService.getProfile();

      // Update (with same values)
      TestHelper.printStep('Updating profile...');
      final request = UpdateProfileRequest(name: profile1.name ?? 'Test User');
      final updatedProfile = await profileApiService.updateProfile(request);

      // Fetch again to verify
      TestHelper.printStep('Fetching profile again...');
      final profile2 = await profileApiService.getProfile();

      TestHelper.printSuccess('Validating consistency...');

      // ID should remain the same
      expect(profile2.id, equals(profile1.id));
      TestHelper.printSuccess('✓ ID unchanged: ${profile2.id}');

      // Role should remain the same (can't change via profile update)
      expect(profile2.role, equals(profile1.role));
      TestHelper.printSuccess('✓ Role unchanged: ${profile2.role}');

      // Updated fields should match
      expect(profile2.email, equals(updatedProfile.email));
      expect(profile2.name, equals(updatedProfile.name));
      TestHelper.printSuccess('✓ Updated fields are consistent');

      TestHelper.printSuccess('Data integrity maintained');
    });
  });

  group('5. Error Handling Tests -', () {
    setUpAll(() async {
      // Ensure authentication
      await AuthHelper.setupAuth();
    });

    test('5.1. Handle stats fetch failure gracefully', () async {
      TestHelper.printSection('TEST 5.1: STATS FETCH FAILURE HANDLING');

      TestHelper.printStep('Fetching profile with stats...');

      try {
        final profile = await profileApiService.getProfileWithStats();

        // Should return profile even if stats fail
        expect(profile.id, greaterThan(0));
        expect(profile.email, isNotEmpty);

        if (profile.stats == null) {
          TestHelper.printSuccess('✓ Gracefully handled missing stats');
        } else {
          TestHelper.printSuccess('✓ Stats available');
        }
      } catch (e) {
        TestHelper.printError('Unexpected error: $e');
        fail('Should not throw on stats failure');
      }
    });

    test('5.2. Multiple consecutive requests', () async {
      TestHelper.printSection('TEST 5.2: MULTIPLE CONSECUTIVE REQUESTS');

      TestHelper.printStep('Making 5 consecutive profile requests...');

      for (int i = 1; i <= 5; i++) {
        TestHelper.printStep('Request $i/5');

        final profile = await profileApiService.getProfile();
        expect(profile.id, greaterThan(0));

        await Future.delayed(const Duration(milliseconds: 200));
      }

      TestHelper.printSuccess('All requests completed successfully');
    });

    test('5.3. Profile data consistency across calls', () async {
      TestHelper.printSection('TEST 5.3: DATA CONSISTENCY');

      TestHelper.printStep('Fetching profile multiple times...');

      final profile1 = await profileApiService.getProfile();
      await Future.delayed(const Duration(milliseconds: 500));
      final profile2 = await profileApiService.getProfile();

      TestHelper.printSuccess('Comparing profiles...');

      expect(profile1.id, equals(profile2.id));
      expect(profile1.email, equals(profile2.email));
      expect(profile1.role, equals(profile2.role));

      TestHelper.printSuccess('Profile data is consistent');
    });
  });

  group('6. Complete Profile Workflow Tests -', () {
    setUpAll(() async {
      // Ensure authentication
      await AuthHelper.setupAuth();
    });

    test('6.1. Complete profile workflow', () async {
      TestHelper.printSection('TEST 6.1: COMPLETE PROFILE WORKFLOW');

      // Step 1: Get basic profile
      TestHelper.printStep('1. Fetching basic profile...');
      final profile = await profileApiService.getProfile();
      TestHelper.printSuccess('Basic profile loaded');
      TestHelper.printSuccess('  ID: ${profile.id}');
      TestHelper.printSuccess('  Email: ${profile.email}');
      TestHelper.printSuccess('  Name: ${profile.name}');

      // Step 2: Get profile with stats
      TestHelper.printStep('2. Fetching profile with statistics...');
      final profileWithStats = await profileApiService.getProfileWithStats();
      TestHelper.printSuccess('Profile with stats loaded');

      if (profileWithStats.stats != null) {
        final stats = profileWithStats.stats!;
        TestHelper.printSuccess('  Kanji studied: ${stats.totalKanjiStudied}');
        TestHelper.printSuccess('  Quizzes: ${stats.quizzesCompleted}');
        TestHelper.printSuccess('  Streak: ${stats.currentStreak}');
        TestHelper.printSuccess('  XP: ${stats.totalXp}');
      }

      // Step 3: Update profile (safe update)
      TestHelper.printStep('3. Updating profile...');
      final updateRequest = UpdateProfileRequest(
        name: profile.name ?? 'Test User',
      );
      final updatedProfile = await profileApiService.updateProfile(
        updateRequest,
      );
      TestHelper.printSuccess('Profile updated');

      // Step 4: Verify consistency
      TestHelper.printStep('4. Verifying data consistency...');
      expect(updatedProfile.id, equals(profile.id));
      expect(updatedProfile.role, equals(profile.role));
      TestHelper.printSuccess('Data is consistent');

      TestHelper.printSuccess('Complete workflow executed successfully');
    });

    test('6.2. Type safety throughout workflow', () async {
      TestHelper.printSection('TEST 6.2: TYPE SAFETY VALIDATION');

      TestHelper.printStep('Executing full workflow with type checks...');

      // Get profile
      final profile = await profileApiService.getProfile();

      // Verify all types
      expect(profile.id, isA<int>());
      expect(profile.email, isA<String>());
      expect(profile.role, isA<String>());
      expect(profile.twoFactorEnabled, isA<bool>());

      TestHelper.printSuccess('✓ Basic profile types correct');

      // Get stats
      final profileWithStats = await profileApiService.getProfileWithStats();

      if (profileWithStats.stats != null) {
        final stats = profileWithStats.stats!;

        expect(stats.totalKanjiStudied, isA<int>());
        expect(stats.quizzesCompleted, isA<int>());
        expect(stats.flashcardsReviewed, isA<int>());
        expect(stats.currentStreak, isA<int>());
        expect(stats.totalXp, isA<int>());
        expect(stats.averageScore, isA<double>());
        expect(stats.recentActivity, isA<List<ActivityData>>());

        TestHelper.printSuccess('✓ Stats types correct');
      }

      // Update profile
      final request = UpdateProfileRequest(name: profile.name ?? 'Test');
      final updated = await profileApiService.updateProfile(request);

      expect(updated.id, isA<int>());
      expect(updated.email, isA<String>());

      TestHelper.printSuccess('✓ Update response types correct');

      TestHelper.printSuccess('All types are correct throughout workflow');
    });
  });

  tearDownAll(() async {
    TestHelper.printSection('CLEANING UP PROFILE TESTS');
    TestHelper.printSuccess('All profile integration tests completed');
  });
}
