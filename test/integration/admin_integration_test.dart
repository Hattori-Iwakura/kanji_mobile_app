import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/core/network/api_client.dart';
import 'package:kanji_mobile_app/features/admin/services/admin_api_service.dart';
import 'package:kanji_mobile_app/features/admin/models/admin_models.dart';
import 'package:kanji_mobile_app/features/kanji/domain/usecases/create_kanji.dart';
import 'package:kanji_mobile_app/features/kanji/domain/usecases/update_kanji.dart';
import 'package:kanji_mobile_app/features/kanji/domain/usecases/delete_kanji.dart';
import 'package:kanji_mobile_app/injection_container.dart' as di;
import '../helpers/test_helper.dart';
import '../helpers/auth_helper.dart';

void main() {
  late AdminApiService adminService;

  setUpAll(() async {
    TestHelper.printSection('INITIALIZING ADMIN INTEGRATION TESTS');
    await TestHelper.initializeDependencies();
    TestHelper.printSuccess('Dependencies initialized');

    // Initialize admin service
    final apiClient = di.sl<ApiClient>();
    adminService = AdminApiService(apiClient);
  });

  group('1. Admin Authentication Tests -', () {
    test('1.1. Non-admin user cannot access admin endpoints', () async {
      TestHelper.printSection('TEST 1.1: NON-ADMIN ACCESS DENIED');

      // Login with regular test user (not admin)
      TestHelper.printStep('Logging in as regular user...');
      await AuthHelper.setupAuth();

      TestHelper.printStep('Attempting to access admin dashboard...');

      try {
        await adminService.getDashboardOverview();
        TestHelper.printError('Should not allow non-admin access');
        fail('Non-admin user should not access admin endpoints');
      } catch (e) {
        TestHelper.printSuccess('Access denied (as expected)');
        TestHelper.printSuccess('Error: ${e.toString()}');
        expect(
          e.toString().toLowerCase(),
          anyOf(
            contains('admin'),
            contains('forbidden'),
            contains('403'),
            contains('unauthorized'),
          ),
        );
      } finally {
        // Clear auth to avoid token caching issues
        AuthHelper.clearAuth();
      }
    });

    test('1.2. Admin user can access admin endpoints', () async {
      TestHelper.printSection('TEST 1.2: ADMIN ACCESS GRANTED');

      // Login with admin user
      TestHelper.printStep('Logging in as admin...');
      final token = await AuthHelper.loginForTesting(
        account: 'admin@gmail.com',
        password: 'Admin@12345',
      );

      // Save token
      final apiClient = di.sl<ApiClient>();
      apiClient.setAuthToken(token);

      TestHelper.printStep('Attempting to access admin dashboard...');

      try {
        final overview = await adminService.getDashboardOverview();

        TestHelper.printSuccess('Access granted');
        TestHelper.printSuccess('Total users: ${overview.users.total}');
        TestHelper.printSuccess(
          'Total content items: ${overview.content.quizzes + overview.content.lists + overview.content.decks}',
        );

        expect(overview.users.total, greaterThan(0));
      } catch (e) {
        TestHelper.printError('Admin access failed: $e');
        fail('Admin user should access admin endpoints');
      }
    });

    test('1.3. Unauthenticated access denied', () async {
      TestHelper.printSection('TEST 1.3: UNAUTHENTICATED ACCESS DENIED');

      // Clear token
      TestHelper.printStep('Clearing authentication...');
      final apiClient = di.sl<ApiClient>();
      apiClient.clearAuthToken();

      TestHelper.printStep('Attempting to access without token...');

      try {
        await adminService.getDashboardOverview();
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

      // Re-authenticate as admin for next tests
      final token = await AuthHelper.loginForTesting(
        account: 'admin@gmail.com',
        password: 'Admin@12345',
      );
      apiClient.setAuthToken(token);
    });
  });

  group('2. Dashboard Statistics Tests -', () {
    setUpAll(() async {
      // Ensure admin authentication
      final token = await AuthHelper.loginForTesting(
        account: 'admin@gmail.com',
        password: 'Admin@12345',
      );
      final apiClient = di.sl<ApiClient>();
      apiClient.setAuthToken(token);
    });

    test('2.1. Get dashboard overview', () async {
      TestHelper.printSection('TEST 2.1: GET DASHBOARD OVERVIEW');

      TestHelper.printStep('Fetching dashboard overview...');

      final overview = await adminService.getDashboardOverview();

      TestHelper.printSuccess('Dashboard overview retrieved');
      TestHelper.printSuccess('Users: ${overview.users.total}');
      TestHelper.printSuccess('  - Active: ${overview.users.active}');
      TestHelper.printSuccess('  - New: ${overview.users.newUsers}');
      TestHelper.printSuccess('Content:');
      TestHelper.printSuccess('  - Kanji: ${overview.content.kanji}');
      TestHelper.printSuccess('  - Quizzes: ${overview.content.quizzes}');
      TestHelper.printSuccess('  - Lists: ${overview.content.lists}');
      TestHelper.printSuccess('  - Decks: ${overview.content.decks}');
      TestHelper.printSuccess('Activity:');
      TestHelper.printSuccess(
        '  - Active Users: ${overview.activity.activeUsers}',
      );
      TestHelper.printSuccess(
        '  - Pending Requests: ${overview.activity.pendingPublishRequests}',
      );
      TestHelper.printSuccess(
        '  - Recent Requests: ${overview.activity.recentPublishRequests}',
      );

      expect(overview.users.total, greaterThan(0));
      expect(overview.content.kanji, greaterThan(0));
      expect(overview.activity.activeUsers, greaterThanOrEqualTo(0));
    });

    test('2.2. Get publish statistics', () async {
      TestHelper.printSection('TEST 2.2: GET PUBLISH STATISTICS');

      TestHelper.printStep('Fetching publish statistics...');

      final stats = await adminService.getPublishStatistics();

      TestHelper.printSuccess('Publish statistics retrieved');
      TestHelper.printSuccess('Total: ${stats.total}');
      TestHelper.printSuccess('Pending: ${stats.pending}');
      TestHelper.printSuccess('Approved: ${stats.approved}');
      TestHelper.printSuccess('By Type:');
      TestHelper.printSuccess(
        '  - Quiz: ${stats.byType.quiz.total} (${stats.byType.quiz.pending} pending)',
      );
      TestHelper.printSuccess(
        '  - List: ${stats.byType.list.total} (${stats.byType.list.pending} pending)',
      );
      TestHelper.printSuccess(
        '  - Deck: ${stats.byType.deck.total} (${stats.byType.deck.pending} pending)',
      );

      expect(stats.total, greaterThanOrEqualTo(0));
      expect(stats.pending, greaterThanOrEqualTo(0));
      expect(stats.approved, greaterThanOrEqualTo(0));
      expect(stats.total, equals(stats.pending + stats.approved));
    });

    test('2.3. Get system health', () async {
      TestHelper.printSection('TEST 2.3: GET SYSTEM HEALTH');

      TestHelper.printStep('Checking system health...');

      final health = await adminService.getSystemHealth();

      TestHelper.printSuccess('System health retrieved');
      TestHelper.printSuccess('Status: ${health.status}');
      TestHelper.printSuccess('Database: ${health.database}');
      TestHelper.printSuccess('Timestamp: ${health.timestamp}');
      if (health.checks != null) {
        TestHelper.printSuccess('Checks: ${health.checks}');
      }

      expect(health.status, isIn(['healthy', 'unhealthy']));
      expect(health.database, isIn(['connected', 'disconnected']));
      expect(health.isHealthy, isA<bool>());

      if (health.isHealthy) {
        TestHelper.printSuccess('✓ System is healthy');
      } else {
        TestHelper.printError('✗ System has issues');
      }
    });

    test('2.4. Statistics consistency check', () async {
      TestHelper.printSection('TEST 2.4: STATISTICS CONSISTENCY');

      TestHelper.printStep('Fetching all statistics...');

      final overview = await adminService.getDashboardOverview();
      final publishStats = await adminService.getPublishStatistics();

      TestHelper.printSuccess('Checking consistency...');

      // Check that pending requests match
      final overviewPending = overview.activity.pendingPublishRequests;
      final statsPending = publishStats.pending;

      TestHelper.printStep('Overview pending: $overviewPending');
      TestHelper.printStep('Stats pending: $statsPending');

      expect(
        overviewPending,
        equals(statsPending),
        reason: 'Pending requests should match across endpoints',
      );

      TestHelper.printSuccess('Statistics are consistent');
    });
  });

  group('3. Publish Request Management Tests -', () {
    setUpAll(() async {
      // Ensure admin authentication
      final token = await AuthHelper.loginForTesting(
        account: 'admin@gmail.com',
        password: 'Admin@12345',
      );
      final apiClient = di.sl<ApiClient>();
      apiClient.setAuthToken(token);
    });

    test('3.1. Get all publish requests', () async {
      TestHelper.printSection('TEST 3.1: GET ALL PUBLISH REQUESTS');

      TestHelper.printStep('Fetching all publish requests...');

      final response = await adminService.getPublishRequests();

      TestHelper.printSuccess('Requests retrieved');
      TestHelper.printSuccess('Total: ${response.total}');
      TestHelper.printSuccess('Returned: ${response.requests.length}');

      if (response.requests.isNotEmpty) {
        final first = response.requests.first;
        TestHelper.printSuccess('First request:');
        TestHelper.printSuccess('  - ID: ${first.id}');
        TestHelper.printSuccess('  - Type: ${first.typeLabel}');
        TestHelper.printSuccess('  - Title: ${first.title}');
        TestHelper.printSuccess('  - Status: ${first.status}');
        TestHelper.printSuccess('  - Created: ${first.createdAt}');
      }

      expect(response.total, greaterThanOrEqualTo(0));
      expect(response.requests.length, lessThanOrEqualTo(20)); // Default limit
    });

    test('3.2. Filter by status - pending', () async {
      TestHelper.printSection('TEST 3.2: FILTER BY STATUS - PENDING');

      TestHelper.printStep('Fetching pending requests...');

      final response = await adminService.getPublishRequests(status: 'pending');

      TestHelper.printSuccess('Pending requests: ${response.requests.length}');

      // Verify all returned requests are pending
      for (final request in response.requests) {
        expect(
          request.status,
          equals('pending'),
          reason: 'All requests should have pending status',
        );
      }

      TestHelper.printSuccess('All requests have pending status');
    });

    test('3.3. Filter by status - approved', () async {
      TestHelper.printSection('TEST 3.3: FILTER BY STATUS - APPROVED');

      TestHelper.printStep('Fetching approved requests...');

      final response = await adminService.getPublishRequests(
        status: 'approved',
      );

      TestHelper.printSuccess('Approved requests: ${response.requests.length}');

      // Verify all returned requests are approved
      for (final request in response.requests) {
        expect(
          request.status,
          equals('approved'),
          reason: 'All requests should have approved status',
        );
      }

      TestHelper.printSuccess('All requests have approved status');
    });

    test('3.4. Filter by type - quiz', () async {
      TestHelper.printSection('TEST 3.4: FILTER BY TYPE - QUIZ');

      TestHelper.printStep('Fetching quiz requests...');

      final response = await adminService.getPublishRequests(type: 'quiz');

      TestHelper.printSuccess('Quiz requests: ${response.requests.length}');

      // Verify all returned requests are quizzes
      for (final request in response.requests) {
        expect(
          request.type,
          equals('quiz'),
          reason: 'All requests should be quiz type',
        );
      }

      TestHelper.printSuccess('All requests are quiz type');
    });

    test('3.5. Filter by type - list', () async {
      TestHelper.printSection('TEST 3.5: FILTER BY TYPE - LIST');

      TestHelper.printStep('Fetching list requests...');

      final response = await adminService.getPublishRequests(type: 'list');

      TestHelper.printSuccess('List requests: ${response.requests.length}');

      // Verify all returned requests are lists
      for (final request in response.requests) {
        expect(
          request.type,
          equals('list'),
          reason: 'All requests should be list type',
        );
      }

      TestHelper.printSuccess('All requests are list type');
    });

    test('3.6. Filter by type - deck', () async {
      TestHelper.printSection('TEST 3.6: FILTER BY TYPE - DECK');

      TestHelper.printStep('Fetching deck requests...');

      final response = await adminService.getPublishRequests(type: 'deck');

      TestHelper.printSuccess('Deck requests: ${response.requests.length}');

      // Verify all returned requests are decks
      for (final request in response.requests) {
        expect(
          request.type,
          equals('deck'),
          reason: 'All requests should be deck type',
        );
      }

      TestHelper.printSuccess('All requests are deck type');
    });

    test('3.7. Combined filters - pending quizzes', () async {
      TestHelper.printSection('TEST 3.7: COMBINED FILTERS - PENDING QUIZZES');

      TestHelper.printStep('Fetching pending quiz requests...');

      final response = await adminService.getPublishRequests(
        status: 'pending',
        type: 'quiz',
      );

      TestHelper.printSuccess(
        'Pending quiz requests: ${response.requests.length}',
      );

      // Verify all returned requests match both filters
      for (final request in response.requests) {
        expect(request.status, equals('pending'));
        expect(request.type, equals('quiz'));
      }

      TestHelper.printSuccess('All requests are pending quizzes');
    });

    test('3.8. Pagination - limit', () async {
      TestHelper.printSection('TEST 3.8: PAGINATION - LIMIT');

      TestHelper.printStep('Fetching with limit=5...');

      final response = await adminService.getPublishRequests(limit: 5);

      TestHelper.printSuccess('Requests returned: ${response.requests.length}');
      TestHelper.printSuccess('Total available: ${response.total}');

      expect(response.requests.length, lessThanOrEqualTo(5));

      TestHelper.printSuccess('Pagination limit working');
    });

    test('3.9. Pagination - offset', () async {
      TestHelper.printSection('TEST 3.9: PAGINATION - OFFSET');

      // Get first page
      TestHelper.printStep('Fetching first page (limit=3)...');
      final firstPage = await adminService.getPublishRequests(limit: 3);

      if (firstPage.total > 3) {
        // Get second page
        TestHelper.printStep('Fetching second page (offset=3, limit=3)...');
        final secondPage = await adminService.getPublishRequests(
          limit: 3,
          offset: 3,
        );

        TestHelper.printSuccess(
          'First page: ${firstPage.requests.length} items',
        );
        TestHelper.printSuccess(
          'Second page: ${secondPage.requests.length} items',
        );

        // Verify pages don't overlap
        if (firstPage.requests.isNotEmpty && secondPage.requests.isNotEmpty) {
          final firstPageIds = firstPage.requests.map((r) => r.id).toSet();
          final secondPageIds = secondPage.requests.map((r) => r.id).toSet();

          expect(
            firstPageIds.intersection(secondPageIds).isEmpty,
            true,
            reason: 'Pages should not overlap',
          );
        }

        TestHelper.printSuccess('Pagination offset working');
      } else {
        TestHelper.printStep('Not enough data for pagination test');
      }
    });
  });

  group('4. Publish Request Detail Tests -', () {
    PublishRequest? testRequest;

    setUpAll(() async {
      // Ensure admin authentication
      final token = await AuthHelper.loginForTesting(
        account: 'admin@gmail.com',
        password: 'Admin@12345',
      );
      final apiClient = di.sl<ApiClient>();
      apiClient.setAuthToken(token);

      // Get a test request
      final response = await adminService.getPublishRequests();
      if (response.requests.isNotEmpty) {
        testRequest = response.requests.first;
      }
    });

    test('4.1. Get request detail by ID', () async {
      TestHelper.printSection('TEST 4.1: GET REQUEST DETAIL BY ID');

      if (testRequest == null) {
        TestHelper.printStep('No requests available for detail test');
        return;
      }

      TestHelper.printStep('Fetching request ${testRequest!.id}...');

      final detail = await adminService.getPublishRequestById(
        testRequest!.id,
        testRequest!.type,
      );

      TestHelper.printSuccess('Request detail retrieved');
      TestHelper.printSuccess('ID: ${detail.id}');
      TestHelper.printSuccess('Type: ${detail.typeLabel}');
      TestHelper.printSuccess('Title: ${detail.title}');
      TestHelper.printSuccess('Status: ${detail.status}');
      TestHelper.printSuccess('Created: ${detail.createdAt}');

      if (detail.user != null) {
        TestHelper.printSuccess('Creator: ${detail.user!.email}');
      }

      if (detail.reviewedAt != null) {
        TestHelper.printSuccess('Reviewed: ${detail.reviewedAt}');
        if (detail.reviewer != null) {
          TestHelper.printSuccess('Reviewer: ${detail.reviewer!.email}');
        }
      }

      expect(detail.id, equals(testRequest!.id));
      expect(detail.type, equals(testRequest!.type));
    });

    test('4.2. Request detail has full content', () async {
      TestHelper.printSection('TEST 4.2: REQUEST DETAIL HAS FULL CONTENT');

      if (testRequest == null) {
        TestHelper.printStep('No requests available for content test');
        return;
      }

      TestHelper.printStep('Fetching full request detail...');

      final detail = await adminService.getPublishRequestById(
        testRequest!.id,
        testRequest!.type,
      );

      TestHelper.printStep('Checking content details...');

      switch (detail.type) {
        case 'quiz':
          if (detail.quiz != null) {
            final quiz = detail.quiz as Map<String, dynamic>;
            TestHelper.printSuccess('Quiz content found');
            TestHelper.printSuccess('  - Title: ${quiz['title']}');
            TestHelper.printSuccess('  - Difficulty: ${quiz['difficulty']}');
            if (quiz['questions'] != null) {
              TestHelper.printSuccess(
                '  - Questions: ${(quiz['questions'] as List).length}',
              );
            }
            expect(quiz['title'], isNotNull);
          }
          break;
        case 'list':
          if (detail.list != null) {
            TestHelper.printSuccess('List content found');
          }
          break;
        case 'deck':
          if (detail.deck != null) {
            TestHelper.printSuccess('Deck content found');
          }
          break;
      }

      TestHelper.printSuccess('Content details available');
    });

    test('4.3. Get non-existent request', () async {
      TestHelper.printSection('TEST 4.3: GET NON-EXISTENT REQUEST');

      TestHelper.printStep('Attempting to fetch non-existent request...');

      try {
        await adminService.getPublishRequestById(999999, 'quiz');
        TestHelper.printError('Should not find non-existent request');
        fail('Non-existent request should throw error');
      } catch (e) {
        TestHelper.printSuccess('Error thrown (as expected)');
        TestHelper.printSuccess('Error: ${e.toString()}');
        expect(
          e.toString().toLowerCase(),
          anyOf(contains('not found'), contains('404')),
        );
      }
    });

    test('4.4. Get request with invalid type', () async {
      TestHelper.printSection('TEST 4.4: GET REQUEST WITH INVALID TYPE');

      if (testRequest == null) {
        TestHelper.printStep('No requests available for invalid type test');
        return;
      }

      TestHelper.printStep('Attempting with invalid type...');

      try {
        await adminService.getPublishRequestById(
          testRequest!.id,
          'invalid_type',
        );
        TestHelper.printError('Should not accept invalid type');
        fail('Invalid type should throw error');
      } catch (e) {
        TestHelper.printSuccess('Error thrown (as expected)');
        TestHelper.printSuccess('Error: ${e.toString()}');
      }
    });
  });

  group('5. Publish Request Review Tests -', () {
    PublishRequest? pendingRequest;

    setUpAll(() async {
      // Ensure admin authentication
      final token = await AuthHelper.loginForTesting(
        account: 'admin@gmail.com',
        password: 'Admin@12345',
      );
      final apiClient = di.sl<ApiClient>();
      apiClient.setAuthToken(token);

      // Try to find a pending request
      final response = await adminService.getPublishRequests(status: 'pending');
      if (response.requests.isNotEmpty) {
        pendingRequest = response.requests.first;
      }
    });

    test('5.1. Approve publish request', () async {
      TestHelper.printSection('TEST 5.1: APPROVE PUBLISH REQUEST');

      if (pendingRequest == null) {
        TestHelper.printStep('No pending requests available for approval test');
        TestHelper.printStep(
          'This is expected if all requests are already reviewed',
        );
        return;
      }

      TestHelper.printStep('Approving request ${pendingRequest!.id}...');
      TestHelper.printStep('Type: ${pendingRequest!.typeLabel}');
      TestHelper.printStep('Title: ${pendingRequest!.title}');

      final reviewed = await adminService.reviewPublishRequest(
        id: pendingRequest!.id,
        type: pendingRequest!.type,
        status: 'approved',
        reviewMessage: 'Approved by integration test',
      );

      TestHelper.printSuccess('Request approved');
      TestHelper.printSuccess('New status: ${reviewed.status}');
      TestHelper.printSuccess('Reviewed at: ${reviewed.reviewedAt}');

      expect(reviewed.status, equals('approved'));
      expect(reviewed.reviewedAt, isNotNull);
      expect(reviewed.reviewedBy, isNotNull);

      // Clear for next test
      pendingRequest = null;
    });

    test('5.2. Reject publish request', () async {
      TestHelper.printSection('TEST 5.2: REJECT PUBLISH REQUEST');

      // Get a new pending request
      final response = await adminService.getPublishRequests(status: 'pending');

      if (response.requests.isEmpty) {
        TestHelper.printStep(
          'No pending requests available for rejection test',
        );
        TestHelper.printStep(
          'This is expected if all requests are already reviewed',
        );
        return;
      }

      final requestToReject = response.requests.first;

      TestHelper.printStep('Rejecting request ${requestToReject.id}...');
      TestHelper.printStep('Type: ${requestToReject.typeLabel}');
      TestHelper.printStep('Title: ${requestToReject.title}');

      final reviewed = await adminService.reviewPublishRequest(
        id: requestToReject.id,
        type: requestToReject.type,
        status: 'rejected',
        reviewMessage: 'Rejected by integration test',
      );

      TestHelper.printSuccess('Request rejected');
      TestHelper.printSuccess('New status: ${reviewed.status}');
      TestHelper.printSuccess('Review message: ${reviewed.reviewMessage}');

      expect(reviewed.status, equals('rejected'));
      expect(reviewed.reviewedAt, isNotNull);
      expect(reviewed.reviewMessage, equals('Rejected by integration test'));
    });

    test('5.3. Review with custom message', () async {
      TestHelper.printSection('TEST 5.3: REVIEW WITH CUSTOM MESSAGE');

      // Get a pending request
      final response = await adminService.getPublishRequests(status: 'pending');

      if (response.requests.isEmpty) {
        TestHelper.printStep('No pending requests available');
        return;
      }

      final requestToReview = response.requests.first;
      final customMessage =
          'Test message ${DateTime.now().millisecondsSinceEpoch}';

      TestHelper.printStep('Reviewing with message: $customMessage');

      final reviewed = await adminService.reviewPublishRequest(
        id: requestToReview.id,
        type: requestToReview.type,
        status: 'approved',
        reviewMessage: customMessage,
      );

      TestHelper.printSuccess('Request reviewed with custom message');
      TestHelper.printSuccess('Message: ${reviewed.reviewMessage}');

      expect(reviewed.reviewMessage, equals(customMessage));
    });

    test('5.4. Review non-existent request', () async {
      TestHelper.printSection('TEST 5.4: REVIEW NON-EXISTENT REQUEST');

      TestHelper.printStep('Attempting to review non-existent request...');

      try {
        await adminService.reviewPublishRequest(
          id: 999999,
          type: 'quiz',
          status: 'approved',
        );
        TestHelper.printError('Should not review non-existent request');
        fail('Non-existent request review should fail');
      } catch (e) {
        TestHelper.printSuccess('Error thrown (as expected)');
        TestHelper.printSuccess('Error: ${e.toString()}');
        expect(
          e.toString().toLowerCase(),
          anyOf(contains('not found'), contains('404')),
        );
      }
    });

    test('5.5. Review with invalid status', () async {
      TestHelper.printSection('TEST 5.5: REVIEW WITH INVALID STATUS');

      // Get a pending request
      final response = await adminService.getPublishRequests(status: 'pending');

      if (response.requests.isEmpty) {
        TestHelper.printStep('No pending requests available');
        return;
      }

      final requestToReview = response.requests.first;

      TestHelper.printStep('Attempting with invalid status...');

      try {
        await adminService.reviewPublishRequest(
          id: requestToReview.id,
          type: requestToReview.type,
          status: 'invalid_status',
        );
        TestHelper.printError('Should not accept invalid status');
        fail('Invalid status should be rejected');
      } catch (e) {
        TestHelper.printSuccess('Error thrown (as expected)');
        TestHelper.printSuccess('Error: ${e.toString()}');
      }
    });
  });

  group('6. Admin Kanji CRUD Tests -', () {
    late CreateKanji createKanji;
    late UpdateKanji updateKanji;
    late DeleteKanji deleteKanji;
    int? createdKanjiId;

    setUpAll(() async {
      // Ensure admin authentication
      final token = await AuthHelper.loginForTesting(
        account: 'admin@gmail.com',
        password: 'Admin@12345',
      );
      final apiClient = di.sl<ApiClient>();
      apiClient.setAuthToken(token);

      // Initialize use cases
      createKanji = di.sl<CreateKanji>();
      updateKanji = di.sl<UpdateKanji>();
      deleteKanji = di.sl<DeleteKanji>();
    });

    test('6.1. Create new kanji', () async {
      TestHelper.printSection('TEST 6.1: CREATE NEW KANJI');

      TestHelper.printStep('Creating test kanji...');

      final params = CreateKanjiParams(
        character: '測',
        meanings: 'measure, test, survey',
        onReadings: 'ソク',
        kunReadings: 'はか.る',
        jlptLevel: 2,
        grade: 5,
        strokeCount: 12,
        frequency: 500,
        tags: ['test', 'admin'],
      );

      final result = await createKanji(params);

      result.fold(
        (failure) {
          TestHelper.printError('Failed to create kanji: $failure');
          fail('Should create kanji successfully');
        },
        (kanji) {
          createdKanjiId = kanji.id;
          TestHelper.printSuccess('Kanji created successfully');
          TestHelper.printSuccess('ID: ${kanji.id}');
          TestHelper.printSuccess('Character: ${kanji.character}');
          TestHelper.printSuccess('Meanings: ${kanji.meanings}');
          TestHelper.printSuccess('JLPT: ${kanji.jlpt}');
          TestHelper.printSuccess('Grade: ${kanji.grade}');

          expect(kanji.character, equals('測'));
          expect(kanji.meanings, contains('measure'));
          expect(kanji.jlpt, equals(2));
          expect(kanji.grade, equals(5));
          expect(kanji.strokeCount, equals(12));
        },
      );
    });

    test('6.2. Update existing kanji', () async {
      TestHelper.printSection('TEST 6.2: UPDATE EXISTING KANJI');

      if (createdKanjiId == null) {
        TestHelper.printError('No kanji created yet, skipping test');
        return;
      }

      TestHelper.printStep('Updating kanji ID: $createdKanjiId');

      final params = UpdateKanjiParams(
        id: createdKanjiId!,
        meanings: 'measure, test, survey, gauge',
        frequency: 450,
        tags: ['test', 'admin', 'updated'],
      );

      final result = await updateKanji(params);

      result.fold(
        (failure) {
          TestHelper.printError('Failed to update kanji: $failure');
          fail('Should update kanji successfully');
        },
        (kanji) {
          TestHelper.printSuccess('Kanji updated successfully');
          TestHelper.printSuccess('ID: ${kanji.id}');
          TestHelper.printSuccess('Updated meanings: ${kanji.meanings}');
          TestHelper.printSuccess('Updated frequency: ${kanji.frequency}');

          expect(kanji.id, equals(createdKanjiId));
          expect(kanji.meanings, contains('gauge'));
          expect(kanji.frequency, equals(450));
        },
      );
    });

    test('6.3. Update kanji with partial data', () async {
      TestHelper.printSection('TEST 6.3: PARTIAL UPDATE KANJI');

      if (createdKanjiId == null) {
        TestHelper.printError('No kanji created yet, skipping test');
        return;
      }

      TestHelper.printStep('Updating only JLPT level...');

      final params = UpdateKanjiParams(
        id: createdKanjiId!,
        jlptLevel: 1, // Upgrade from N2 to N1
      );

      final result = await updateKanji(params);

      result.fold(
        (failure) {
          TestHelper.printError('Failed to update kanji: $failure');
          fail('Should update kanji successfully');
        },
        (kanji) {
          TestHelper.printSuccess('Partial update successful');
          TestHelper.printSuccess('Updated JLPT: ${kanji.jlpt}');
          TestHelper.printSuccess('Character unchanged: ${kanji.character}');

          expect(kanji.id, equals(createdKanjiId));
          expect(kanji.jlpt, equals(1));
          expect(kanji.character, equals('測')); // Should remain unchanged
        },
      );
    });

    test('6.4. Delete kanji', () async {
      TestHelper.printSection('TEST 6.4: DELETE KANJI');

      if (createdKanjiId == null) {
        TestHelper.printError('No kanji created yet, skipping test');
        return;
      }

      TestHelper.printStep('Deleting kanji ID: $createdKanjiId');

      final result = await deleteKanji(createdKanjiId!);

      result.fold(
        (failure) {
          TestHelper.printError('Failed to delete kanji: $failure');
          fail('Should delete kanji successfully');
        },
        (_) {
          TestHelper.printSuccess('Kanji deleted successfully');
          TestHelper.printSuccess('Deleted ID: $createdKanjiId');
        },
      );
    });

    test('6.5. Update non-existent kanji should fail', () async {
      TestHelper.printSection('TEST 6.5: UPDATE NON-EXISTENT KANJI');

      TestHelper.printStep('Attempting to update non-existent kanji...');

      final params = UpdateKanjiParams(id: 999999, meanings: 'should fail');

      final result = await updateKanji(params);

      result.fold(
        (failure) {
          TestHelper.printSuccess('Error thrown (as expected)');
          TestHelper.printSuccess('Failure: ${failure.toString()}');
        },
        (kanji) {
          TestHelper.printError('Should not update non-existent kanji');
          fail('Non-existent kanji update should fail');
        },
      );
    });

    test('6.6. Delete non-existent kanji should fail', () async {
      TestHelper.printSection('TEST 6.6: DELETE NON-EXISTENT KANJI');

      TestHelper.printStep('Attempting to delete non-existent kanji...');

      final result = await deleteKanji(999999);

      result.fold(
        (failure) {
          TestHelper.printSuccess('Error thrown (as expected)');
          TestHelper.printSuccess('Failure: ${failure.toString()}');
        },
        (_) {
          TestHelper.printError('Should not delete non-existent kanji');
          fail('Non-existent kanji deletion should fail');
        },
      );
    });

    test('6.7. Create kanji with minimal required fields', () async {
      TestHelper.printSection('TEST 6.7: CREATE KANJI WITH MINIMAL FIELDS');

      TestHelper.printStep('Creating kanji with only required fields...');

      final params = CreateKanjiParams(
        character: '験',
        meanings: 'verify, test, examine',
        onReadings: 'ケン, ゲン',
        kunReadings: 'あかし, しるし, ため.す',
        strokeCount: 18,
        frequency: 600,
      );

      final result = await createKanji(params);

      int? minimalKanjiId;

      result.fold(
        (failure) {
          TestHelper.printError('Failed to create minimal kanji: $failure');
          fail('Should create kanji with minimal fields');
        },
        (kanji) {
          minimalKanjiId = kanji.id;
          TestHelper.printSuccess('Minimal kanji created successfully');
          TestHelper.printSuccess('ID: ${kanji.id}');
          TestHelper.printSuccess('Character: ${kanji.character}');
          TestHelper.printSuccess('JLPT: ${kanji.jlpt ?? "null (OK)"}');
          TestHelper.printSuccess('Grade: ${kanji.grade ?? "null (OK)"}');

          expect(kanji.character, equals('験'));
          expect(kanji.strokeCount, equals(18));
        },
      );

      // Cleanup: Delete the minimal kanji
      if (minimalKanjiId != null) {
        TestHelper.printStep('Cleaning up minimal kanji...');
        await deleteKanji(minimalKanjiId!);
        TestHelper.printSuccess('Cleanup completed');
      }
    });

    test('6.8. Create duplicate kanji should fail', () async {
      TestHelper.printSection('TEST 6.8: CREATE DUPLICATE KANJI');

      TestHelper.printStep('Creating first kanji...');

      final params1 = CreateKanjiParams(
        character: '複',
        meanings: 'duplicate, double',
        onReadings: 'フク',
        kunReadings: '',
        strokeCount: 14,
        frequency: 700,
      );

      int? duplicateTestId;
      final result1 = await createKanji(params1);

      result1.fold(
        (failure) {
          TestHelper.printError('Failed to create first kanji: $failure');
        },
        (kanji) {
          duplicateTestId = kanji.id;
          TestHelper.printSuccess('First kanji created: ${kanji.character}');
        },
      );

      TestHelper.printStep('Attempting to create duplicate...');

      final params2 = CreateKanjiParams(
        character: '複', // Same character
        meanings: 'duplicate attempt',
        onReadings: 'フク',
        kunReadings: '',
        strokeCount: 14,
        frequency: 700,
      );

      final result2 = await createKanji(params2);

      result2.fold(
        (failure) {
          TestHelper.printSuccess('Duplicate rejected (as expected)');
          TestHelper.printSuccess('Failure: ${failure.toString()}');
        },
        (kanji) {
          TestHelper.printError('Should not create duplicate kanji');
          fail('Duplicate kanji should be rejected');
        },
      );

      // Cleanup
      if (duplicateTestId != null) {
        TestHelper.printStep('Cleaning up test kanji...');
        await deleteKanji(duplicateTestId!);
        TestHelper.printSuccess('Cleanup completed');
      }
    });
  });

  group('7. Admin Workflow Tests -', () {
    setUpAll(() async {
      // Ensure admin authentication
      final token = await AuthHelper.loginForTesting(
        account: 'admin@gmail.com',
        password: 'Admin@12345',
      );
      final apiClient = di.sl<ApiClient>();
      apiClient.setAuthToken(token);
    });

    test('7.1. Complete admin workflow', () async {
      TestHelper.printSection('TEST 7.1: COMPLETE ADMIN WORKFLOW');

      // Step 1: Check dashboard
      TestHelper.printStep('1. Checking dashboard overview...');
      final overview = await adminService.getDashboardOverview();
      TestHelper.printSuccess('Dashboard loaded');

      final initialPending = overview.activity.pendingPublishRequests;
      TestHelper.printSuccess('Initial pending requests: $initialPending');

      // Step 2: Get all pending requests
      TestHelper.printStep('2. Fetching pending requests...');
      final pendingResponse = await adminService.getPublishRequests(
        status: 'pending',
      );
      TestHelper.printSuccess(
        'Found ${pendingResponse.requests.length} pending requests',
      );

      // Step 3: Get statistics
      TestHelper.printStep('3. Getting publish statistics...');
      final stats = await adminService.getPublishStatistics();
      TestHelper.printSuccess('Total requests: ${stats.total}');
      TestHelper.printSuccess('Approved: ${stats.approved}');

      // Step 4: Check system health
      TestHelper.printStep('4. Checking system health...');
      final health = await adminService.getSystemHealth();
      TestHelper.printSuccess('System status: ${health.status}');

      TestHelper.printSuccess('Complete workflow executed successfully');
    });

    test('7.2. Multiple admin requests in sequence', () async {
      TestHelper.printSection('TEST 7.2: MULTIPLE REQUESTS IN SEQUENCE');

      TestHelper.printStep('Making 5 consecutive requests...');

      for (int i = 1; i <= 5; i++) {
        TestHelper.printStep('Request $i/5');

        final overview = await adminService.getDashboardOverview();
        expect(overview.users.total, greaterThan(0));

        await Future.delayed(const Duration(milliseconds: 200));
      }

      TestHelper.printSuccess('All requests completed successfully');
    });

    test('7.3. Error recovery', () async {
      TestHelper.printSection('TEST 7.3: ERROR RECOVERY');

      // Make an invalid request
      TestHelper.printStep('1. Making invalid request...');
      try {
        await adminService.getPublishRequestById(999999, 'quiz');
      } catch (e) {
        TestHelper.printSuccess('Error caught (expected)');
      }

      // Verify system still works
      TestHelper.printStep('2. Making valid request after error...');
      final overview = await adminService.getDashboardOverview();

      TestHelper.printSuccess('System recovered successfully');
      TestHelper.printSuccess('Users: ${overview.users.total}');

      expect(overview.users.total, greaterThan(0));
    });
  });

  tearDownAll(() async {
    TestHelper.printSection('CLEANING UP ADMIN TESTS');
    TestHelper.printSuccess('All admin integration tests completed');
  });
}
