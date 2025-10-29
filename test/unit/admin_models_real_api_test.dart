import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/features/admin/models/admin_models.dart';

void main() {
  group('Admin Models - Real API Response Tests', () {
    // Đây là test với dữ liệu giống API thực tế trả về
    // Để kiểm tra các lỗi type casting trong runtime

    test('PublishStatistics with real API response structure', () {
      // API có thể trả về như thế này
      final jsonResponse = {
        'total': 10,
        'pending': 5,
        'approved': 5,
        'byType': {
          'quiz': {'total': 5, 'pending': 2, 'approved': 3},
          'list': {'total': 3, 'pending': 2, 'approved': 1},
          'deck': {'total': 2, 'pending': 1, 'approved': 1},
        },
      };

      expect(() => PublishStatistics.fromJson(jsonResponse), returnsNormally);

      final result = PublishStatistics.fromJson(jsonResponse);
      expect(result.total, 10);
      expect(result.byType.quiz.total, 5);
    });

    test('DashboardOverview with nested Map casting', () {
      // Test case thực tế khi API trả về nested objects
      final jsonResponse = {
        'users': {'total': 100, 'active': 50, 'new': 10},
        'content': {'kanji': 2136, 'quizzes': 50, 'lists': 20, 'decks': 15},
        'activity': {
          'activeUsers': 50,
          'pendingPublishRequests': 5,
          'recentPublishRequests': 10,
        },
      };

      expect(() => DashboardOverview.fromJson(jsonResponse), returnsNormally);
    });

    test('ChartData with array of objects', () {
      // Test với array từ API
      final jsonResponse = {
        'data': [
          {'label': 'Mon', 'value': 10},
          {'label': 'Tue', 'value': 15},
          {'label': 'Wed', 'value': 20},
        ],
        'period': 'week',
        'summary': {'total': 45, 'average': 15.0},
      };

      expect(() => ChartData.fromJson(jsonResponse), returnsNormally);

      final result = ChartData.fromJson(jsonResponse);
      expect(result.data.length, 3);
      expect(result.data[0].label, 'Mon');
    });

    test('ActivityStatistics with recentActivities array', () {
      final jsonResponse = {
        'totalSessions': 100,
        'totalAttempts': 500,
        'recentActivities': [
          {
            'type': 'quiz',
            'count': 10,
            'timestamp': '2024-10-29T10:00:00.000Z',
          },
          {
            'type': 'flashcard',
            'count': 15,
            'timestamp': '2024-10-29T11:00:00.000Z',
          },
        ],
        'byType': {'quiz': 50, 'flashcard': 50},
      };

      expect(() => ActivityStatistics.fromJson(jsonResponse), returnsNormally);

      final result = ActivityStatistics.fromJson(jsonResponse);
      expect(result.recentActivities.length, 2);
    });

    test('SystemMetrics with nested performance/database/memory', () {
      final jsonResponse = {
        'performance': {
          'cpu': 45.5,
          'responseTime': 120.3,
          'requestsPerMinute': 1500,
        },
        'database': {
          'connections': 50,
          'queryTime': 25.5,
          'totalQueries': 10000,
        },
        'memory': {'used': 512.0, 'total': 1024.0, 'percentage': 50.0},
        'timestamp': '2024-10-29T12:00:00.000Z',
      };

      expect(() => SystemMetrics.fromJson(jsonResponse), returnsNormally);
    });

    test('Handle dynamic types from API (int vs double)', () {
      // API có thể trả về int thay vì double
      final jsonResponse = {
        'cpu': 45, // int not double
        'responseTime': 120, // int not double
        'requestsPerMinute': 1500,
      };

      expect(() => PerformanceMetrics.fromJson(jsonResponse), returnsNormally);

      final result = PerformanceMetrics.fromJson(jsonResponse);
      expect(result.cpu, 45.0);
      expect(result.responseTime, 120.0);
    });

    test('UserStatistics with optional growth', () {
      final jsonResponse = {
        'totalUsers': 1000,
        'activeUsers': 500,
        'newUsers': 50,
        'growth': {'count': 10, 'percentage': 2.5},
        'retention': {'day1': 80, 'day7': 60, 'day30': 40},
      };

      expect(() => UserStatistics.fromJson(jsonResponse), returnsNormally);
    });

    test('ContentStatistics with optional growth', () {
      final jsonResponse = {
        'totalKanji': 2136,
        'totalQuizzes': 100,
        'totalDecks': 50,
        'totalLists': 30,
        'growth': {'count': 5, 'percentage': 1.5},
        'byType': {
          'jlpt': {'N5': 100, 'N4': 200, 'N3': 300},
        },
      };

      expect(() => ContentStatistics.fromJson(jsonResponse), returnsNormally);
    });

    group('Edge Cases - Type Mismatches', () {
      test('should handle when byType is returned as List instead of Map', () {
        // Đây là lỗi thường gặp: API trả về List thay vì Map
        final jsonResponse = {
          'total': 10,
          'pending': 5,
          'approved': 5,
          'byType': [], // Empty array instead of object
        };

        // Bây giờ KHÔNG còn throw error nữa, trả về default values
        final stats = PublishStatistics.fromJson(jsonResponse);
        expect(stats.total, 10);
        expect(stats.pending, 5);
        expect(stats.approved, 5);
        // byType nên có default values
        expect(stats.byType.quiz.total, 0);
        expect(stats.byType.list.total, 0);
        expect(stats.byType.deck.total, 0);
      });

      test('should handle when data is returned as Map instead of List', () {
        final jsonResponse = {
          'data': {}, // Object instead of array
          'period': 'week',
        };

        // Bây giờ KHÔNG còn throw error, trả về empty list
        final chartData = ChartData.fromJson(jsonResponse);
        expect(chartData.data, isEmpty);
        expect(chartData.period, 'week');
      });

      test('should handle when nested object is missing required field', () {
        final jsonResponse = {
          'performance': {
            // missing 'cpu' field
            'responseTime': 120.0,
            'requestsPerMinute': 1500,
          },
          'database': {
            'connections': 50,
            'queryTime': 25.5,
            'totalQueries': 10000,
          },
          'memory': {'used': 512.0, 'total': 1024.0, 'percentage': 50.0},
          'timestamp': '2024-10-29T12:00:00.000Z',
        };

        expect(
          () => SystemMetrics.fromJson(jsonResponse),
          returnsNormally, // Should use default value
        );
      });
    });

    group('Debug - Verify type validation works', () {
      test('byType as List should use default values', () {
        final badJson = {
          'total': 10,
          'pending': 5,
          'approved': 5,
          'byType': [], // Wrong type!
        };

        // Should NOT throw, should return object with defaults
        final stats = PublishStatistics.fromJson(badJson);
        expect(stats, isNotNull);
        expect(stats.total, 10);
        expect(stats.byType.quiz.total, 0); // Default value
      });

      test('data as Map should return empty list', () {
        final badJson = {
          'data': {}, // Object instead of array
          'period': 'week',
        };

        // Should NOT throw, should return empty list
        final chartData = ChartData.fromJson(badJson);
        expect(chartData, isNotNull);
        expect(chartData.data, isEmpty);
      });

      test('nested objects as List should use defaults', () {
        final badJson = {
          'users': [], // Array instead of object
          'content': {'kanji': 2136, 'quizzes': 50, 'lists': 20, 'decks': 15},
          'activity': {
            'activeUsers': 50,
            'pendingPublishRequests': 5,
            'recentPublishRequests': 10,
          },
        };

        // Should NOT throw, should use default for users
        final overview = DashboardOverview.fromJson(badJson);
        expect(overview, isNotNull);
        expect(overview.users.total, 0); // Default value
        expect(overview.content.kanji, 2136); // Works fine
      });
    });
  });
}
