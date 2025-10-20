import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_flutter/features/auth/models/auth_response.dart';
import 'package:kanji_flutter/features/auth/models/user.dart';

void main() {
  group('AuthResponse Model Tests', () {
    final testUser = User(
      id: 1,
      email: 'test@example.com',
      username: 'testuser',
      avatarUrl: null,
      role: 'USER',
      createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
    );

    const testToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.token';

    final testJson = {
      'user': {
        'id': 1,
        'email': 'test@example.com',
        'username': 'testuser',
        'avatarUrl': null,
        'role': 'USER',
        'createdAt': '2025-01-01T00:00:00.000Z',
      },
      'token': testToken,
    };

    test('should create AuthResponse instance with user and token', () {
      final authResponse = AuthResponse(user: testUser, token: testToken);

      expect(authResponse.user, testUser);
      expect(authResponse.token, testToken);
    });

    test('should create AuthResponse from JSON (fromJson)', () {
      final authResponse = AuthResponse.fromJson(testJson);

      expect(authResponse.user.id, 1);
      expect(authResponse.user.email, 'test@example.com');
      expect(authResponse.user.username, 'testuser');
      expect(authResponse.user.role, 'USER');
      expect(authResponse.token, testToken);
    });

    test('should convert AuthResponse to JSON (toJson)', () {
      final authResponse = AuthResponse(user: testUser, token: testToken);

      final json = authResponse.toJson();

      expect(json['user'], isA<Map<String, dynamic>>());
      expect(json['user']['id'], 1);
      expect(json['user']['email'], 'test@example.com');
      expect(json['token'], testToken);
    });

    test('should handle fromJson -> toJson roundtrip', () {
      final authResponse = AuthResponse.fromJson(testJson);
      final json = authResponse.toJson();

      final userJson = json['user'] as Map<String, dynamic>;
      final testUserJson = testJson['user'] as Map<String, dynamic>;

      expect(userJson['id'], testUserJson['id']);
      expect(userJson['email'], testUserJson['email']);
      expect(json['token'], testJson['token']);
    });

    test('should handle nested User object correctly', () {
      final authResponse = AuthResponse.fromJson(testJson);

      expect(authResponse.user, isA<User>());
      expect(authResponse.user.email, 'test@example.com');
    });

    test('should handle long JWT token', () {
      final longToken =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
          'eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.'
          'SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

      final jsonWithLongToken = Map<String, dynamic>.from(testJson);
      jsonWithLongToken['token'] = longToken;

      final authResponse = AuthResponse.fromJson(jsonWithLongToken);
      expect(authResponse.token, longToken);
    });
  });
}
