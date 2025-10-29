import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/features/admin/models/user_management_models.dart';

void main() {
  group('User Management Models - Real API Response Tests', () {
    // ==================== UserListResponse Tests ====================

    test('UserListResponse with real API response structure', () {
      final json = {
        'users': [
          {
            'id': 1,
            'email': 'admin@example.com',
            'name': 'Admin User',
            'role': 'ADMIN',
            'profileImage': null,
            'createdAt': '2025-01-01T00:00:00.000Z',
            'updatedAt': '2025-01-02T00:00:00.000Z',
            'twoFactorEnabled': true,
          },
          {
            'id': 2,
            'email': 'user@example.com',
            'name': 'Regular User',
            'role': 'USER',
            'profileImage': 'https://example.com/avatar.jpg',
            'createdAt': '2025-01-05T00:00:00.000Z',
            'updatedAt': '2025-01-06T00:00:00.000Z',
            'twoFactorEnabled': false,
          },
        ],
        'total': 2,
      };

      final response = UserListResponse.fromJson(json);
      expect(response.users.length, 2);
      expect(response.total, 2);
      expect(response.users[0].email, 'admin@example.com');
      expect(response.users[0].role, 'ADMIN');
      expect(response.users[0].twoFactorEnabled, true);
      expect(response.users[1].email, 'user@example.com');
      expect(response.users[1].role, 'USER');
      expect(response.users[1].profileImage, 'https://example.com/avatar.jpg');
    });

    test('UserInfo with complete data', () {
      final json = {
        'id': 1,
        'email': 'test@example.com',
        'name': 'Test User',
        'role': 'USER',
        'profileImage': 'https://example.com/avatar.jpg',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
        'twoFactorEnabled': true,
        'totalQuizzes': 10,
        'totalLists': 5,
        'totalDecks': 8,
        'totalSessions': 25,
      };

      final user = UserInfo.fromJson(json);
      expect(user.id, 1);
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.role, 'USER');
      expect(user.profileImage, 'https://example.com/avatar.jpg');
      expect(user.twoFactorEnabled, true);
      expect(user.totalQuizzes, 10);
      expect(user.totalLists, 5);
      expect(user.totalDecks, 8);
      expect(user.totalSessions, 25);
    });

    test('UserInfo with missing optional fields', () {
      final json = {
        'id': 1,
        'email': 'test@example.com',
        'role': 'USER',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
      };

      final user = UserInfo.fromJson(json);
      expect(user.id, 1);
      expect(user.email, 'test@example.com');
      expect(user.name, null);
      expect(user.role, 'USER');
      expect(user.profileImage, null);
      expect(user.twoFactorEnabled, false); // Default value
      expect(user.totalQuizzes, null);
      expect(user.totalLists, null);
      expect(user.totalDecks, null);
      expect(user.totalSessions, null);
    });

    test('UserManagementStatistics with growthData array', () {
      final json = {
        'totalUsers': 1000,
        'activeUsers': 750,
        'newUsersToday': 5,
        'newUsersThisWeek': 25,
        'newUsersThisMonth': 100,
        'growthData': [
          {'date': '2025-10-01', 'count': 10},
          {'date': '2025-10-02', 'count': 15},
          {'date': '2025-10-03', 'count': 12},
        ],
      };

      final stats = UserManagementStatistics.fromJson(json);
      expect(stats.totalUsers, 1000);
      expect(stats.activeUsers, 750);
      expect(stats.newUsersToday, 5);
      expect(stats.newUsersThisWeek, 25);
      expect(stats.newUsersThisMonth, 100);
      expect(stats.growthData.length, 3);
      expect(stats.growthData[0].date, '2025-10-01');
      expect(stats.growthData[0].count, 10);
    });

    test('Handle dynamic types from API (int vs double)', () {
      final json = {
        'id': 1.0, // API might return double instead of int
        'email': 'test@example.com',
        'role': 'USER',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
        'totalQuizzes': 10.0,
        'totalLists': 5.0,
      };

      final user = UserInfo.fromJson(json);
      expect(user.id, 1);
      expect(user.totalQuizzes, 10);
      expect(user.totalLists, 5);
    });

    // ==================== Edge Cases - Type Mismatches ====================

    group('Edge Cases - Type Mismatches', () {
      test('should handle when users is returned as Map instead of List', () {
        final json = {
          'users': {}, // API returns empty object instead of array!
          'total': 0,
        };

        // Should NOT throw, should return empty list
        final response = UserListResponse.fromJson(json);
        expect(response.users, isEmpty);
        expect(response.total, 0);
      });

      test(
        'should handle when growthData is returned as Map instead of List',
        () {
          final json = {
            'totalUsers': 100,
            'activeUsers': 80,
            'newUsersToday': 5,
            'newUsersThisWeek': 20,
            'newUsersThisMonth': 50,
            'growthData': {}, // API returns empty object instead of array!
          };

          // Should NOT throw, should return empty list
          final stats = UserManagementStatistics.fromJson(json);
          expect(stats.growthData, isEmpty);
          expect(stats.totalUsers, 100);
        },
      );

      test('should handle when users array contains non-Map items', () {
        final json = {
          'users': [
            {
              'id': 1,
              'email': 'test@example.com',
              'role': 'USER',
              'createdAt': '2025-01-01T00:00:00.000Z',
              'updatedAt': '2025-01-02T00:00:00.000Z',
            },
            'invalid_string', // Invalid item in array
            null, // Null item
            {
              'id': 2,
              'email': 'test2@example.com',
              'role': 'USER',
              'createdAt': '2025-01-01T00:00:00.000Z',
              'updatedAt': '2025-01-02T00:00:00.000Z',
            },
          ],
          'total': 4,
        };

        // Should filter out invalid items
        final response = UserListResponse.fromJson(json);
        expect(response.users.length, 2); // Only 2 valid users
        expect(response.users[0].id, 1);
        expect(response.users[1].id, 2);
      });

      test('should handle missing required fields with defaults', () {
        final json = {
          'id': 1,
          // Missing email
          'role': 'USER',
          // Missing createdAt and updatedAt
        };

        final user = UserInfo.fromJson(json);
        expect(user.id, 1);
        expect(user.email, ''); // Default empty string
        expect(user.role, 'USER');
        expect(user.createdAt, isNotNull); // Should use DateTime.now()
        expect(user.updatedAt, isNotNull);
      });

      test('should handle null values in required fields', () {
        final json = {
          'id': null,
          'email': null,
          'role': null,
          'createdAt': null,
          'updatedAt': null,
          'twoFactorEnabled': null,
        };

        final user = UserInfo.fromJson(json);
        expect(user.id, 0); // Default value
        expect(user.email, ''); // Default empty string
        expect(user.role, 'USER'); // Default role
        expect(user.twoFactorEnabled, false); // Default value
        expect(user.createdAt, isNotNull);
        expect(user.updatedAt, isNotNull);
      });
    });

    // ==================== Debug - Verify type validation works ====================

    group('Debug - Verify type validation works', () {
      test('users as string should return empty list', () {
        final json = {
          'users': 'not_an_array', // Wrong type!
          'total': 0,
        };

        final response = UserListResponse.fromJson(json);
        expect(response, isNotNull);
        expect(response.users, isEmpty);
      });

      test('growthData as string should return empty list', () {
        final json = {
          'totalUsers': 100,
          'activeUsers': 80,
          'newUsersToday': 5,
          'newUsersThisWeek': 20,
          'newUsersThisMonth': 50,
          'growthData': 'not_an_array', // Wrong type!
        };

        final stats = UserManagementStatistics.fromJson(json);
        expect(stats, isNotNull);
        expect(stats.growthData, isEmpty);
      });

      test('users as null should return empty list', () {
        final json = {'users': null, 'total': 0};

        final response = UserListResponse.fromJson(json);
        expect(response, isNotNull);
        expect(response.users, isEmpty);
      });

      test('all fields missing should use defaults', () {
        final json = <String, dynamic>{};

        final user = UserInfo.fromJson(json);
        expect(user, isNotNull);
        expect(user.id, 0);
        expect(user.email, '');
        expect(user.role, 'USER');
        expect(user.twoFactorEnabled, false);
      });

      test('total as string should use default', () {
        final json = {
          'users': [],
          'total': 'not_a_number', // Wrong type!
        };

        final response = UserListResponse.fromJson(json);
        expect(response, isNotNull);
        expect(response.total, 0); // Default value
      });

      test('nested array with mixed types should filter correctly', () {
        final json = {
          'totalUsers': 100,
          'activeUsers': 80,
          'newUsersToday': 5,
          'newUsersThisWeek': 20,
          'newUsersThisMonth': 50,
          'growthData': [
            {'date': '2025-10-01', 'count': 10}, // Valid
            'invalid', // Invalid
            {'date': '2025-10-02', 'count': 15}, // Valid
            null, // Invalid
            {'date': '2025-10-03', 'count': 12}, // Valid
            123, // Invalid
          ],
        };

        final stats = UserManagementStatistics.fromJson(json);
        expect(stats.growthData.length, 3); // Only 3 valid items
        expect(stats.growthData[0].date, '2025-10-01');
        expect(stats.growthData[1].date, '2025-10-02');
        expect(stats.growthData[2].date, '2025-10-03');
      });
    });

    // ==================== UpdateUserRequest Tests ====================

    group('UpdateUserRequest', () {
      test('toJson with all fields', () {
        final request = UpdateUserRequest(
          name: 'New Name',
          email: 'newemail@example.com',
          role: 'ADMIN',
        );

        final json = request.toJson();
        expect(json['name'], 'New Name');
        expect(json['email'], 'newemail@example.com');
        expect(json['role'], 'ADMIN');
      });

      test('toJson with partial fields', () {
        final request = UpdateUserRequest(name: 'New Name');

        final json = request.toJson();
        expect(json['name'], 'New Name');
        expect(json.containsKey('email'), false);
        expect(json.containsKey('role'), false);
      });

      test('toJson with no fields', () {
        final request = UpdateUserRequest();

        final json = request.toJson();
        expect(json.isEmpty, true);
      });
    });

    // ==================== UserInfo copyWith Tests ====================

    group('UserInfo copyWith', () {
      test('copyWith updates specified fields', () {
        final original = UserInfo(
          id: 1,
          email: 'test@example.com',
          name: 'Test User',
          role: 'USER',
          createdAt: DateTime.parse('2025-01-01'),
          updatedAt: DateTime.parse('2025-01-02'),
        );

        final updated = original.copyWith(name: 'Updated Name', role: 'ADMIN');

        expect(updated.id, 1); // Unchanged
        expect(updated.email, 'test@example.com'); // Unchanged
        expect(updated.name, 'Updated Name'); // Changed
        expect(updated.role, 'ADMIN'); // Changed
      });

      test('copyWith with no changes returns equivalent object', () {
        final original = UserInfo(
          id: 1,
          email: 'test@example.com',
          role: 'USER',
          createdAt: DateTime.parse('2025-01-01'),
          updatedAt: DateTime.parse('2025-01-02'),
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.email, original.email);
        expect(copy.role, original.role);
      });
    });

    // ==================== Serialization Round-trip Tests ====================

    group('Serialization Round-trip', () {
      test('UserInfo round-trip serialization', () {
        final original = UserInfo(
          id: 1,
          email: 'test@example.com',
          name: 'Test User',
          role: 'ADMIN',
          profileImage: 'https://example.com/avatar.jpg',
          createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2025-01-02T00:00:00.000Z'),
          twoFactorEnabled: true,
          totalQuizzes: 10,
          totalLists: 5,
        );

        final json = original.toJson();
        final reconstructed = UserInfo.fromJson(json);

        expect(reconstructed.id, original.id);
        expect(reconstructed.email, original.email);
        expect(reconstructed.name, original.name);
        expect(reconstructed.role, original.role);
        expect(reconstructed.profileImage, original.profileImage);
        expect(reconstructed.twoFactorEnabled, original.twoFactorEnabled);
        expect(reconstructed.totalQuizzes, original.totalQuizzes);
        expect(reconstructed.totalLists, original.totalLists);
      });

      test('UserListResponse round-trip serialization', () {
        final original = UserListResponse(
          users: [
            UserInfo(
              id: 1,
              email: 'test1@example.com',
              role: 'USER',
              createdAt: DateTime.parse('2025-01-01'),
              updatedAt: DateTime.parse('2025-01-02'),
            ),
            UserInfo(
              id: 2,
              email: 'test2@example.com',
              role: 'ADMIN',
              createdAt: DateTime.parse('2025-01-03'),
              updatedAt: DateTime.parse('2025-01-04'),
            ),
          ],
          total: 2,
        );

        final json = original.toJson();
        final reconstructed = UserListResponse.fromJson(json);

        expect(reconstructed.users.length, original.users.length);
        expect(reconstructed.total, original.total);
        expect(reconstructed.users[0].email, original.users[0].email);
        expect(reconstructed.users[1].email, original.users[1].email);
      });
    });
  });
}
