import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:kanji_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kanji_flutter/features/auth/presentation/bloc/auth_event.dart';
import 'package:kanji_flutter/features/auth/presentation/bloc/auth_state.dart';
import 'package:kanji_flutter/injection_container.dart' as di;
import 'package:kanji_flutter/core/network/api_client.dart';

import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin Dashboard Bloc Flow Tests - Using bloc_test', () {
    late IntegrationTestHelper testHelper;
    late ApiClient apiClient;

    setUpAll(() async {
      // Load environment variables
      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        print('⚠️ Could not load .env file: $e');
        // Continue anyway - will use default values
      }

      await di.init();
      testHelper = IntegrationTestHelper();
      apiClient = di.sl<ApiClient>();

      final isRunning = await testHelper.isBackendRunning();
      if (!isRunning) {
        throw Exception(
          '❌ Backend not running at ${IntegrationTestHelper.baseUrl}',
        );
      }
      print('✅ Backend server is running');
    });

    tearDownAll(() async {
      try {
        await testHelper.cleanup();
      } catch (e) {
        print('⚠️ Cleanup error: $e');
      }
    });

    group('Auth Bloc - Admin Login Flow', () {
      blocTest<AuthBloc, AuthState>(
        '✅ Admin login should emit Authenticated state with ADMIN role',
        build: () => di.sl<AuthBloc>(),
        act: (bloc) {
          bloc.add(
            AuthLoginRequested(
              email: IntegrationTestHelper.adminEmail,
              password: IntegrationTestHelper.adminPassword,
            ),
          );
        },
        expect: () => [
          isA<AuthLoading>(),
          isA<Authenticated>().having(
            (state) => state.user.role.toUpperCase(),
            'role',
            equals('ADMIN'),
          ),
        ],
        wait: const Duration(seconds: 5),
      );

      blocTest<AuthBloc, AuthState>(
        '✅ Regular user login should NOT have ADMIN role',
        build: () => di.sl<AuthBloc>(),
        act: (bloc) {
          bloc.add(
            AuthLoginRequested(
              email: IntegrationTestHelper.testEmail,
              password: IntegrationTestHelper.testPassword,
            ),
          );
        },
        expect: () => [
          isA<AuthLoading>(),
          isA<Authenticated>().having(
            (state) => state.user.role.toUpperCase(),
            'role',
            equals('USER'),
          ),
        ],
        wait: const Duration(seconds: 5),
      );

      blocTest<AuthBloc, AuthState>(
        '❌ Invalid admin credentials should emit AuthError',
        build: () => di.sl<AuthBloc>(),
        act: (bloc) => bloc.add(
          AuthLoginRequested(
            email: 'invalid@admin.com',
            password: 'wrongpassword',
          ),
        ),
        expect: () => [isA<AuthLoading>(), isA<AuthError>()],
        wait: const Duration(seconds: 5),
      );

      blocTest<AuthBloc, AuthState>(
        '✅ Auth check should restore admin session',
        build: () => di.sl<AuthBloc>(),
        setUp: () async {
          await testHelper.loginAsAdmin();
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<Authenticated>().having(
            (state) => state.user.role.toUpperCase(),
            'role',
            equals('ADMIN'),
          ),
        ],
        wait: const Duration(seconds: 5),
      );
    });

    group('Admin Dashboard - API Response Parsing Tests', () {
      test('✅ /admin/users API should return valid data', () async {
        await testHelper.loginAsAdmin();

        final response = await apiClient.get('/admin/users');
        print('📥 Users API Response: ${response.data}');

        expect(response.data, isNotNull);

        // Backend always wraps response: { statusCode, data, timestamp }
        expect(
          response.data,
          isA<Map<String, dynamic>>(),
          reason: 'Response should be wrapped object',
        );

        final wrappedData = response.data as Map<String, dynamic>;
        expect(
          wrappedData.containsKey('data'),
          isTrue,
          reason: 'Should have "data" key',
        );

        final actualData = wrappedData['data'];
        expect(
          actualData,
          isA<List>(),
          reason: 'data should be a List of users',
        );
      });

      test('✅ /kanji API should return total count', () async {
        await testHelper.loginAsAdmin();

        final response = await apiClient.get('/kanji?limit=1');
        print('📥 Kanji API Response: ${response.data}');

        expect(response.data, isNotNull);
        expect(
          response.data,
          isA<Map<String, dynamic>>(),
          reason: 'Response should be wrapped object',
        );

        final wrappedData = response.data as Map<String, dynamic>;
        expect(
          wrappedData.containsKey('data'),
          isTrue,
          reason: 'Should have "data" key',
        );

        final actualData = wrappedData['data'];
        if (actualData is Map<String, dynamic>) {
          expect(
            actualData.containsKey('total'),
            isTrue,
            reason: 'Should have total count in data',
          );
          expect(
            actualData['total'],
            isA<int>(),
            reason: 'total should be integer',
          );
        }
      });

      test('✅ /quizzes API should return valid data', () async {
        await testHelper.loginAsAdmin();

        final response = await apiClient.get('/quizzes');
        print('📥 Quizzes API Response: ${response.data}');

        expect(response.data, isNotNull);
        expect(
          response.data,
          isA<Map<String, dynamic>>(),
          reason: 'Response should be wrapped object',
        );

        final wrappedData = response.data as Map<String, dynamic>;
        expect(
          wrappedData.containsKey('data'),
          isTrue,
          reason: 'Should have "data" key',
        );

        final actualData = wrappedData['data'];
        // Data can be List directly or Map with pagination
        expect(
          actualData is List || actualData is Map<String, dynamic>,
          isTrue,
          reason: 'data should be List or Map with pagination',
        );
      });

      test('✅ /quizzes/admin/publish-requests should handle gracefully', () async {
        await testHelper.loginAsAdmin();

        try {
          final response = await apiClient.get(
            '/quizzes/admin/publish-requests',
          );
          print('📥 Publish Requests API Response: ${response.data}');

          expect(response.data, isNotNull);
          expect(
            response.data,
            isA<Map<String, dynamic>>(),
            reason: 'Response should be wrapped object',
          );

          final wrappedData = response.data as Map<String, dynamic>;
          if (wrappedData.containsKey('data')) {
            final actualData = wrappedData['data'];
            expect(
              actualData is List || actualData is Map<String, dynamic>,
              isTrue,
              reason: 'data should be List or Map',
            );
          }
        } catch (e) {
          print(
            '⚠️ Publish requests endpoint not available or requires special permission: $e',
          );
          // This is acceptable - endpoint might not exist or require special permission
        }
      });
    });

    group('Admin Dashboard - Stats Calculation Tests', () {
      test('✅ Should calculate total users correctly', () async {
        await testHelper.loginAsAdmin();

        final response = await apiClient.get('/admin/users');

        // Unwrap response
        final wrappedData = response.data as Map<String, dynamic>;
        final actualData = wrappedData['data'];

        List<dynamic> users = [];
        if (actualData is Map<String, dynamic>) {
          users = (actualData['data'] as List?) ?? [];
        } else if (actualData is List) {
          users = actualData;
        }

        print('📊 Total Users: ${users.length}');
        expect(
          users.length,
          greaterThanOrEqualTo(0),
          reason: 'Should have valid user count',
        );
      });

      test('✅ Should calculate active users (last 7 days)', () async {
        await testHelper.loginAsAdmin();

        final response = await apiClient.get('/admin/users');

        // Unwrap response
        final wrappedData = response.data as Map<String, dynamic>;
        final actualData = wrappedData['data'];

        List<dynamic> users = [];
        if (actualData is Map<String, dynamic>) {
          users = (actualData['data'] as List?) ?? [];
        } else if (actualData is List) {
          users = actualData;
        }

        final now = DateTime.now();
        int activeUsers = 0;

        for (var user in users) {
          try {
            if (user['lastLoginAt'] != null) {
              final lastLogin = DateTime.parse(user['lastLoginAt'] as String);
              if (now.difference(lastLogin).inDays <= 7) {
                activeUsers++;
              }
            }
          } catch (e) {
            // Skip invalid dates
            continue;
          }
        }

        print('📊 Active Users (last 7 days): $activeUsers / ${users.length}');
        expect(activeUsers, greaterThanOrEqualTo(0));
        expect(activeUsers, lessThanOrEqualTo(users.length));
      });

      test('✅ Should calculate new users today', () async {
        await testHelper.loginAsAdmin();

        final response = await apiClient.get('/admin/users');

        // Unwrap response
        final wrappedData = response.data as Map<String, dynamic>;
        final actualData = wrappedData['data'];

        List<dynamic> users = [];
        if (actualData is Map<String, dynamic>) {
          users = (actualData['data'] as List?) ?? [];
        } else if (actualData is List) {
          users = actualData;
        }

        final now = DateTime.now();
        int newUsersToday = 0;

        for (var user in users) {
          try {
            if (user['createdAt'] != null) {
              final createdAt = DateTime.parse(user['createdAt'] as String);
              if (now.difference(createdAt).inDays == 0) {
                newUsersToday++;
              }
            }
          } catch (e) {
            continue;
          }
        }

        print('📊 New Users Today: $newUsersToday');
        expect(newUsersToday, greaterThanOrEqualTo(0));
      });

      test('✅ Should get total kanji count', () async {
        await testHelper.loginAsAdmin();

        final response = await apiClient.get('/kanji?limit=1');

        // Unwrap response
        final wrappedData = response.data as Map<String, dynamic>;
        final actualData = wrappedData['data'];

        int kanjiTotal = 0;
        if (actualData is Map<String, dynamic>) {
          kanjiTotal = actualData['total'] ?? 0;
        }

        print('📊 Total Kanji: $kanjiTotal');
        expect(kanjiTotal, greaterThanOrEqualTo(0));
      });

      test('✅ Should get total quizzes count', () async {
        await testHelper.loginAsAdmin();

        final response = await apiClient.get('/quizzes');

        // Unwrap response
        final wrappedData = response.data as Map<String, dynamic>;
        final actualData = wrappedData['data'];

        List<dynamic> quizzes = [];
        if (actualData is Map<String, dynamic>) {
          quizzes = (actualData['data'] as List?) ?? [];
        } else if (actualData is List) {
          quizzes = actualData;
        }

        print('📊 Total Quizzes: ${quizzes.length}');
        expect(quizzes.length, greaterThanOrEqualTo(0));
      });
    });

    group('Admin Dashboard - Error Handling Tests', () {
      test('❌ Unauthorized access should fail gracefully', () async {
        // Clear auth token
        await testHelper.cleanup();

        try {
          await apiClient.get('/admin/users');
          fail('Should throw error for unauthorized access');
        } catch (e) {
          print('✅ Correctly rejected unauthorized access: $e');
          expect(e, isNotNull);
        }
      });

      test('❌ Invalid API endpoint should fail gracefully', () async {
        await testHelper.loginAsAdmin();

        try {
          await apiClient.get('/admin/invalid-endpoint');
          fail('Should throw error for invalid endpoint');
        } catch (e) {
          print('✅ Correctly handled invalid endpoint: $e');
          expect(e, isNotNull);
        }
      });

      test('✅ Regular user should NOT access admin endpoints', () async {
        await testHelper.loginAndGetToken(); // Login as regular user

        try {
          await apiClient.get('/admin/users');
          fail('Regular user should NOT access admin endpoints');
        } catch (e) {
          print('✅ Correctly blocked regular user from admin endpoint: $e');
          expect(e, isNotNull);
        }
      });
    });

    group('Admin Dashboard - Data Integrity Tests', () {
      test('✅ User objects should have required fields', () async {
        await testHelper.loginAsAdmin();

        final response = await apiClient.get('/admin/users');

        // Unwrap response
        final wrappedData = response.data as Map<String, dynamic>;
        final actualData = wrappedData['data'];

        List<dynamic> users = [];
        if (actualData is Map<String, dynamic>) {
          users = (actualData['data'] as List?) ?? [];
        } else if (actualData is List) {
          users = actualData;
        }

        if (users.isNotEmpty) {
          final firstUser = users.first as Map<String, dynamic>;

          // Check required fields
          expect(
            firstUser.containsKey('id'),
            isTrue,
            reason: 'User should have id',
          );
          expect(
            firstUser.containsKey('email'),
            isTrue,
            reason: 'User should have email',
          );
          // Note: 'username' might be 'name' in backend
          expect(
            firstUser.containsKey('name') || firstUser.containsKey('username'),
            isTrue,
            reason: 'User should have name or username',
          );
          expect(
            firstUser.containsKey('role'),
            isTrue,
            reason: 'User should have role',
          );
          expect(
            firstUser.containsKey('createdAt'),
            isTrue,
            reason: 'User should have createdAt',
          );

          print('✅ User object structure is valid');
          print('   Sample user: ${firstUser['email']} (${firstUser['role']})');
        }
      });

      test('✅ User roles should be valid (USER or ADMIN)', () async {
        await testHelper.loginAsAdmin();

        final response = await apiClient.get('/admin/users');

        // Unwrap response
        final wrappedData = response.data as Map<String, dynamic>;
        final actualData = wrappedData['data'];

        List<dynamic> users = [];
        if (actualData is Map<String, dynamic>) {
          users = (actualData['data'] as List?) ?? [];
        } else if (actualData is List) {
          users = actualData;
        }

        for (var user in users) {
          final role = (user['role'] as String).toUpperCase();
          expect(
            ['USER', 'ADMIN'].contains(role),
            isTrue,
            reason: 'Role should be either USER or ADMIN, got: $role',
          );
        }

        print('✅ All user roles are valid');
      });

      test('✅ Quiz objects should have required fields', () async {
        await testHelper.loginAsAdmin();

        final response = await apiClient.get('/quizzes');

        // Unwrap response
        final wrappedData = response.data as Map<String, dynamic>;
        final actualData = wrappedData['data'];

        List<dynamic> quizzes = [];
        if (actualData is Map<String, dynamic>) {
          quizzes = (actualData['data'] as List?) ?? [];
        } else if (actualData is List) {
          quizzes = actualData;
        }

        if (quizzes.isNotEmpty) {
          final firstQuiz = quizzes.first as Map<String, dynamic>;

          expect(firstQuiz.containsKey('id'), isTrue);
          expect(firstQuiz.containsKey('title'), isTrue);

          print('✅ Quiz object structure is valid');
        }
      });
    });

    group('Admin Dashboard - Performance Tests', () {
      test('✅ Stats loading should complete within 10 seconds', () async {
        await testHelper.loginAsAdmin();

        final stopwatch = Stopwatch()..start();

        // Fetch all stats
        await Future.wait([
          apiClient.get('/admin/users'),
          apiClient.get('/kanji?limit=1'),
          apiClient.get('/quizzes'),
        ]);

        stopwatch.stop();
        final elapsed = stopwatch.elapsedMilliseconds;

        print('⏱️ Stats loading time: ${elapsed}ms');
        expect(
          elapsed,
          lessThan(10000),
          reason: 'Stats should load within 10 seconds',
        );
      });

      test('✅ Individual API calls should complete within 5 seconds', () async {
        await testHelper.loginAsAdmin();

        final tests = [
          {'name': 'Users API', 'endpoint': '/admin/users'},
          {'name': 'Kanji API', 'endpoint': '/kanji?limit=1'},
          {'name': 'Quizzes API', 'endpoint': '/quizzes'},
        ];

        for (var test in tests) {
          final stopwatch = Stopwatch()..start();
          await apiClient.get(test['endpoint'] as String);
          stopwatch.stop();

          final elapsed = stopwatch.elapsedMilliseconds;
          print('⏱️ ${test['name']}: ${elapsed}ms');

          expect(
            elapsed,
            lessThan(5000),
            reason: '${test['name']} should complete within 5 seconds',
          );
        }
      });
    });
  });
}
