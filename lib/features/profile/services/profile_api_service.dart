import 'package:kanji_mobile_app/features/profile/models/profile_models.dart';
import 'package:kanji_mobile_app/features/profile/models/two_factor_models.dart';
import 'package:kanji_mobile_app/core/network/api_client.dart';
import 'package:dio/dio.dart';

class ProfileApiService {
  final ApiClient _apiClient;

  ProfileApiService(this._apiClient);

  // Get current user profile
  Future<UserProfile> getProfile() async {
    try {
      final response = await _apiClient.dio.get('/auth/profile');

      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'] ?? response.data;
        return UserProfile.fromJson(data);
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      }
      throw Exception('Failed to load profile: ${e.message}');
    }
  }

  // Update profile
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _apiClient.dio.patch(
        '/auth/profile',
        data: request.toJson(),
      );

      final data = response.data['data'] ?? response.data;
      return UserProfile.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      }
      if (e.response?.statusCode == 409) {
        throw Exception('Email already exists');
      }
      throw Exception('Failed to update profile: ${e.message}');
    }
  }

  // Get profile with stats from progress endpoint
  Future<UserProfile> getProfileWithStats() async {
    try {
      final profileFuture = getProfile();
      final statsFuture = _getProfileStats();

      final results = await Future.wait([profileFuture, statsFuture]);
      final profile = results[0] as UserProfile;
      final stats = results[1] as ProfileStats?;

      return profile.copyWith(stats: stats);
    } catch (e) {
      throw Exception('Failed to load profile with stats: $e');
    }
  }

  // Get profile statistics from progress endpoint
  Future<ProfileStats?> _getProfileStats() async {
    try {
      final response = await _apiClient.dio.get('/progress/overview');

      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'] ?? response.data;

        // Convert progress data to ProfileStats format
        return ProfileStats(
          totalKanjiStudied: data['totalKanjiStudied'] as int? ?? 0,
          quizzesCompleted: data['quizzesCompleted'] as int? ?? 0,
          flashcardsReviewed: data['flashcardsReviewed'] as int? ?? 0,
          currentStreak: data['currentStreak'] as int? ?? 0,
          totalXp: data['xp'] as int? ?? 0,
          averageScore: (data['averageQuizScore'] as num?)?.toDouble() ?? 0.0,
          recentActivity: [], // Would need separate endpoint
        );
      }

      return null;
    } catch (e) {
      // If stats fail, don't fail the whole profile load
      return null;
    }
  }

  // Change password
  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      await _apiClient.dio.post(
        '/auth/change-password',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Current password is incorrect');
      }
      throw Exception('Failed to change password: ${e.message}');
    }
  }

  // Upload profile image
  Future<UserProfile> uploadProfileImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _apiClient.dio.post(
        '/auth/profile/upload-image',
        data: formData,
      );

      final data = response.data['data'] ?? response.data;
      return UserProfile.fromJson(data);
    } on DioException catch (e) {
      throw Exception('Failed to upload image: ${e.message}');
    }
  }

  // ==================== TWO-FACTOR AUTHENTICATION ====================

  // Setup 2FA - Get secret and QR code
  Future<TwoFactorSetupResponse> setup2FA() async {
    try {
      final response = await _apiClient.dio.post('/auth/2fa/setup');
      return TwoFactorSetupResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to setup 2FA: ${e.message}');
    }
  }

  // Enable 2FA after verifying code
  Future<TwoFactorResponse> enable2FA(String code) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/2fa/enable',
        data: Enable2FARequest(code: code).toJson(),
      );
      return TwoFactorResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid verification code');
      }
      throw Exception('Failed to enable 2FA: ${e.message}');
    }
  }

  // Disable 2FA
  Future<TwoFactorResponse> disable2FA(String password, String code) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/2fa/disable',
        data: Disable2FARequest(password: password, code: code).toJson(),
      );
      return TwoFactorResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid password or code');
      }
      throw Exception('Failed to disable 2FA: ${e.message}');
    }
  }

  // Send OTP via email
  Future<TwoFactorResponse> sendEmailOTP() async {
    try {
      final response = await _apiClient.dio.post('/auth/2fa/send-email-otp');
      return TwoFactorResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to send OTP: ${e.message}');
    }
  }
}
