// User Management Models

class UserListResponse {
  final List<UserInfo> users;
  final int total;

  UserListResponse({required this.users, required this.total});

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    // Safe type checking for users array
    final usersField = json['users'];
    final List<UserInfo> usersList;

    if (usersField != null && usersField is List) {
      usersList = usersField
          .where((u) => u is Map<String, dynamic>)
          .map((u) => UserInfo.fromJson(u as Map<String, dynamic>))
          .toList();
    } else {
      usersList = [];
    }

    // Safe type checking for total
    final totalField = json['total'];
    final int totalValue;
    if (totalField is int) {
      totalValue = totalField;
    } else if (totalField is double) {
      totalValue = totalField.toInt();
    } else if (totalField is String) {
      totalValue = int.tryParse(totalField) ?? 0;
    } else {
      totalValue = 0;
    }

    return UserListResponse(users: usersList, total: totalValue);
  }

  Map<String, dynamic> toJson() {
    return {'users': users.map((u) => u.toJson()).toList(), 'total': total};
  }
}

class UserInfo {
  final int id;
  final String email;
  final String? name;
  final String role;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool twoFactorEnabled;

  // Additional fields for admin dashboard
  final int? totalQuizzes;
  final int? totalLists;
  final int? totalDecks;
  final int? totalSessions;

  UserInfo({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
    this.twoFactorEnabled = false,
    this.totalQuizzes,
    this.totalLists,
    this.totalDecks,
    this.totalSessions,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int? safeInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return UserInfo(
      id: safeInt(json['id']) ?? 0,
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      role: json['role'] as String? ?? 'USER',
      profileImage: json['profileImage'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      totalQuizzes: safeInt(json['totalQuizzes']),
      totalLists: safeInt(json['totalLists']),
      totalDecks: safeInt(json['totalDecks']),
      totalSessions: safeInt(json['totalSessions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'twoFactorEnabled': twoFactorEnabled,
      if (totalQuizzes != null) 'totalQuizzes': totalQuizzes,
      if (totalLists != null) 'totalLists': totalLists,
      if (totalDecks != null) 'totalDecks': totalDecks,
      if (totalSessions != null) 'totalSessions': totalSessions,
    };
  }

  UserInfo copyWith({
    int? id,
    String? email,
    String? name,
    String? role,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? twoFactorEnabled,
    int? totalQuizzes,
    int? totalLists,
    int? totalDecks,
    int? totalSessions,
  }) {
    return UserInfo(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      totalLists: totalLists ?? this.totalLists,
      totalDecks: totalDecks ?? this.totalDecks,
      totalSessions: totalSessions ?? this.totalSessions,
    );
  }
}

class UpdateUserRequest {
  final String? name;
  final String? email;
  final String? role;

  UpdateUserRequest({this.name, this.email, this.role});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (role != null) data['role'] = role;
    return data;
  }
}

class UserManagementStatistics {
  final int totalUsers;
  final int activeUsers;
  final int newUsersToday;
  final int newUsersThisWeek;
  final int newUsersThisMonth;
  final List<UserGrowthData> growthData;

  UserManagementStatistics({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersToday,
    required this.newUsersThisWeek,
    required this.newUsersThisMonth,
    required this.growthData,
  });

  factory UserManagementStatistics.fromJson(Map<String, dynamic> json) {
    // Safe type checking for growthData array
    final growthField = json['growthData'];
    final List<UserGrowthData> growthList;

    if (growthField != null && growthField is List) {
      growthList = growthField
          .where((g) => g is Map<String, dynamic>)
          .map((g) => UserGrowthData.fromJson(g as Map<String, dynamic>))
          .toList();
    } else {
      growthList = [];
    }

    return UserManagementStatistics(
      totalUsers: json['totalUsers'] as int? ?? 0,
      activeUsers: json['activeUsers'] as int? ?? 0,
      newUsersToday: json['newUsersToday'] as int? ?? 0,
      newUsersThisWeek: json['newUsersThisWeek'] as int? ?? 0,
      newUsersThisMonth: json['newUsersThisMonth'] as int? ?? 0,
      growthData: growthList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'newUsersToday': newUsersToday,
      'newUsersThisWeek': newUsersThisWeek,
      'newUsersThisMonth': newUsersThisMonth,
      'growthData': growthData.map((g) => g.toJson()).toList(),
    };
  }
}

class UserGrowthData {
  final String date;
  final int count;

  UserGrowthData({required this.date, required this.count});

  factory UserGrowthData.fromJson(Map<String, dynamic> json) {
    return UserGrowthData(
      date: json['date'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'count': count};
  }
}
