import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/auth_result_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResultModel> login({
    required String account,
    required String password,
  });

  Future<AuthResultModel> register({
    required String account,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> getProfile();

  Future<UserModel> updateProfile({String? name, String? profileImage});

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<AuthResultModel> refreshToken({
    required String refreshToken,
    String? sessionId,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<AuthResultModel> login({
    required String account,
    required String password,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.login,
        data: {'account': account, 'password': password},
      );

      if (response.data['success'] == true) {
        return AuthResultModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: response.data['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResultModel> register({
    required String account,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.register,
        data: {'account': account, 'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        return AuthResultModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: response.data['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.dio.post(ApiEndpoints.logout);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await dioClient.dio.get(ApiEndpoints.profile);

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: response.data['message'] ?? 'Failed to get profile',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> updateProfile({String? name, String? profileImage}) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (profileImage != null) data['profileImage'] = profileImage;

      final response = await dioClient.dio.patch(
        ApiEndpoints.updateProfile,
        data: data,
      );

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: response.data['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await dioClient.dio.post(
        ApiEndpoints.changePassword,
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await dioClient.dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await dioClient.dio.post(
        ApiEndpoints.resetPassword,
        data: {'token': token, 'newPassword': newPassword},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResultModel> refreshToken({
    required String refreshToken,
    String? sessionId,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.refreshToken,
        data: {
          'refreshToken': refreshToken,
          if (sessionId != null) 'sessionId': sessionId,
        },
      );

      if (response.data['success'] == true) {
        return AuthResultModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: response.data['message'] ?? 'Failed to refresh token',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
