// Admin Dashboard Models

class DashboardOverview {
  final UserStats users;
  final ContentStats content;
  final ActivityStats activity;

  DashboardOverview({
    required this.users,
    required this.content,
    required this.activity,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    // Safe type checking for nested objects
    final usersData = json['users'];
    final UserStats usersObj;
    if (usersData != null && usersData is Map<String, dynamic>) {
      usersObj = UserStats.fromJson(usersData);
    } else {
      usersObj = UserStats(total: 0, active: 0, newUsers: 0);
    }

    final contentData = json['content'];
    final ContentStats contentObj;
    if (contentData != null && contentData is Map<String, dynamic>) {
      contentObj = ContentStats.fromJson(contentData);
    } else {
      contentObj = ContentStats(kanji: 0, quizzes: 0, lists: 0, decks: 0);
    }

    final activityData = json['activity'];
    final ActivityStats activityObj;
    if (activityData != null && activityData is Map<String, dynamic>) {
      activityObj = ActivityStats.fromJson(activityData);
    } else {
      activityObj = ActivityStats(
        activeUsers: 0,
        pendingPublishRequests: 0,
        recentPublishRequests: 0,
      );
    }

    return DashboardOverview(
      users: usersObj,
      content: contentObj,
      activity: activityObj,
    );
  }
}

class UserStats {
  final int total;
  final int active;
  final int newUsers;

  UserStats({
    required this.total,
    required this.active,
    required this.newUsers,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      total: json['total'] as int? ?? 0,
      active: json['active'] as int? ?? 0,
      newUsers: json['new'] as int? ?? 0,
    );
  }
}

class ContentStats {
  final int kanji;
  final int quizzes;
  final int lists;
  final int decks;

  ContentStats({
    required this.kanji,
    required this.quizzes,
    required this.lists,
    required this.decks,
  });

  factory ContentStats.fromJson(Map<String, dynamic> json) {
    return ContentStats(
      kanji: json['kanji'] as int? ?? 0,
      quizzes: json['quizzes'] as int? ?? 0,
      lists: json['lists'] as int? ?? 0,
      decks: json['decks'] as int? ?? 0,
    );
  }
}

class ActivityStats {
  final int activeUsers;
  final int pendingPublishRequests;
  final int recentPublishRequests;

  ActivityStats({
    required this.activeUsers,
    required this.pendingPublishRequests,
    required this.recentPublishRequests,
  });

  factory ActivityStats.fromJson(Map<String, dynamic> json) {
    return ActivityStats(
      activeUsers: json['activeUsers'] as int? ?? 0,
      pendingPublishRequests: json['pendingPublishRequests'] as int? ?? 0,
      recentPublishRequests: json['recentPublishRequests'] as int? ?? 0,
    );
  }
}

class PublishRequestsResponse {
  final List<PublishRequest> requests;
  final int total;

  PublishRequestsResponse({required this.requests, required this.total});

  factory PublishRequestsResponse.fromJson(Map<String, dynamic> json) {
    final requestsList = json['requests'] as List?;
    return PublishRequestsResponse(
      requests: requestsList != null
          ? requestsList.map((r) => PublishRequest.fromJson(r)).toList()
          : [],
      total: json['total'] as int? ?? 0,
    );
  }
}

class PublishRequest {
  final int id;
  final String type;
  final String status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final int? reviewedBy;
  final String? reviewMessage;
  final dynamic quiz;
  final dynamic list;
  final dynamic deck;
  final User? user;
  final User? reviewer;

  PublishRequest({
    required this.id,
    required this.type,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewMessage,
    this.quiz,
    this.list,
    this.deck,
    this.user,
    this.reviewer,
  });

  factory PublishRequest.fromJson(Map<String, dynamic> json) {
    return PublishRequest(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      reviewedBy: json['reviewedBy'] as int?,
      reviewMessage: json['reviewMessage'] as String?,
      quiz: json['quiz'],
      list: json['list'] ?? json['kanjiList'],
      deck: json['deck'] ?? json['flashcardDeck'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      reviewer: json['reviewer'] != null
          ? User.fromJson(json['reviewer'])
          : null,
    );
  }

  String get title {
    if (quiz != null) return quiz['title'] ?? 'Untitled Quiz';
    if (list != null) return list['name'] ?? 'Untitled List';
    if (deck != null) return deck['name'] ?? 'Untitled Deck';
    return 'Untitled';
  }

  String get typeLabel {
    switch (type) {
      case 'quiz':
        return 'Quiz';
      case 'list':
        return 'Kanji List';
      case 'deck':
        return 'Flashcard Deck';
      default:
        return type;
    }
  }
}

class User {
  final int id;
  final String email;
  final String? name;

  User({required this.id, required this.email, this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
    );
  }
}

class PublishStatistics {
  final int total;
  final int pending;
  final int approved;
  final PublishTypeStats byType;

  PublishStatistics({
    required this.total,
    required this.pending,
    required this.approved,
    required this.byType,
  });

  factory PublishStatistics.fromJson(Map<String, dynamic> json) {
    // Check if byType is actually a Map before casting
    final byTypeData = json['byType'];
    final PublishTypeStats byTypeStats;

    if (byTypeData != null && byTypeData is Map<String, dynamic>) {
      byTypeStats = PublishTypeStats.fromJson(byTypeData);
    } else {
      byTypeStats = PublishTypeStats(
        quiz: TypeStat(total: 0, pending: 0, approved: 0),
        list: TypeStat(total: 0, pending: 0, approved: 0),
        deck: TypeStat(total: 0, pending: 0, approved: 0),
      );
    }

    return PublishStatistics(
      total: json['total'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      approved: json['approved'] as int? ?? 0,
      byType: byTypeStats,
    );
  }
}

class PublishTypeStats {
  final TypeStat quiz;
  final TypeStat list;
  final TypeStat deck;

  PublishTypeStats({
    required this.quiz,
    required this.list,
    required this.deck,
  });

  factory PublishTypeStats.fromJson(Map<String, dynamic> json) {
    return PublishTypeStats(
      quiz: json['quiz'] != null
          ? TypeStat.fromJson(json['quiz'] as Map<String, dynamic>)
          : TypeStat(total: 0, pending: 0, approved: 0),
      list: json['list'] != null
          ? TypeStat.fromJson(json['list'] as Map<String, dynamic>)
          : TypeStat(total: 0, pending: 0, approved: 0),
      deck: json['deck'] != null
          ? TypeStat.fromJson(json['deck'] as Map<String, dynamic>)
          : TypeStat(total: 0, pending: 0, approved: 0),
    );
  }
}

class TypeStat {
  final int total;
  final int pending;
  final int approved;

  TypeStat({
    required this.total,
    required this.pending,
    required this.approved,
  });

  factory TypeStat.fromJson(Map<String, dynamic> json) {
    return TypeStat(
      total: json['total'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      approved: json['approved'] as int? ?? 0,
    );
  }
}

class SystemHealth {
  final String status;
  final String database;
  final DateTime timestamp;
  final Map<String, dynamic>? checks;

  SystemHealth({
    required this.status,
    required this.database,
    required this.timestamp,
    this.checks,
  });

  factory SystemHealth.fromJson(Map<String, dynamic> json) {
    return SystemHealth(
      status: json['status'],
      database: json['database'],
      timestamp: DateTime.parse(json['timestamp']),
      checks: json['checks'],
    );
  }

  bool get isHealthy => status == 'healthy';
}

// Detailed Statistics Models
class UserStatistics {
  final int totalUsers;
  final int activeUsers;
  final int newUsers;
  final GrowthData? growth;
  final Map<String, dynamic>? retention;

  UserStatistics({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsers,
    this.growth,
    this.retention,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalUsers: json['totalUsers'] as int? ?? 0,
      activeUsers: json['activeUsers'] as int? ?? 0,
      newUsers: json['newUsers'] as int? ?? 0,
      growth: json['growth'] != null
          ? GrowthData.fromJson(json['growth'] as Map<String, dynamic>)
          : null,
      retention: json['retention'] as Map<String, dynamic>?,
    );
  }
}

class GrowthData {
  final int count;
  final double percentage;

  GrowthData({required this.count, required this.percentage});

  factory GrowthData.fromJson(Map<String, dynamic> json) {
    return GrowthData(
      count: json['count'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ContentStatistics {
  final int totalKanji;
  final int totalQuizzes;
  final int totalDecks;
  final int totalLists;
  final GrowthData? growth;
  final Map<String, dynamic>? byType;

  ContentStatistics({
    required this.totalKanji,
    required this.totalQuizzes,
    required this.totalDecks,
    required this.totalLists,
    this.growth,
    this.byType,
  });

  factory ContentStatistics.fromJson(Map<String, dynamic> json) {
    return ContentStatistics(
      totalKanji: json['totalKanji'] as int? ?? 0,
      totalQuizzes: json['totalQuizzes'] as int? ?? 0,
      totalDecks: json['totalDecks'] as int? ?? 0,
      totalLists: json['totalLists'] as int? ?? 0,
      growth: json['growth'] != null
          ? GrowthData.fromJson(json['growth'] as Map<String, dynamic>)
          : null,
      byType: json['byType'] as Map<String, dynamic>?,
    );
  }
}

class ActivityStatistics {
  final int totalSessions;
  final int totalAttempts;
  final List<RecentActivity> recentActivities;
  final Map<String, dynamic>? byType;

  ActivityStatistics({
    required this.totalSessions,
    required this.totalAttempts,
    required this.recentActivities,
    this.byType,
  });

  factory ActivityStatistics.fromJson(Map<String, dynamic> json) {
    // Safe type checking for array
    final activitiesField = json['recentActivities'];
    final List<RecentActivity> activities;

    if (activitiesField != null && activitiesField is List) {
      activities = activitiesField
          .where((a) => a is Map<String, dynamic>)
          .map((a) => RecentActivity.fromJson(a as Map<String, dynamic>))
          .toList();
    } else {
      activities = [];
    }

    return ActivityStatistics(
      totalSessions: json['totalSessions'] as int? ?? 0,
      totalAttempts: json['totalAttempts'] as int? ?? 0,
      recentActivities: activities,
      byType: json['byType'] is Map<String, dynamic>
          ? json['byType'] as Map<String, dynamic>
          : null,
    );
  }
}

class RecentActivity {
  final String type;
  final int count;
  final DateTime timestamp;

  RecentActivity({
    required this.type,
    required this.count,
    required this.timestamp,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'] as String? ?? 'Unknown',
      count: json['count'] as int? ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

// Chart Data Models
class ChartData {
  final List<ChartDataPoint> data;
  final String period;
  final Map<String, dynamic>? summary;

  ChartData({required this.data, required this.period, this.summary});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    // Safe type checking for data array
    final dataField = json['data'];
    final List<ChartDataPoint> dataPoints;

    if (dataField != null && dataField is List) {
      dataPoints = dataField
          .where((d) => d is Map<String, dynamic>)
          .map((d) => ChartDataPoint.fromJson(d as Map<String, dynamic>))
          .toList();
    } else {
      dataPoints = [];
    }

    return ChartData(
      data: dataPoints,
      period: json['period'] as String? ?? 'week',
      summary: json['summary'] is Map<String, dynamic>
          ? json['summary'] as Map<String, dynamic>
          : null,
    );
  }
}

class ChartDataPoint {
  final String label;
  final int value;
  final DateTime? timestamp;

  ChartDataPoint({required this.label, required this.value, this.timestamp});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      label: json['label'] as String? ?? '',
      value: json['value'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }
}

// System Metrics Models
class SystemMetrics {
  final PerformanceMetrics performance;
  final DatabaseMetrics database;
  final MemoryMetrics memory;
  final DateTime timestamp;

  SystemMetrics({
    required this.performance,
    required this.database,
    required this.memory,
    required this.timestamp,
  });

  factory SystemMetrics.fromJson(Map<String, dynamic> json) {
    // Safe type checking for nested objects
    final performanceData = json['performance'];
    final PerformanceMetrics performanceObj;
    if (performanceData != null && performanceData is Map<String, dynamic>) {
      performanceObj = PerformanceMetrics.fromJson(performanceData);
    } else {
      performanceObj = PerformanceMetrics(
        cpu: 0.0,
        responseTime: 0.0,
        requestsPerMinute: 0,
      );
    }

    final databaseData = json['database'];
    final DatabaseMetrics databaseObj;
    if (databaseData != null && databaseData is Map<String, dynamic>) {
      databaseObj = DatabaseMetrics.fromJson(databaseData);
    } else {
      databaseObj = DatabaseMetrics(
        connections: 0,
        queryTime: 0.0,
        totalQueries: 0,
      );
    }

    final memoryData = json['memory'];
    final MemoryMetrics memoryObj;
    if (memoryData != null && memoryData is Map<String, dynamic>) {
      memoryObj = MemoryMetrics.fromJson(memoryData);
    } else {
      memoryObj = MemoryMetrics(used: 0.0, total: 0.0, percentage: 0.0);
    }

    return SystemMetrics(
      performance: performanceObj,
      database: databaseObj,
      memory: memoryObj,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}

class PerformanceMetrics {
  final double cpu;
  final double responseTime;
  final int requestsPerMinute;

  PerformanceMetrics({
    required this.cpu,
    required this.responseTime,
    required this.requestsPerMinute,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      cpu: (json['cpu'] as num?)?.toDouble() ?? 0.0,
      responseTime: (json['responseTime'] as num?)?.toDouble() ?? 0.0,
      requestsPerMinute: json['requestsPerMinute'] as int? ?? 0,
    );
  }
}

class DatabaseMetrics {
  final int connections;
  final double queryTime;
  final int totalQueries;

  DatabaseMetrics({
    required this.connections,
    required this.queryTime,
    required this.totalQueries,
  });

  factory DatabaseMetrics.fromJson(Map<String, dynamic> json) {
    return DatabaseMetrics(
      connections: json['connections'] as int? ?? 0,
      queryTime: (json['queryTime'] as num?)?.toDouble() ?? 0.0,
      totalQueries: json['totalQueries'] as int? ?? 0,
    );
  }
}

class MemoryMetrics {
  final double used;
  final double total;
  final double percentage;

  MemoryMetrics({
    required this.used,
    required this.total,
    required this.percentage,
  });

  factory MemoryMetrics.fromJson(Map<String, dynamic> json) {
    return MemoryMetrics(
      used: (json['used'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
