import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../models/two_factor_setup_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    String? twoFactorCode,
  });
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
  );
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({String? name, String? profileImage});
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<void> changePassword(String currentPassword, String newPassword);

  // 2FA methods
  Future<TwoFactorSetupModel> setup2FA();
  Future<UserModel> enable2FA(String code);
  Future<UserModel> disable2FA(String password, String code);
  Future<void> sendEmailOTP();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  /// Helper method to extract error message from Dio response
  String _extractErrorMessage(dynamic responseData, String defaultMessage) {
    if (responseData == null) return defaultMessage;

    if (responseData is Map<String, dynamic>) {
      // Try 'message' field first (for validation errors)
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      } else if (message is List && message.isNotEmpty) {
        return message.join(', ');
      }

      // Fall back to 'error' field (for application errors)
      final error = responseData['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }

      return defaultMessage;
    } else if (responseData is String) {
      return responseData;
    }

    return defaultMessage;
  }

  @override
  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    String? twoFactorCode,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'account': email,
        'password': password,
      };
      if (twoFactorCode != null) {
        data['code'] = twoFactorCode;
      }

      final response = await apiClient.dio.post('/auth/login', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('=== LOGIN RESPONSE ===');
        print('Status: ${response.statusCode}');
        print('Data: ${response.data}');
        print('======================');
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException('Login failed');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.response?.statusCode == 401) {
        final errorMessage = _extractErrorMessage(
          e.response?.data,
          'Invalid credentials',
        );
        throw UnauthorizedException(errorMessage);
      } else {
        final errorMessage = _extractErrorMessage(
          e.response?.data,
          'Server error',
        );
        throw ServerException(errorMessage);
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/register',
        data: {'email': email, 'password': password, 'name': name},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException('Registration failed');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else {
        final errorMessage = _extractErrorMessage(
          e.response?.data,
          'Server error',
        );
        throw ServerException(errorMessage);
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.dio.get('/auth/profile');

      if (response.statusCode == 200) {
        return UserModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException('Failed to get profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      } else {
        final errorMessage = _extractErrorMessage(
          e.response?.data,
          'Server error',
        );
        throw ServerException(errorMessage);
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<UserModel> updateProfile({String? name, String? profileImage}) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (profileImage != null) data['profileImage'] = profileImage;

      final response = await apiClient.dio.patch('/auth/profile', data: data);

      if (response.statusCode == 200) {
        return UserModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException('Failed to update profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      } else {
        final errorMessage = _extractErrorMessage(
          e.response?.data,
          'Server error',
        );
        throw ServerException(errorMessage);
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Failed to send reset link');
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(
        e.response?.data,
        'Failed to send reset link',
      );
      throw ServerException(errorMessage);
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/reset-password',
        data: {'token': token, 'newPassword': newPassword},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Failed to reset password');
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(
        e.response?.data,
        'Failed to reset password',
      );
      throw ServerException(errorMessage);
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Failed to change password');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      }
      final errorMessage = _extractErrorMessage(
        e.response?.data,
        'Failed to change password',
      );
      throw ServerException(errorMessage);
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<TwoFactorSetupModel> setup2FA() async {
    try {
      final response = await apiClient.dio.post('/auth/2fa/setup');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TwoFactorSetupModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException('Failed to setup 2FA');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      } else {
        final errorMessage = _extractErrorMessage(
          e.response?.data,
          'Server error',
        );
        throw ServerException(errorMessage);
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<UserModel> enable2FA(String code) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/2fa/enable',
        data: {'code': code},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException('Failed to enable 2FA');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      } else {
        final errorMessage = _extractErrorMessage(
          e.response?.data,
          'Invalid code or server error',
        );
        throw ServerException(errorMessage);
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<UserModel> disable2FA(String password, String code) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/2fa/disable',
        data: {'password': password, 'code': code},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException('Failed to disable 2FA');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Invalid credentials');
      } else {
        final errorMessage = _extractErrorMessage(
          e.response?.data,
          'Invalid code or server error',
        );
        throw ServerException(errorMessage);
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> sendEmailOTP() async {
    try {
      final response = await apiClient.dio.post('/auth/2fa/send-email-otp');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Failed to send OTP');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      } else {
        final errorMessage = _extractErrorMessage(
          e.response?.data,
          'Failed to send OTP',
        );
        throw ServerException(errorMessage);
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
