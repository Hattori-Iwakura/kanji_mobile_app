import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoint.dart';
import '../../domain/entities/auth_exception.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String username,
    required String password,
  });
  Future<UserModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.login, {
        'account': email, // Backend expects 'account' field, not 'email'
        'password': password,
      });

      // Backend wraps response: { statusCode, data: { user, accessToken }, timestamp }
      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Login failed';
      throw AuthException(message);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.register, {
        'email': email,
        'username': username,
        'password': password,
      });

      // Backend wraps response: { statusCode, data: { user, accessToken }, timestamp }
      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Registration failed';
      throw AuthException(message);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);

      // Backend wraps response: { statusCode, data: user, timestamp }
      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to get profile';
      throw AuthException(message);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }
}
