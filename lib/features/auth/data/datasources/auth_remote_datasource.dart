import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoint.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String account, String password);
  Future<AuthResponseModel> refreshToken(String sessionId, String refreshToken);
  Future<void> logout(String sessionId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> login(String account, String password) async {
    try {
      final response = await apiClient.post(ApiEndpoints.login, {
        'account': account,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;

        // Check if response is wrapped in a data field
        final data = responseData.containsKey('data')
            ? responseData['data'] as Map<String, dynamic>
            : responseData;

        return AuthResponseModel.fromJson(data);
      } else {
        throw ServerException(
          'Login failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          e.response?.data['message'] ?? 'Invalid credentials',
        );
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(
    String sessionId,
    String refreshToken,
  ) async {
    try {
      final response = await apiClient.post(ApiEndpoints.refreshMobile, {
        'sessionId': sessionId,
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Check if response is wrapped in a data field
        final data = responseData.containsKey('data')
            ? responseData['data'] as Map<String, dynamic>
            : responseData;

        return AuthResponseModel.fromJson(data);
      } else {
        throw ServerException(
          'Refresh failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    }
  }

  @override
  Future<void> logout(String sessionId) async {
    try {
      await apiClient.post(ApiEndpoints.logout, {'sessionId': sessionId});
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Logout failed');
    }
  }
}
