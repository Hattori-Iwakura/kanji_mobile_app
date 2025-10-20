import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kanji_flutter/features/auth/services/auth_storage.dart';

// Generate mocks
@GenerateMocks([FlutterSecureStorage])
import 'auth_storage_test.mocks.dart';

void main() {
  late AuthStorage authStorage;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    authStorage = AuthStorage(mockSecureStorage);
  });

  group('AuthStorage Tests', () {
    const testToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
        'eyJzdWIiOjEsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsImlhdCI6MTYwMDAwMDAwMCwiZXhwIjo5OTk5OTk5OTk5fQ.'
        'test-signature';

    const expiredToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
        'eyJzdWIiOjEsImVtYWlsIjoidGVzdEBleGFtcGxlLmNvbSIsImlhdCI6MTYwMDAwMDAwMCwiZXhwIjoxNjAwMDAwMDAwfQ.'
        'test-signature';

    group('saveToken', () {
      test('should save token to secure storage', () async {
        when(
          mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async => Future.value());

        await authStorage.saveToken(testToken);

        verify(
          mockSecureStorage.write(key: 'auth_token', value: testToken),
        ).called(1);
      });

      test('should handle save errors gracefully', () async {
        when(
          mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenThrow(Exception('Storage error'));

        expect(() => authStorage.saveToken(testToken), throwsException);
      });
    });

    group('getToken', () {
      test('should retrieve token from secure storage', () async {
        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => testToken);

        final token = await authStorage.getToken();

        expect(token, testToken);
        verify(mockSecureStorage.read(key: 'auth_token')).called(1);
      });

      test('should return null when no token exists', () async {
        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => null);

        final token = await authStorage.getToken();

        expect(token, null);
      });

      test('should handle read errors', () async {
        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenThrow(Exception('Read error'));

        expect(() => authStorage.getToken(), throwsException);
      });
    });

    group('deleteToken', () {
      test('should delete token from secure storage', () async {
        when(
          mockSecureStorage.delete(key: anyNamed('key')),
        ).thenAnswer((_) async => Future.value());

        await authStorage.deleteToken();

        verify(mockSecureStorage.delete(key: 'auth_token')).called(1);
      });

      test('should handle delete errors gracefully', () async {
        when(
          mockSecureStorage.delete(key: anyNamed('key')),
        ).thenThrow(Exception('Delete error'));

        expect(() => authStorage.deleteToken(), throwsException);
      });
    });

    group('hasValidToken', () {
      test('should return true for valid non-expired token', () async {
        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => testToken);

        final isValid = await authStorage.hasValidToken();

        expect(isValid, true);
      });

      test('should return false when no token exists', () async {
        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => null);

        final isValid = await authStorage.hasValidToken();

        expect(isValid, false);
      });

      test('should return false for expired token', () async {
        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => expiredToken);

        final isValid = await authStorage.hasValidToken();

        expect(isValid, false);
      });

      test('should return false for invalid token format', () async {
        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => 'invalid-token');

        final isValid = await authStorage.hasValidToken();

        expect(isValid, false);
      });

      test('should return false on storage read error', () async {
        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenThrow(Exception('Read error'));

        // Expect exception to be thrown (not caught)
        expect(() => authStorage.hasValidToken(), throwsException);
      });
    });

    group('getUserIdFromToken', () {
      test('should decode and return user ID from valid token', () async {
        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => testToken);

        final userId = await authStorage.getUserIdFromToken();

        expect(userId, 1);
      });

      test('should return null when no token exists', () async {
        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => null);

        final userId = await authStorage.getUserIdFromToken();

        expect(userId, null);
      });

      test('should return null for invalid token format', () async {
        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => 'invalid-token');

        final userId = await authStorage.getUserIdFromToken();

        expect(userId, null);
      });

      test('should return null for token without sub claim', () async {
        const tokenWithoutSub =
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
            'eyJlbWFpbCI6InRlc3RAZXhhbXBsZS5jb20iLCJpYXQiOjE2MDAwMDAwMDAsImV4cCI6OTk5OTk5OTk5OX0.'
            'test-signature';

        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => tokenWithoutSub);

        final userId = await authStorage.getUserIdFromToken();

        expect(userId, null);
      });

      test('should handle storage read errors', () async {
        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenThrow(Exception('Read error'));

        // Expect exception to be thrown (not caught)
        expect(() => authStorage.getUserIdFromToken(), throwsException);
      });
    });

    group('Integration Tests', () {
      test('should complete save-get-delete cycle', () async {
        when(
          mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async => Future.value());

        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => testToken);

        when(
          mockSecureStorage.delete(key: anyNamed('key')),
        ).thenAnswer((_) async => Future.value());

        // Save
        await authStorage.saveToken(testToken);
        verify(mockSecureStorage.write(key: 'auth_token', value: testToken));

        // Get
        final token = await authStorage.getToken();
        expect(token, testToken);

        // Delete
        await authStorage.deleteToken();
        verify(mockSecureStorage.delete(key: 'auth_token'));
      });

      test('should validate token after saving', () async {
        when(
          mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async => Future.value());

        when(
          mockSecureStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => testToken);

        await authStorage.saveToken(testToken);
        final isValid = await authStorage.hasValidToken();

        expect(isValid, true);
      });
    });
  });
}
