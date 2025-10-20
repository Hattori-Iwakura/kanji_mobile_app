import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Module Integration Tests', () {
    late IntegrationTestHelper helper;

    setUp(() {
      helper = IntegrationTestHelper();
    });

    tearDown(() async {
      await helper.cleanup();
    });

    test('Backend health check', () async {
      final isRunning = await helper.isBackendRunning();
      expect(isRunning, true, reason: 'Backend server should be running');
      print('✅ Backend server is running');
    });

    test('Register new user - Success', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final email = 'testuser_$timestamp@example.com';
      final account = 'testuser$timestamp';

      final response = await helper.apiClient.post('/auth/register', {
        'account': account, // Added account field
        'email': email,
        'password': 'Test@123456',
      });

      expect(response.statusCode, 201);
      expect(response.data, isNotNull);

      // Backend wraps response in {statusCode, data, timestamp}
      final data = response.data['data'] ?? response.data;
      expect(data['accessToken'], isNotNull);
      expect(data['user'], isNotNull);
      expect(data['user']['email'], equals(email));

      print('✅ User registered successfully');
      print('   Email: $email');
      print('   Token received: ${data['accessToken'] != null}');
    });

    test('Register - Fail with duplicate email', () async {
      final email = IntegrationTestHelper.testEmail;

      try {
        await helper.apiClient.post('/auth/register', {
          'account': 'testuser', // Added account field
          'email': email,
          'password': 'Test@123456',
        });
        fail('Should throw exception for duplicate email');
      } catch (e) {
        // Backend returns 409 for duplicate, but wrapped as 400 sometimes
        expect(e.toString(), anyOf(contains('409'), contains('400')));
        print('✅ Correctly rejected duplicate email');
      }
    });

    test('Register - Fail with invalid email format', () async {
      try {
        await helper.apiClient.post('/auth/register', {
          'account': 'testuser', // Added account field
          'email': 'invalid-email',
          'password': 'Test@123456',
        });
        fail('Should throw exception for invalid email');
      } catch (e) {
        expect(e.toString(), contains('400'));
        print('✅ Correctly rejected invalid email format');
      }
    });

    test('Register - Fail with weak password', () async {
      try {
        await helper.apiClient.post('/auth/register', {
          'account': 'newuser', // Added account field
          'email': 'newuser@example.com',
          'password': '123', // Too short
        });
        fail('Should throw exception for weak password');
      } catch (e) {
        expect(e.toString(), contains('400'));
        print('✅ Correctly rejected weak password');
      }
    });

    test('Login - Success with valid credentials', () async {
      final response = await helper.apiClient.post('/auth/login', {
        'account': IntegrationTestHelper
            .testEmail, // Changed from 'email' to 'account'
        'password': IntegrationTestHelper.testPassword,
      });

      // Backend returns 200 for login
      expect(response.statusCode, anyOf(200, 201));
      expect(response.data, isNotNull);

      // Backend wraps response in {statusCode, data, timestamp}
      final data = response.data['data'] ?? response.data;
      expect(data['accessToken'], isNotNull);
      expect(data['user'], isNotNull);
      expect(data['user']['email'], equals(IntegrationTestHelper.testEmail));

      // Verify token is a valid JWT (has 3 parts separated by dots)
      final token = data['accessToken'] as String;
      expect(token.split('.').length, equals(3));

      print('✅ Login successful');
      print('   Token format valid: ${token.split('.').length == 3}');
    });

    test('Login - Fail with wrong password', () async {
      try {
        await helper.apiClient.post('/auth/login', {
          'account': IntegrationTestHelper
              .testEmail, // Changed from 'email' to 'account'
          'password': 'WrongPassword123',
        });
        fail('Should throw exception for wrong password');
      } catch (e) {
        expect(e.toString(), contains('401'));
        print('✅ Correctly rejected wrong password');
      }
    });

    test('Login - Fail with non-existent email', () async {
      try {
        await helper.apiClient.post('/auth/login', {
          'account':
              'nonexistent@example.com', // Changed from 'email' to 'account'
          'password': 'Test@123456',
        });
        fail('Should throw exception for non-existent user');
      } catch (e) {
        expect(e.toString(), contains('401'));
        print('✅ Correctly rejected non-existent user');
      }
    });

    test('Get profile - Success with valid token', () async {
      // Login first
      await helper.loginAndGetToken();

      final response = await helper.apiClient.get('/auth/profile');

      expect(response.statusCode, 200);
      expect(response.data, isNotNull);

      // Backend wraps response in {statusCode, data, timestamp}
      final data = response.data['data'] ?? response.data;
      expect(data['id'], isNotNull);
      expect(data['email'], equals(IntegrationTestHelper.testEmail));
      expect(data['name'], isNotNull);

      print('✅ Profile retrieved successfully');
      print('   User ID: ${data['id']}');
      print('   Email: ${data['email']}');
      print('   Name: ${data['name']}');
    });

    test('Get profile - Fail without token', () async {
      try {
        await helper.apiClient.get('/auth/profile');
        fail('Should throw exception without auth token');
      } catch (e) {
        expect(e.toString(), contains('401'));
        print('✅ Correctly rejected unauthorized profile access');
      }
    });

    test('Get profile - Fail with invalid token', () async {
      helper.apiClient.setAuthToken('invalid.jwt.token');

      try {
        await helper.apiClient.get('/auth/profile');
        fail('Should throw exception with invalid token');
      } catch (e) {
        expect(e.toString(), contains('401'));
        print('✅ Correctly rejected invalid token');
      }
    });

    test('Token persistence across requests', () async {
      // Login
      await helper.loginAndGetToken();

      // Make multiple authenticated requests
      for (int i = 0; i < 3; i++) {
        final response = await helper.apiClient.get('/auth/profile');
        expect(response.statusCode, 200);
      }

      print('✅ Token persisted correctly across multiple requests');
    });

    test('Update profile - Success', () async {
      await helper.loginAndGetToken();

      final newName = 'Updated Name ${DateTime.now().millisecondsSinceEpoch}';

      final response = await helper.apiClient.patch('/auth/profile', {
        'name': newName,
      });

      expect(response.statusCode, 200);

      // Backend wraps response in {statusCode, data, timestamp}
      final data = response.data['data'] ?? response.data;
      expect(data['name'], equals(newName));

      // Verify update persisted
      final profileResponse = await helper.apiClient.get('/auth/profile');
      final profileData = profileResponse.data['data'] ?? profileResponse.data;
      expect(profileData['name'], equals(newName));

      print('✅ Profile updated successfully');
      print('   New name: $newName');
    });
  });
}
