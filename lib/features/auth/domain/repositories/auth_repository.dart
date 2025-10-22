import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, AuthResult>> login({
    required String account,
    required String password,
  });

  /// Register new user
  Future<Either<Failure, AuthResult>> register({
    required String account,
    required String email,
    required String password,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Get current user profile
  Future<Either<Failure, User>> getProfile();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? profileImage,
  });

  /// Change password
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// Forgot password - send reset email
  Future<Either<Failure, void>> forgotPassword({required String email});

  /// Reset password with token
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Refresh access token
  Future<Either<Failure, AuthResult>> refreshToken({
    required String refreshToken,
    String? sessionId,
  });

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get cached user
  Future<User?> getCachedUser();

  /// Clear cached auth data
  Future<void> clearAuthData();
}
