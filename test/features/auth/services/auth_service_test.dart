import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:kanji_flutter/features/auth/services/auth_service.dart';
import 'package:kanji_flutter/features/auth/services/auth_storage.dart';
import 'package:kanji_flutter/features/auth/models/user.dart';
import 'package:kanji_flutter/features/auth/models/auth_exception.dart';
import 'package:kanji_flutter/core/network/api_client.dart';

// Generate mocks
@GenerateMocks([ApiClient, AuthStorage])
import 'auth_service_test.mocks.dart';

void main() {
  late AuthService authService;
  late MockApiClient mockApiClient;
  late MockAuthStorage mockAuthStorage;

  setUp(() {
    mockApiClient = MockApiClient();
    mockAuthStorage = MockAuthStorage();
    authService = AuthService(
      apiClient: mockApiClient,
      storage: mockAuthStorage,
    );
  });

  group('AuthService Tests', () {
    final testUser = User(
      id: 1,
      email: 'test@example.com',
      username: 'testuser',
      avatarUrl: null,
      role: 'USER',
      createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
    );

    const testToken = 'test-jwt-token';

    final successResponse = Response(
      requestOptions: RequestOptions(path: '/api/auth/login'),
      statusCode: 200,
      data: {
        'user': {
          'id': 1,
          'email': 'test@example.com',
          'username': 'testuser',
          'avatarUrl': null,
          'role': 'USER',
          'createdAt': '2025-01-01T00:00:00.000Z',
        },
        'token': testToken,
      },
    );

    group('login', () {
      test('should login successfully and return user', () async {
        when(
          mockApiClient.post(any, any),
        ).thenAnswer((_) async => successResponse);

        when(
          mockAuthStorage.saveToken(any),
        ).thenAnswer((_) async => Future.value());

        when(mockApiClient.setAuthToken(any)).thenReturn(null);

        final user = await authService.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(user.id, testUser.id);
        expect(user.email, testUser.email);
        expect(user.username, testUser.username);

        verify(
          mockApiClient.post(any, {
            'email': 'test@example.com',
            'password': 'password123',
          }),
        ).called(1);

        verify(mockAuthStorage.saveToken(testToken)).called(1);
        verify(mockApiClient.setAuthToken(testToken)).called(1);
      });

      test('should throw AuthException on invalid credentials', () async {
        when(mockApiClient.post(any, any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/auth/login'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/auth/login'),
              statusCode: 401,
              data: {'message': 'Invalid credentials'},
            ),
          ),
        );

        expect(
          () => authService.login(
            email: 'test@example.com',
            password: 'wrong-password',
          ),
          throwsA(isA<AuthException>()),
        );
      });

      test(
        'should throw AuthException with custom message from backend',
        () async {
          const errorMessage = 'User not found';

          when(mockApiClient.post(any, any)).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/api/auth/login'),
              response: Response(
                requestOptions: RequestOptions(path: '/api/auth/login'),
                statusCode: 404,
                data: {'message': errorMessage},
              ),
            ),
          );

          try {
            await authService.login(
              email: 'test@example.com',
              password: 'password',
            );
            fail('Should have thrown AuthException');
          } catch (e) {
            expect(e, isA<AuthException>());
            expect((e as AuthException).message, errorMessage);
          }
        },
      );

      test('should throw AuthException on network error', () async {
        when(mockApiClient.post(any, any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/auth/login'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        expect(
          () => authService.login(
            email: 'test@example.com',
            password: 'password',
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('register', () {
      test('should register successfully and return user', () async {
        when(
          mockApiClient.post(any, any),
        ).thenAnswer((_) async => successResponse);

        when(
          mockAuthStorage.saveToken(any),
        ).thenAnswer((_) async => Future.value());

        when(mockApiClient.setAuthToken(any)).thenReturn(null);

        final user = await authService.register(
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
        );

        expect(user.id, testUser.id);
        expect(user.email, testUser.email);
        expect(user.username, testUser.username);

        verify(
          mockApiClient.post(any, {
            'email': 'test@example.com',
            'username': 'testuser',
            'password': 'password123',
          }),
        ).called(1);

        verify(mockAuthStorage.saveToken(testToken)).called(1);
        verify(mockApiClient.setAuthToken(testToken)).called(1);
      });

      test('should throw AuthException when email already exists', () async {
        when(mockApiClient.post(any, any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/auth/register'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/auth/register'),
              statusCode: 409,
              data: {'message': 'Email already exists'},
            ),
          ),
        );

        expect(
          () => authService.register(
            email: 'test@example.com',
            username: 'user',
            password: 'pass',
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('getProfile', () {
      test('should fetch user profile successfully', () async {
        when(mockAuthStorage.getToken()).thenAnswer((_) async => testToken);
        when(mockApiClient.get(any)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/api/auth/profile'),
            statusCode: 200,
            data: {
              'id': 1,
              'email': 'test@example.com',
              'username': 'testuser',
              'avatarUrl': null,
              'role': 'USER',
              'createdAt': '2025-01-01T00:00:00.000Z',
            },
          ),
        );

        final user = await authService.getProfile();

        expect(user.id, testUser.id);
        expect(user.email, testUser.email);

        verify(mockApiClient.get(any)).called(1);
      });

      test('should throw AuthException when unauthorized', () async {
        when(mockApiClient.get(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/auth/profile'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/auth/profile'),
              statusCode: 401,
              data: {'message': 'Unauthorized'},
            ),
          ),
        );

        expect(() => authService.getProfile(), throwsA(isA<AuthException>()));
      });
    });

    group('logout', () {
      test('should logout successfully and clear token', () async {
        when(
          mockAuthStorage.deleteToken(),
        ).thenAnswer((_) async => Future.value());

        when(mockApiClient.clearAuthToken()).thenReturn(null);

        await authService.logout();

        verify(mockAuthStorage.deleteToken()).called(1);
        verify(mockApiClient.clearAuthToken()).called(1);
      });

      test('should handle storage errors during logout', () async {
        when(
          mockAuthStorage.deleteToken(),
        ).thenThrow(Exception('Storage error'));

        expect(() => authService.logout(), throwsException);
      });
    });

    group('isLoggedIn', () {
      test('should return true when valid token exists', () async {
        when(mockAuthStorage.hasValidToken()).thenAnswer((_) async => true);

        final isLoggedIn = await authService.isLoggedIn();

        expect(isLoggedIn, true);
        verify(mockAuthStorage.hasValidToken()).called(1);
      });

      test('should return false when no valid token exists', () async {
        when(mockAuthStorage.hasValidToken()).thenAnswer((_) async => false);

        final isLoggedIn = await authService.isLoggedIn();

        expect(isLoggedIn, false);
      });
    });

    group('initAuth', () {
      test('should initialize auth by restoring token', () async {
        when(mockAuthStorage.getToken()).thenAnswer((_) async => testToken);
        when(mockAuthStorage.hasValidToken()).thenAnswer((_) async => true);
        when(mockApiClient.setAuthToken(any)).thenReturn(null);

        await authService.initAuth();

        verify(mockAuthStorage.getToken()).called(1);
        verify(mockApiClient.setAuthToken(testToken)).called(1);
      });

      test('should handle no token gracefully', () async {
        when(mockAuthStorage.getToken()).thenAnswer((_) async => null);

        await authService.initAuth();

        verify(mockAuthStorage.getToken()).called(1);
        verifyNever(mockApiClient.setAuthToken(any));
      });
    });

    group('Integration Tests', () {
      test('should complete login -> logout flow', () async {
        // Login
        when(
          mockApiClient.post(any, any),
        ).thenAnswer((_) async => successResponse);
        when(
          mockAuthStorage.saveToken(any),
        ).thenAnswer((_) async => Future.value());
        when(mockApiClient.setAuthToken(any)).thenReturn(null);

        await authService.login(
          email: 'test@example.com',
          password: 'password',
        );

        verify(mockAuthStorage.saveToken(testToken));
        verify(mockApiClient.setAuthToken(testToken));

        // Logout
        when(
          mockAuthStorage.deleteToken(),
        ).thenAnswer((_) async => Future.value());
        when(mockApiClient.clearAuthToken()).thenReturn(null);

        await authService.logout();

        verify(mockAuthStorage.deleteToken());
        verify(mockApiClient.clearAuthToken());
      });
    });
  });
}
