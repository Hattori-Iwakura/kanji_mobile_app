import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_flutter/features/auth/models/user.dart';

void main() {
  group('User Model Tests', () {
    final testUser = User(
      id: 1,
      email: 'test@example.com',
      username: 'testuser',
      avatarUrl: 'https://example.com/avatar.png',
      role: 'USER',
      createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
    );

    final testJson = {
      'id': 1,
      'email': 'test@example.com',
      'username': 'testuser',
      'avatarUrl': 'https://example.com/avatar.png',
      'role': 'USER',
      'createdAt': '2025-01-01T00:00:00.000Z',
    };

    test('should create User instance with all properties', () {
      expect(testUser.id, 1);
      expect(testUser.email, 'test@example.com');
      expect(testUser.username, 'testuser');
      expect(testUser.avatarUrl, 'https://example.com/avatar.png');
      expect(testUser.role, 'USER');
      expect(testUser.createdAt, DateTime.parse('2025-01-01T00:00:00.000Z'));
    });

    test('should create User from JSON (fromJson)', () {
      final user = User.fromJson(testJson);

      expect(user.id, testUser.id);
      expect(user.email, testUser.email);
      expect(user.username, testUser.username);
      expect(user.avatarUrl, testUser.avatarUrl);
      expect(user.role, testUser.role);
      expect(user.createdAt, testUser.createdAt);
    });

    test('should create User from JSON with null avatarUrl', () {
      final jsonWithNullAvatar = Map<String, dynamic>.from(testJson);
      jsonWithNullAvatar['avatarUrl'] = null;

      final user = User.fromJson(jsonWithNullAvatar);

      expect(user.id, 1);
      expect(user.email, 'test@example.com');
      expect(user.username, 'testuser');
      expect(user.avatarUrl, null);
      expect(user.role, 'USER');
    });

    test('should convert User to JSON (toJson)', () {
      final json = testUser.toJson();

      expect(json['id'], 1);
      expect(json['email'], 'test@example.com');
      expect(json['username'], 'testuser');
      expect(json['avatarUrl'], 'https://example.com/avatar.png');
      expect(json['role'], 'USER');
      expect(json['createdAt'], '2025-01-01T00:00:00.000Z');
    });

    test('should handle toJson with null avatarUrl', () {
      final userWithoutAvatar = User(
        id: 1,
        email: 'test@example.com',
        username: 'testuser',
        avatarUrl: null,
        role: 'USER',
        createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
      );

      final json = userWithoutAvatar.toJson();

      expect(json['avatarUrl'], null);
    });

    test('should handle fromJson -> toJson roundtrip', () {
      final user = User.fromJson(testJson);
      final json = user.toJson();

      expect(json, testJson);
    });

    test('should handle different roles (ADMIN, USER)', () {
      final adminJson = Map<String, dynamic>.from(testJson);
      adminJson['role'] = 'ADMIN';

      final adminUser = User.fromJson(adminJson);
      expect(adminUser.role, 'ADMIN');
    });

    test('should handle createdAt date parsing correctly', () {
      final customDateJson = Map<String, dynamic>.from(testJson);
      customDateJson['createdAt'] = '2024-12-25T12:30:45.123Z';

      final user = User.fromJson(customDateJson);
      expect(user.createdAt, DateTime.parse('2024-12-25T12:30:45.123Z'));
    });
  });
}
