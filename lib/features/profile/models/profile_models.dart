// User Profile Models

class UserProfile {
  final int id;
  final String email;
  final String? name;
  final String role;
  final String? profileImage;
  final bool twoFactorEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional stats from progress
  final ProfileStats? stats;

  UserProfile({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    this.profileImage,
    this.twoFactorEnabled = false,
    this.createdAt,
    this.updatedAt,
    this.stats,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int? safeInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Helper function to safely parse DateTime
    DateTime? safeDateTime(dynamic value) {
      if (value == null) return null;
      try {
        if (value is String) {
          return DateTime.parse(value);
        }
      } catch (e) {
        return null;
      }
      return null;
    }

    // Safe type checking for stats object
    final statsData = json['stats'];
    final ProfileStats? statsObj;
    if (statsData != null && statsData is Map<String, dynamic>) {
      statsObj = ProfileStats.fromJson(statsData);
    } else {
      statsObj = null;
    }

    return UserProfile(
      id: safeInt(json['id']) ?? 0,
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      role: json['role'] as String? ?? 'USER',
      profileImage: json['profileImage'] as String?,
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      createdAt: safeDateTime(json['createdAt']),
      updatedAt: safeDateTime(json['updatedAt']),
      stats: statsObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'profileImage': profileImage,
      'twoFactorEnabled': twoFactorEnabled,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (stats != null) 'stats': stats!.toJson(),
    };
  }

  UserProfile copyWith({
    int? id,
    String? email,
    String? name,
    String? role,
    String? profileImage,
    bool? twoFactorEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProfileStats? stats,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stats: stats ?? this.stats,
    );
  }
}

class ProfileStats {
  final int totalKanjiStudied;
  final int quizzesCompleted;
  final int flashcardsReviewed;
  final int currentStreak;
  final int totalXp;
  final double averageScore;
  final List<ActivityData> recentActivity;

  ProfileStats({
    required this.totalKanjiStudied,
    required this.quizzesCompleted,
    required this.flashcardsReviewed,
    required this.currentStreak,
    required this.totalXp,
    required this.averageScore,
    required this.recentActivity,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    // Helper functions
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double safeDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Safe type checking for activity array
    final activityField = json['recentActivity'];
    final List<ActivityData> activityList;

    if (activityField != null && activityField is List) {
      activityList = activityField
          .where((a) => a is Map<String, dynamic>)
          .map((a) => ActivityData.fromJson(a as Map<String, dynamic>))
          .toList();
    } else {
      activityList = [];
    }

    return ProfileStats(
      totalKanjiStudied: safeInt(json['totalKanjiStudied']),
      quizzesCompleted: safeInt(json['quizzesCompleted']),
      flashcardsReviewed: safeInt(json['flashcardsReviewed']),
      currentStreak: safeInt(json['currentStreak']),
      totalXp: safeInt(json['totalXp']),
      averageScore: safeDouble(json['averageScore']),
      recentActivity: activityList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalKanjiStudied': totalKanjiStudied,
      'quizzesCompleted': quizzesCompleted,
      'flashcardsReviewed': flashcardsReviewed,
      'currentStreak': currentStreak,
      'totalXp': totalXp,
      'averageScore': averageScore,
      'recentActivity': recentActivity.map((a) => a.toJson()).toList(),
    };
  }
}

class ActivityData {
  final String type;
  final String title;
  final DateTime timestamp;
  final int? score;
  final String? details;

  ActivityData({
    required this.type,
    required this.title,
    required this.timestamp,
    this.score,
    this.details,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    // Helper functions
    int? safeInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    DateTime safeDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        if (value is String) {
          return DateTime.parse(value);
        }
      } catch (e) {
        return DateTime.now();
      }
      return DateTime.now();
    }

    return ActivityData(
      type: json['type'] as String? ?? 'unknown',
      title: json['title'] as String? ?? 'Activity',
      timestamp: safeDateTime(json['timestamp']),
      score: safeInt(json['score']),
      details: json['details'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'timestamp': timestamp.toIso8601String(),
      if (score != null) 'score': score,
      if (details != null) 'details': details,
    };
  }
}

class UpdateProfileRequest {
  final String? name;
  final String? profileImage;

  UpdateProfileRequest({this.name, this.profileImage});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (profileImage != null) data['profileImage'] = profileImage;
    return data;
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'currentPassword': currentPassword, 'newPassword': newPassword};
  }
}
