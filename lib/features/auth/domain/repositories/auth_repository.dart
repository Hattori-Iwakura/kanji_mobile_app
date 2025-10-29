import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../entities/two_factor_setup.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(
    String email,
    String password, {
    String? twoFactorCode,
  });
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String name,
  );
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? profileImage,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> isAuthenticated();
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, void>> resetPassword(String token, String newPassword);

  // 2FA methods
  Future<Either<Failure, TwoFactorSetup>> setup2FA();
  Future<Either<Failure, User>> enable2FA(String code);
  Future<Either<Failure, User>> disable2FA(String password, String code);
  Future<Either<Failure, void>> sendEmailOTP();
}
