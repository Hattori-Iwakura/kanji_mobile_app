import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/features/profile/models/profile_models.dart';

void main() {
  group('Profile Models - Real API Response Tests', () {
    // ==================== UserProfile Tests ====================

    test('UserProfile with complete data including stats', () {
      final json = {
        'id': 1,
        'email': 'user@example.com',
        'name': 'Test User',
        'role': 'USER',
        'profileImage': 'https://example.com/avatar.jpg',
        'twoFactorEnabled': true,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-15T00:00:00.000Z',
        'stats': {
          'totalKanjiStudied': 150,
          'quizzesCompleted': 25,
          'flashcardsReviewed': 500,
          'currentStreak': 7,
          'totalXp': 1500,
          'averageScore': 85.5,
          'recentActivity': [
            {
              'type': 'quiz',
              'title': 'JLPT N5 Quiz',
              'timestamp': '2025-10-29T10:00:00.000Z',
              'score': 90,
              'details': 'Completed with 9/10 correct',
            },
          ],
        },
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.id, 1);
      expect(profile.email, 'user@example.com');
      expect(profile.name, 'Test User');
      expect(profile.role, 'USER');
      expect(profile.profileImage, 'https://example.com/avatar.jpg');
      expect(profile.twoFactorEnabled, true);
      expect(profile.createdAt, isNotNull);
      expect(profile.updatedAt, isNotNull);
      expect(profile.stats, isNotNull);
      expect(profile.stats!.totalKanjiStudied, 150);
      expect(profile.stats!.quizzesCompleted, 25);
      expect(profile.stats!.averageScore, 85.5);
      expect(profile.stats!.recentActivity.length, 1);
    });

    test('UserProfile with minimal required fields', () {
      final json = {'id': 1, 'email': 'user@example.com', 'role': 'USER'};

      final profile = UserProfile.fromJson(json);
      expect(profile.id, 1);
      expect(profile.email, 'user@example.com');
      expect(profile.name, null);
      expect(profile.role, 'USER');
      expect(profile.profileImage, null);
      expect(profile.twoFactorEnabled, false); // Default value
      expect(profile.createdAt, null);
      expect(profile.updatedAt, null);
      expect(profile.stats, null);
    });

    test('ProfileStats with complete data', () {
      final json = {
        'totalKanjiStudied': 150,
        'quizzesCompleted': 25,
        'flashcardsReviewed': 500,
        'currentStreak': 7,
        'totalXp': 1500,
        'averageScore': 85.5,
        'recentActivity': [
          {
            'type': 'quiz',
            'title': 'JLPT N5 Quiz',
            'timestamp': '2025-10-29T10:00:00.000Z',
            'score': 90,
            'details': 'Completed',
          },
          {
            'type': 'flashcard',
            'title': 'Daily Review',
            'timestamp': '2025-10-29T09:00:00.000Z',
            'score': null,
            'details': null,
          },
        ],
      };

      final stats = ProfileStats.fromJson(json);
      expect(stats.totalKanjiStudied, 150);
      expect(stats.quizzesCompleted, 25);
      expect(stats.flashcardsReviewed, 500);
      expect(stats.currentStreak, 7);
      expect(stats.totalXp, 1500);
      expect(stats.averageScore, 85.5);
      expect(stats.recentActivity.length, 2);
      expect(stats.recentActivity[0].type, 'quiz');
      expect(stats.recentActivity[0].score, 90);
      expect(stats.recentActivity[1].type, 'flashcard');
      expect(stats.recentActivity[1].score, null);
    });

    test('ActivityData with complete data', () {
      final json = {
        'type': 'quiz',
        'title': 'JLPT N5 Quiz',
        'timestamp': '2025-10-29T10:00:00.000Z',
        'score': 90,
        'details': 'Completed with 9/10 correct',
      };

      final activity = ActivityData.fromJson(json);
      expect(activity.type, 'quiz');
      expect(activity.title, 'JLPT N5 Quiz');
      expect(activity.timestamp, isNotNull);
      expect(activity.score, 90);
      expect(activity.details, 'Completed with 9/10 correct');
    });

    test('ActivityData with minimal fields', () {
      final json = {
        'type': 'flashcard',
        'title': 'Daily Review',
        'timestamp': '2025-10-29T09:00:00.000Z',
      };

      final activity = ActivityData.fromJson(json);
      expect(activity.type, 'flashcard');
      expect(activity.title, 'Daily Review');
      expect(activity.timestamp, isNotNull);
      expect(activity.score, null);
      expect(activity.details, null);
    });

    test('Handle dynamic types from API (int vs double)', () {
      final json = {
        'id': 1.0, // API might return double
        'email': 'test@example.com',
        'role': 'USER',
        'twoFactorEnabled': true,
        'stats': {
          'totalKanjiStudied': 150.0,
          'quizzesCompleted': 25.0,
          'flashcardsReviewed': 500.0,
          'currentStreak': 7.0,
          'totalXp': 1500.0,
          'averageScore': 85, // Might be int
          'recentActivity': [],
        },
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.id, 1);
      expect(profile.stats!.totalKanjiStudied, 150);
      expect(profile.stats!.quizzesCompleted, 25);
      expect(profile.stats!.averageScore, 85.0);
    });

    test('Handle string numbers from API', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'role': 'USER',
        'stats': {
          'totalKanjiStudied': '150',
          'quizzesCompleted': '25',
          'flashcardsReviewed': '500',
          'currentStreak': '7',
          'totalXp': '1500',
          'averageScore': '85.5',
          'recentActivity': [],
        },
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.id, 123);
      expect(profile.stats!.totalKanjiStudied, 150);
      expect(profile.stats!.averageScore, 85.5);
    });

    // ==================== Edge Cases - Type Mismatches ====================

    group('Edge Cases - Type Mismatches', () {
      test('should handle when stats is returned as List instead of Map', () {
        final json = {
          'id': 1,
          'email': 'test@example.com',
          'role': 'USER',
          'stats': [], // API returns empty array instead of object!
        };

        // Should NOT throw, should set stats to null
        final profile = UserProfile.fromJson(json);
        expect(profile, isNotNull);
        expect(profile.stats, null);
      });

      test(
        'should handle when recentActivity is returned as Map instead of List',
        () {
          final json = {
            'totalKanjiStudied': 150,
            'quizzesCompleted': 25,
            'flashcardsReviewed': 500,
            'currentStreak': 7,
            'totalXp': 1500,
            'averageScore': 85.5,
            'recentActivity': {}, // API returns empty object instead of array!
          };

          // Should NOT throw, should return empty list
          final stats = ProfileStats.fromJson(json);
          expect(stats.recentActivity, isEmpty);
        },
      );

      test(
        'should handle when recentActivity array contains non-Map items',
        () {
          final json = {
            'totalKanjiStudied': 150,
            'quizzesCompleted': 25,
            'flashcardsReviewed': 500,
            'currentStreak': 7,
            'totalXp': 1500,
            'averageScore': 85.5,
            'recentActivity': [
              {
                'type': 'quiz',
                'title': 'Quiz 1',
                'timestamp': '2025-10-29T10:00:00.000Z',
              },
              'invalid_string', // Invalid item
              null, // Null item
              {
                'type': 'flashcard',
                'title': 'Review 1',
                'timestamp': '2025-10-29T09:00:00.000Z',
              },
            ],
          };

          // Should filter out invalid items
          final stats = ProfileStats.fromJson(json);
          expect(stats.recentActivity.length, 2); // Only 2 valid activities
          expect(stats.recentActivity[0].type, 'quiz');
          expect(stats.recentActivity[1].type, 'flashcard');
        },
      );

      test('should handle missing required fields with defaults', () {
        final json = {
          'id': 1,
          // Missing email
          // Missing role
        };

        final profile = UserProfile.fromJson(json);
        expect(profile.id, 1);
        expect(profile.email, ''); // Default empty string
        expect(profile.role, 'USER'); // Default role
        expect(profile.twoFactorEnabled, false);
      });

      test('should handle null values in required fields', () {
        final json = {
          'id': null,
          'email': null,
          'role': null,
          'twoFactorEnabled': null,
          'stats': null,
        };

        final profile = UserProfile.fromJson(json);
        expect(profile.id, 0); // Default value
        expect(profile.email, ''); // Default empty string
        expect(profile.role, 'USER'); // Default role
        expect(profile.twoFactorEnabled, false); // Default value
        expect(profile.stats, null);
      });

      test('should handle invalid date strings', () {
        final json = {
          'id': 1,
          'email': 'test@example.com',
          'role': 'USER',
          'createdAt': 'invalid-date',
          'updatedAt': 'not-a-date',
        };

        final profile = UserProfile.fromJson(json);
        expect(profile, isNotNull);
        expect(profile.createdAt, null);
        expect(profile.updatedAt, null);
      });

      test('should handle invalid timestamp in ActivityData', () {
        final json = {
          'type': 'quiz',
          'title': 'Test',
          'timestamp': 'invalid-date',
        };

        final activity = ActivityData.fromJson(json);
        expect(activity, isNotNull);
        expect(activity.timestamp, isNotNull); // Should use DateTime.now()
      });
    });

    // ==================== Debug - Verify type validation works ====================

    group('Debug - Verify type validation works', () {
      test('stats as string should return null', () {
        final json = {
          'id': 1,
          'email': 'test@example.com',
          'role': 'USER',
          'stats': 'not_an_object', // Wrong type!
        };

        final profile = UserProfile.fromJson(json);
        expect(profile, isNotNull);
        expect(profile.stats, null);
      });

      test('recentActivity as string should return empty list', () {
        final json = {
          'totalKanjiStudied': 100,
          'quizzesCompleted': 10,
          'flashcardsReviewed': 200,
          'currentStreak': 5,
          'totalXp': 500,
          'averageScore': 80.0,
          'recentActivity': 'not_an_array', // Wrong type!
        };

        final stats = ProfileStats.fromJson(json);
        expect(stats, isNotNull);
        expect(stats.recentActivity, isEmpty);
      });

      test('all numeric fields as strings should parse correctly', () {
        final json = {
          'totalKanjiStudied': '100',
          'quizzesCompleted': '10',
          'flashcardsReviewed': '200',
          'currentStreak': '5',
          'totalXp': '500',
          'averageScore': '80.5',
          'recentActivity': [],
        };

        final stats = ProfileStats.fromJson(json);
        expect(stats.totalKanjiStudied, 100);
        expect(stats.quizzesCompleted, 10);
        expect(stats.flashcardsReviewed, 200);
        expect(stats.currentStreak, 5);
        expect(stats.totalXp, 500);
        expect(stats.averageScore, 80.5);
      });

      test('invalid numeric strings should use defaults', () {
        final json = {
          'totalKanjiStudied': 'not_a_number',
          'quizzesCompleted': 'abc',
          'flashcardsReviewed': 'xyz',
          'currentStreak': 'invalid',
          'totalXp': '---',
          'averageScore': 'bad',
          'recentActivity': [],
        };

        final stats = ProfileStats.fromJson(json);
        expect(stats.totalKanjiStudied, 0);
        expect(stats.quizzesCompleted, 0);
        expect(stats.flashcardsReviewed, 0);
        expect(stats.currentStreak, 0);
        expect(stats.totalXp, 0);
        expect(stats.averageScore, 0.0);
      });

      test('all fields missing should use defaults', () {
        final json = <String, dynamic>{};

        final profile = UserProfile.fromJson(json);
        expect(profile, isNotNull);
        expect(profile.id, 0);
        expect(profile.email, '');
        expect(profile.role, 'USER');
        expect(profile.twoFactorEnabled, false);
      });

      test('nested array with all invalid types', () {
        final json = {
          'totalKanjiStudied': 100,
          'quizzesCompleted': 10,
          'flashcardsReviewed': 200,
          'currentStreak': 5,
          'totalXp': 500,
          'averageScore': 80.0,
          'recentActivity': [
            'string',
            123,
            null,
            true,
            ['array'],
          ],
        };

        final stats = ProfileStats.fromJson(json);
        expect(stats.recentActivity, isEmpty); // All items filtered out
      });
    });

    // ==================== UpdateProfileRequest Tests ====================

    group('UpdateProfileRequest', () {
      test('toJson with all fields', () {
        final request = UpdateProfileRequest(
          name: 'New Name',
          email: 'newemail@example.com',
          profileImage: 'https://example.com/new-avatar.jpg',
        );

        final json = request.toJson();
        expect(json['name'], 'New Name');
        expect(json['email'], 'newemail@example.com');
        expect(json['profileImage'], 'https://example.com/new-avatar.jpg');
      });

      test('toJson with partial fields', () {
        final request = UpdateProfileRequest(name: 'New Name');

        final json = request.toJson();
        expect(json['name'], 'New Name');
        expect(json.containsKey('email'), false);
        expect(json.containsKey('profileImage'), false);
      });

      test('toJson with no fields', () {
        final request = UpdateProfileRequest();

        final json = request.toJson();
        expect(json.isEmpty, true);
      });
    });

    // ==================== ChangePasswordRequest Tests ====================

    group('ChangePasswordRequest', () {
      test('toJson with required fields', () {
        final request = ChangePasswordRequest(
          currentPassword: 'oldpass123',
          newPassword: 'newpass456',
        );

        final json = request.toJson();
        expect(json['currentPassword'], 'oldpass123');
        expect(json['newPassword'], 'newpass456');
      });
    });

    // ==================== UserProfile copyWith Tests ====================

    group('UserProfile copyWith', () {
      test('copyWith updates specified fields', () {
        final original = UserProfile(
          id: 1,
          email: 'test@example.com',
          name: 'Test User',
          role: 'USER',
        );

        final updated = original.copyWith(
          name: 'Updated Name',
          twoFactorEnabled: true,
        );

        expect(updated.id, 1); // Unchanged
        expect(updated.email, 'test@example.com'); // Unchanged
        expect(updated.name, 'Updated Name'); // Changed
        expect(updated.twoFactorEnabled, true); // Changed
      });

      test('copyWith with no changes returns equivalent object', () {
        final original = UserProfile(
          id: 1,
          email: 'test@example.com',
          role: 'USER',
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.email, original.email);
        expect(copy.role, original.role);
      });
    });

    // ==================== Serialization Round-trip Tests ====================

    group('Serialization Round-trip', () {
      test('UserProfile round-trip serialization', () {
        final original = UserProfile(
          id: 1,
          email: 'test@example.com',
          name: 'Test User',
          role: 'USER',
          profileImage: 'https://example.com/avatar.jpg',
          twoFactorEnabled: true,
          createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2025-01-15T00:00:00.000Z'),
        );

        final json = original.toJson();
        final reconstructed = UserProfile.fromJson(json);

        expect(reconstructed.id, original.id);
        expect(reconstructed.email, original.email);
        expect(reconstructed.name, original.name);
        expect(reconstructed.role, original.role);
        expect(reconstructed.profileImage, original.profileImage);
        expect(reconstructed.twoFactorEnabled, original.twoFactorEnabled);
      });

      test('ProfileStats round-trip serialization', () {
        final original = ProfileStats(
          totalKanjiStudied: 150,
          quizzesCompleted: 25,
          flashcardsReviewed: 500,
          currentStreak: 7,
          totalXp: 1500,
          averageScore: 85.5,
          recentActivity: [
            ActivityData(
              type: 'quiz',
              title: 'Test Quiz',
              timestamp: DateTime.parse('2025-10-29T10:00:00.000Z'),
              score: 90,
            ),
          ],
        );

        final json = original.toJson();
        final reconstructed = ProfileStats.fromJson(json);

        expect(reconstructed.totalKanjiStudied, original.totalKanjiStudied);
        expect(reconstructed.quizzesCompleted, original.quizzesCompleted);
        expect(reconstructed.flashcardsReviewed, original.flashcardsReviewed);
        expect(reconstructed.currentStreak, original.currentStreak);
        expect(reconstructed.totalXp, original.totalXp);
        expect(reconstructed.averageScore, original.averageScore);
        expect(
          reconstructed.recentActivity.length,
          original.recentActivity.length,
        );
      });

      test('ActivityData round-trip serialization', () {
        final original = ActivityData(
          type: 'quiz',
          title: 'JLPT N5 Quiz',
          timestamp: DateTime.parse('2025-10-29T10:00:00.000Z'),
          score: 90,
          details: 'Completed',
        );

        final json = original.toJson();
        final reconstructed = ActivityData.fromJson(json);

        expect(reconstructed.type, original.type);
        expect(reconstructed.title, original.title);
        expect(reconstructed.score, original.score);
        expect(reconstructed.details, original.details);
      });
    });
  });
}
