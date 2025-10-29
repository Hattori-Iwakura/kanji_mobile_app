import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/features/admin/models/admin_models.dart';

void main() {
  group('Admin Models - JSON Parsing Tests', () {
    group('UserStats', () {
      test('should parse valid JSON correctly', () {
        final json = {'total': 100, 'active': 50, 'new': 10};

        final result = UserStats.fromJson(json);

        expect(result.total, 100);
        expect(result.active, 50);
        expect(result.newUsers, 10);
      });

      test('should handle null values with defaults', () {
        final json = {'total': null, 'active': null, 'new': null};

        final result = UserStats.fromJson(json);

        expect(result.total, 0);
        expect(result.active, 0);
        expect(result.newUsers, 0);
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};

        final result = UserStats.fromJson(json);

        expect(result.total, 0);
        expect(result.active, 0);
        expect(result.newUsers, 0);
      });
    });

    group('ContentStats', () {
      test('should parse valid JSON correctly', () {
        final json = {'kanji': 100, 'quizzes': 50, 'lists': 20, 'decks': 15};

        final result = ContentStats.fromJson(json);

        expect(result.kanji, 100);
        expect(result.quizzes, 50);
        expect(result.lists, 20);
        expect(result.decks, 15);
      });

      test('should handle null values with defaults', () {
        final json = {
          'kanji': null,
          'quizzes': null,
          'lists': null,
          'decks': null,
        };

        final result = ContentStats.fromJson(json);

        expect(result.kanji, 0);
        expect(result.quizzes, 0);
        expect(result.lists, 0);
        expect(result.decks, 0);
      });
    });

    group('GrowthData', () {
      test('should parse valid JSON correctly', () {
        final json = {'count': 10, 'percentage': 15.5};

        final result = GrowthData.fromJson(json);

        expect(result.count, 10);
        expect(result.percentage, 15.5);
      });

      test('should handle null values with defaults', () {
        final json = {'count': null, 'percentage': null};

        final result = GrowthData.fromJson(json);

        expect(result.count, 0);
        expect(result.percentage, 0.0);
      });

      test('should handle integer as percentage', () {
        final json = {
          'count': 10,
          'percentage': 15, // int instead of double
        };

        final result = GrowthData.fromJson(json);

        expect(result.count, 10);
        expect(result.percentage, 15.0);
      });
    });

    group('UserStatistics', () {
      test('should parse valid JSON with growth data', () {
        final json = {
          'totalUsers': 1000,
          'activeUsers': 500,
          'newUsers': 50,
          'growth': {'count': 10, 'percentage': 2.5},
          'retention': {'day1': 80, 'day7': 60},
        };

        final result = UserStatistics.fromJson(json);

        expect(result.totalUsers, 1000);
        expect(result.activeUsers, 500);
        expect(result.newUsers, 50);
        expect(result.growth, isNotNull);
        expect(result.growth!.count, 10);
        expect(result.growth!.percentage, 2.5);
        expect(result.retention, isNotNull);
      });

      test('should handle null growth data', () {
        final json = {
          'totalUsers': 1000,
          'activeUsers': 500,
          'newUsers': 50,
          'growth': null,
          'retention': null,
        };

        final result = UserStatistics.fromJson(json);

        expect(result.totalUsers, 1000);
        expect(result.growth, isNull);
        expect(result.retention, isNull);
      });
    });

    group('TypeStat', () {
      test('should parse valid JSON correctly', () {
        final json = {'total': 100, 'pending': 20, 'approved': 80};

        final result = TypeStat.fromJson(json);

        expect(result.total, 100);
        expect(result.pending, 20);
        expect(result.approved, 80);
      });

      test('should handle null values', () {
        final json = {'total': null, 'pending': null, 'approved': null};

        final result = TypeStat.fromJson(json);

        expect(result.total, 0);
        expect(result.pending, 0);
        expect(result.approved, 0);
      });
    });

    group('PublishTypeStats', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'quiz': {'total': 50, 'pending': 10, 'approved': 40},
          'list': {'total': 30, 'pending': 5, 'approved': 25},
          'deck': {'total': 20, 'pending': 3, 'approved': 17},
        };

        final result = PublishTypeStats.fromJson(json);

        expect(result.quiz.total, 50);
        expect(result.list.total, 30);
        expect(result.deck.total, 20);
      });

      test('should handle null nested objects', () {
        final json = {'quiz': null, 'list': null, 'deck': null};

        final result = PublishTypeStats.fromJson(json);

        expect(result.quiz.total, 0);
        expect(result.list.total, 0);
        expect(result.deck.total, 0);
      });
    });

    group('PublishStatistics', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'total': 100,
          'pending': 15,
          'approved': 85,
          'byType': {
            'quiz': {'total': 50, 'pending': 10, 'approved': 40},
            'list': {'total': 30, 'pending': 5, 'approved': 25},
            'deck': {'total': 20, 'pending': 0, 'approved': 20},
          },
        };

        final result = PublishStatistics.fromJson(json);

        expect(result.total, 100);
        expect(result.pending, 15);
        expect(result.approved, 85);
        expect(result.byType.quiz.total, 50);
      });

      test('should handle null byType', () {
        final json = {
          'total': 100,
          'pending': 15,
          'approved': 85,
          'byType': null,
        };

        final result = PublishStatistics.fromJson(json);

        expect(result.total, 100);
        expect(result.byType.quiz.total, 0);
      });
    });

    group('ChartDataPoint', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'label': 'Mon',
          'value': 100,
          'timestamp': '2024-01-01T00:00:00.000Z',
        };

        final result = ChartDataPoint.fromJson(json);

        expect(result.label, 'Mon');
        expect(result.value, 100);
        expect(result.timestamp, isNotNull);
      });

      test('should handle null values', () {
        final json = {'label': null, 'value': null, 'timestamp': null};

        final result = ChartDataPoint.fromJson(json);

        expect(result.label, '');
        expect(result.value, 0);
        expect(result.timestamp, isNull);
      });
    });

    group('ChartData', () {
      test('should parse valid JSON with data array', () {
        final json = {
          'data': [
            {'label': 'Mon', 'value': 100},
            {'label': 'Tue', 'value': 150},
            {'label': 'Wed', 'value': 120},
          ],
          'period': 'week',
          'summary': {'total': 370, 'average': 123.3},
        };

        final result = ChartData.fromJson(json);

        expect(result.data.length, 3);
        expect(result.data[0].label, 'Mon');
        expect(result.data[0].value, 100);
        expect(result.period, 'week');
        expect(result.summary, isNotNull);
      });

      test('should handle empty data array', () {
        final json = {'data': [], 'period': 'week'};

        final result = ChartData.fromJson(json);

        expect(result.data, isEmpty);
        expect(result.period, 'week');
      });

      test('should handle null data array', () {
        final json = {'data': null, 'period': null};

        final result = ChartData.fromJson(json);

        expect(result.data, isEmpty);
        expect(result.period, 'week'); // default
      });
    });

    group('PerformanceMetrics', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'cpu': 45.5,
          'responseTime': 123.4,
          'requestsPerMinute': 1500,
        };

        final result = PerformanceMetrics.fromJson(json);

        expect(result.cpu, 45.5);
        expect(result.responseTime, 123.4);
        expect(result.requestsPerMinute, 1500);
      });

      test('should handle null values', () {
        final json = {
          'cpu': null,
          'responseTime': null,
          'requestsPerMinute': null,
        };

        final result = PerformanceMetrics.fromJson(json);

        expect(result.cpu, 0.0);
        expect(result.responseTime, 0.0);
        expect(result.requestsPerMinute, 0);
      });

      test('should handle integer values for double fields', () {
        final json = {
          'cpu': 45, // int instead of double
          'responseTime': 123, // int instead of double
          'requestsPerMinute': 1500,
        };

        final result = PerformanceMetrics.fromJson(json);

        expect(result.cpu, 45.0);
        expect(result.responseTime, 123.0);
      });
    });

    group('DatabaseMetrics', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'connections': 50,
          'queryTime': 25.5,
          'totalQueries': 10000,
        };

        final result = DatabaseMetrics.fromJson(json);

        expect(result.connections, 50);
        expect(result.queryTime, 25.5);
        expect(result.totalQueries, 10000);
      });

      test('should handle null values', () {
        final json = {
          'connections': null,
          'queryTime': null,
          'totalQueries': null,
        };

        final result = DatabaseMetrics.fromJson(json);

        expect(result.connections, 0);
        expect(result.queryTime, 0.0);
        expect(result.totalQueries, 0);
      });
    });

    group('MemoryMetrics', () {
      test('should parse valid JSON correctly', () {
        final json = {'used': 512.5, 'total': 1024.0, 'percentage': 50.05};

        final result = MemoryMetrics.fromJson(json);

        expect(result.used, 512.5);
        expect(result.total, 1024.0);
        expect(result.percentage, 50.05);
      });

      test('should handle null values', () {
        final json = {'used': null, 'total': null, 'percentage': null};

        final result = MemoryMetrics.fromJson(json);

        expect(result.used, 0.0);
        expect(result.total, 0.0);
        expect(result.percentage, 0.0);
      });
    });

    group('SystemMetrics', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'performance': {
            'cpu': 45.5,
            'responseTime': 123.4,
            'requestsPerMinute': 1500,
          },
          'database': {
            'connections': 50,
            'queryTime': 25.5,
            'totalQueries': 10000,
          },
          'memory': {'used': 512.5, 'total': 1024.0, 'percentage': 50.05},
          'timestamp': '2024-01-01T12:00:00.000Z',
        };

        final result = SystemMetrics.fromJson(json);

        expect(result.performance.cpu, 45.5);
        expect(result.database.connections, 50);
        expect(result.memory.used, 512.5);
        expect(result.timestamp, isNotNull);
      });

      test('should handle null nested objects', () {
        final json = {
          'performance': null,
          'database': null,
          'memory': null,
          'timestamp': null,
        };

        final result = SystemMetrics.fromJson(json);

        expect(result.performance.cpu, 0.0);
        expect(result.database.connections, 0);
        expect(result.memory.used, 0.0);
        expect(result.timestamp, isNotNull); // DateTime.now() as fallback
      });
    });

    group('RecentActivity', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'type': 'quiz',
          'count': 15,
          'timestamp': '2024-01-01T10:30:00.000Z',
        };

        final result = RecentActivity.fromJson(json);

        expect(result.type, 'quiz');
        expect(result.count, 15);
        expect(result.timestamp, isNotNull);
      });

      test('should handle null values', () {
        final json = {
          'type': null,
          'count': null,
          'timestamp': '2024-01-01T10:30:00.000Z', // timestamp required
        };

        final result = RecentActivity.fromJson(json);

        expect(result.type, 'Unknown');
        expect(result.count, 0);
      });
    });

    group('ActivityStatistics', () {
      test('should parse valid JSON with activities', () {
        final json = {
          'totalSessions': 500,
          'totalAttempts': 2500,
          'recentActivities': [
            {
              'type': 'quiz',
              'count': 15,
              'timestamp': '2024-01-01T10:30:00.000Z',
            },
            {
              'type': 'flashcard',
              'count': 25,
              'timestamp': '2024-01-01T11:00:00.000Z',
            },
          ],
          'byType': {'quiz': 100, 'flashcard': 200},
        };

        final result = ActivityStatistics.fromJson(json);

        expect(result.totalSessions, 500);
        expect(result.totalAttempts, 2500);
        expect(result.recentActivities.length, 2);
        expect(result.recentActivities[0].type, 'quiz');
        expect(result.byType, isNotNull);
      });

      test('should handle null activities array', () {
        final json = {
          'totalSessions': 500,
          'totalAttempts': 2500,
          'recentActivities': null,
          'byType': null,
        };

        final result = ActivityStatistics.fromJson(json);

        expect(result.totalSessions, 500);
        expect(result.recentActivities, isEmpty);
      });
    });

    group('DashboardOverview', () {
      test('should parse complete valid JSON', () {
        final json = {
          'users': {'total': 1000, 'active': 500, 'new': 50},
          'content': {'kanji': 2000, 'quizzes': 100, 'lists': 50, 'decks': 30},
          'activity': {
            'activeUsers': 500,
            'pendingPublishRequests': 10,
            'recentPublishRequests': 5,
          },
        };

        final result = DashboardOverview.fromJson(json);

        expect(result.users.total, 1000);
        expect(result.content.kanji, 2000);
        expect(result.activity.activeUsers, 500);
      });

      test('should handle null nested objects', () {
        final json = {'users': null, 'content': null, 'activity': null};

        final result = DashboardOverview.fromJson(json);

        expect(result.users.total, 0);
        expect(result.content.kanji, 0);
        expect(result.activity.activeUsers, 0);
      });
    });

    group('User', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'id': 123,
          'email': 'test@example.com',
          'name': 'Test User',
        };

        final result = User.fromJson(json);

        expect(result.id, 123);
        expect(result.email, 'test@example.com');
        expect(result.name, 'Test User');
      });

      test('should handle null values', () {
        final json = {'id': null, 'email': null, 'name': null};

        final result = User.fromJson(json);

        expect(result.id, 0);
        expect(result.email, '');
        expect(result.name, isNull);
      });
    });

    group('PublishRequest', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'id': 1,
          'type': 'quiz',
          'status': 'pending',
          'createdAt': '2024-01-01T10:00:00.000Z',
          'reviewedAt': null,
          'reviewedBy': null,
          'reviewMessage': null,
          'quiz': {'id': 1, 'title': 'Test Quiz'},
          'list': null,
          'deck': null,
          'user': {'id': 123, 'email': 'user@example.com', 'name': 'User'},
          'reviewer': null,
        };

        final result = PublishRequest.fromJson(json);

        expect(result.id, 1);
        expect(result.type, 'quiz');
        expect(result.status, 'pending');
        expect(result.user, isNotNull);
        expect(result.title, 'Test Quiz');
      });

      test('should handle null values', () {
        final json = {
          'id': null,
          'type': null,
          'status': null,
          'createdAt': '2024-01-01T10:00:00.000Z',
          'reviewedAt': null,
          'reviewedBy': null,
          'reviewMessage': null,
          'quiz': null,
          'list': null,
          'deck': null,
          'user': null,
          'reviewer': null,
        };

        final result = PublishRequest.fromJson(json);

        expect(result.id, 0);
        expect(result.type, '');
        expect(result.status, '');
        expect(result.title, 'Untitled');
      });
    });

    group('SystemHealth', () {
      test('should parse valid JSON correctly', () {
        final json = {
          'status': 'healthy',
          'database': 'connected',
          'timestamp': '2024-01-01T12:00:00.000Z',
          'checks': {'api': 'ok', 'redis': 'ok'},
        };

        final result = SystemHealth.fromJson(json);

        expect(result.status, 'healthy');
        expect(result.database, 'connected');
        expect(result.isHealthy, true);
        expect(result.checks, isNotNull);
      });

      test('should detect unhealthy status', () {
        final json = {
          'status': 'degraded',
          'database': 'connected',
          'timestamp': '2024-01-01T12:00:00.000Z',
        };

        final result = SystemHealth.fromJson(json);

        expect(result.isHealthy, false);
      });
    });
  });
}
