import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:kanji_mobile_v1/core/constants/app_constants.dart';
import 'package:kanji_mobile_v1/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:kanji_mobile_v1/features/auth/data/models/user_model.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    dataSource = AuthLocalDataSourceImpl(mockSecureStorage);
  });

  group('AuthLocalDataSource', () {
    const testAccessToken = 'test_access_token_123';
    const testRefreshToken = 'test_refresh_token_456';
    const testSessionId = 'session_789';

    final testUserModel = UserModel(
      id: 1,
      account: 'testuser',
      email: 'test@example.com',
      profileImage: null,
      isFirstLogin: false,
      createdAt: DateTime(2024, 1, 1),
      role: 'USER',
    );

    group('cacheAuthTokens', () {
      test(
        'should cache access token, refresh token, and session ID',
        () async {
          // arrange
          when(
            () => mockSecureStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            ),
          ).thenAnswer((_) async => {});

          // act
          await dataSource.cacheAuthTokens(
            accessToken: testAccessToken,
            refreshToken: testRefreshToken,
            sessionId: testSessionId,
          );

          // assert
          verify(
            () => mockSecureStorage.write(
              key: AppConstants.keyAccessToken,
              value: testAccessToken,
            ),
          ).called(1);
          verify(
            () => mockSecureStorage.write(
              key: AppConstants.keyRefreshToken,
              value: testRefreshToken,
            ),
          ).called(1);
          verify(
            () => mockSecureStorage.write(
              key: 'session_id',
              value: testSessionId,
            ),
          ).called(1);
        },
      );

      test(
        'should cache only access token when refresh token is null',
        () async {
          // arrange
          when(
            () => mockSecureStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            ),
          ).thenAnswer((_) async => {});

          // act
          await dataSource.cacheAuthTokens(
            accessToken: testAccessToken,
            refreshToken: null,
            sessionId: null,
          );

          // assert
          verify(
            () => mockSecureStorage.write(
              key: AppConstants.keyAccessToken,
              value: testAccessToken,
            ),
          ).called(1);
          verifyNever(
            () => mockSecureStorage.write(
              key: AppConstants.keyRefreshToken,
              value: any(named: 'value'),
            ),
          );
          verifyNever(
            () => mockSecureStorage.write(
              key: 'session_id',
              value: any(named: 'value'),
            ),
          );
        },
      );
    });

    group('getAccessToken', () {
      test('should return access token from secure storage', () async {
        // arrange
        when(
          () => mockSecureStorage.read(key: AppConstants.keyAccessToken),
        ).thenAnswer((_) async => testAccessToken);

        // act
        final result = await dataSource.getAccessToken();

        // assert
        expect(result, equals(testAccessToken));
        verify(
          () => mockSecureStorage.read(key: AppConstants.keyAccessToken),
        ).called(1);
      });

      test('should return null when no access token exists', () async {
        // arrange
        when(
          () => mockSecureStorage.read(key: AppConstants.keyAccessToken),
        ).thenAnswer((_) async => null);

        // act
        final result = await dataSource.getAccessToken();

        // assert
        expect(result, isNull);
        verify(
          () => mockSecureStorage.read(key: AppConstants.keyAccessToken),
        ).called(1);
      });
    });

    group('getRefreshToken', () {
      test('should return refresh token from secure storage', () async {
        // arrange
        when(
          () => mockSecureStorage.read(key: AppConstants.keyRefreshToken),
        ).thenAnswer((_) async => testRefreshToken);

        // act
        final result = await dataSource.getRefreshToken();

        // assert
        expect(result, equals(testRefreshToken));
        verify(
          () => mockSecureStorage.read(key: AppConstants.keyRefreshToken),
        ).called(1);
      });

      test('should return null when no refresh token exists', () async {
        // arrange
        when(
          () => mockSecureStorage.read(key: AppConstants.keyRefreshToken),
        ).thenAnswer((_) async => null);

        // act
        final result = await dataSource.getRefreshToken();

        // assert
        expect(result, isNull);
      });
    });

    group('getSessionId', () {
      test('should return session ID from secure storage', () async {
        // arrange
        when(
          () => mockSecureStorage.read(key: 'session_id'),
        ).thenAnswer((_) async => testSessionId);

        // act
        final result = await dataSource.getSessionId();

        // assert
        expect(result, equals(testSessionId));
        verify(() => mockSecureStorage.read(key: 'session_id')).called(1);
      });

      test('should return null when no session ID exists', () async {
        // arrange
        when(
          () => mockSecureStorage.read(key: 'session_id'),
        ).thenAnswer((_) async => null);

        // act
        final result = await dataSource.getSessionId();

        // assert
        expect(result, isNull);
      });
    });

    group('cacheUser', () {
      test('should cache user data in secure storage', () async {
        // arrange
        when(
          () => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async => {});

        // act
        await dataSource.cacheUser(testUserModel);

        // assert
        verify(
          () => mockSecureStorage.write(
            key: 'cached_user',
            value: any(named: 'value'),
          ),
        ).called(1);
        verify(
          () =>
              mockSecureStorage.write(key: AppConstants.keyUserId, value: '1'),
        ).called(1);
        verify(
          () => mockSecureStorage.write(
            key: AppConstants.keyUserRole,
            value: 'USER',
          ),
        ).called(1);
      });
    });

    group('getCachedUser', () {
      test('should return cached user from secure storage', () async {
        // arrange
        final userJson =
            '{"id":1,"account":"testuser","email":"test@example.com","profile_image":null,"is_first_login":false,"create_at":"2024-01-01T00:00:00.000","role":"USER"}';
        when(
          () => mockSecureStorage.read(key: 'cached_user'),
        ).thenAnswer((_) async => userJson);

        // act
        final result = await dataSource.getCachedUser();

        // assert
        expect(result, isNotNull);
        expect(result?.id, equals(1));
        expect(result?.account, equals('testuser'));
        expect(result?.email, equals('test@example.com'));
        expect(result?.role, equals('USER'));
        verify(() => mockSecureStorage.read(key: 'cached_user')).called(1);
      });

      test('should return null when no cached user exists', () async {
        // arrange
        when(
          () => mockSecureStorage.read(key: 'cached_user'),
        ).thenAnswer((_) async => null);

        // act
        final result = await dataSource.getCachedUser();

        // assert
        expect(result, isNull);
        verify(() => mockSecureStorage.read(key: 'cached_user')).called(1);
      });
    });

    group('clearAuthData', () {
      test('should clear all auth-related data from secure storage', () async {
        // arrange
        when(
          () => mockSecureStorage.delete(key: any(named: 'key')),
        ).thenAnswer((_) async => {});

        // act
        await dataSource.clearAuthData();

        // assert
        verify(
          () => mockSecureStorage.delete(key: AppConstants.keyAccessToken),
        ).called(1);
        verify(
          () => mockSecureStorage.delete(key: AppConstants.keyRefreshToken),
        ).called(1);
        verify(() => mockSecureStorage.delete(key: 'session_id')).called(1);
        verify(() => mockSecureStorage.delete(key: 'cached_user')).called(1);
        verify(
          () => mockSecureStorage.delete(key: AppConstants.keyUserId),
        ).called(1);
        verify(
          () => mockSecureStorage.delete(key: AppConstants.keyUserRole),
        ).called(1);
      });

      test(
        'should handle clear auth data even if some keys do not exist',
        () async {
          // arrange
          when(
            () => mockSecureStorage.delete(key: any(named: 'key')),
          ).thenAnswer((_) async => {});

          // act
          await dataSource.clearAuthData();

          // assert - should still call delete for all keys
          verify(
            () => mockSecureStorage.delete(key: any(named: 'key')),
          ).called(6);
        },
      );
    });
  });
}
