import '../../../../core/network/api_client.dart';
import '../../domain/entities/auth_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.apiClient,
  });

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {'account': email, 'password': password},
      );

      final data = response.data['data'] ?? response.data;
      final token = data['accessToken'] as String;

      // Save token to local storage
      await localDataSource.saveToken(token);

      // Set token in API client for future requests
      apiClient.setAuthToken(token);

      // Get user from remote data source
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      return userModel.toEntity();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Login failed: $e');
    }
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        data: {'email': email, 'username': username, 'password': password},
      );

      final data = response.data['data'] ?? response.data;
      final token = data['accessToken'] as String;

      // Save token to local storage
      await localDataSource.saveToken(token);

      // Set token in API client
      apiClient.setAuthToken(token);

      // Get user from remote data source
      final userModel = await remoteDataSource.register(
        email: email,
        username: username,
        password: password,
      );

      return userModel.toEntity();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Registration failed: $e');
    }
  }

  @override
  Future<UserEntity> getProfile() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) {
        throw AuthException('No authentication token found');
      }

      final userModel = await remoteDataSource.getProfile();
      return userModel.toEntity();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Failed to get profile: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await localDataSource.deleteToken();
      apiClient.clearAuthToken();
    } catch (e) {
      throw AuthException('Logout failed: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.hasValidToken();
  }

  @override
  Future<void> initAuth() async {
    final token = await localDataSource.getToken();
    if (token != null && await localDataSource.hasValidToken()) {
      apiClient.setAuthToken(token);
    }
  }
}
