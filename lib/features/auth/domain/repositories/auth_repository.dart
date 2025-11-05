import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../entities/two_factor_setup.dart';

/// AuthRepository Interface - Contract định nghĩa business logic trong Domain layer
///
/// Clean Architecture principles:
/// - Domain layer chỉ định nghĩa interface (abstract class)
/// - Data layer implement interface này (AuthRepositoryImpl)
/// - Dependency Inversion: Domain không phụ thuộc vào Data
///
/// Tại sao dùng Either<Failure, Success>?
/// - Functional programming approach để handle errors
/// - Left: Failure (lỗi) - Right: Success (data)
/// - Không throw exceptions -> code an toàn hơn
/// - UI có thể dễ dàng handle cả success và failure cases
///
/// Sử dụng trong:
/// - Use cases gọi repository methods
/// - BLoC handle Either results và emit states tương ứng
abstract class AuthRepository {
  /// Đăng nhập với email và password
  ///
  /// Params:
  /// - email: Email của user
  /// - password: Password (sẽ không được lưu plain text)
  /// - twoFactorCode: OTP code nếu user đã bật 2FA (optional)
  ///
  /// Returns:
  /// - Left(Failure): Nếu login thất bại (sai password, network error, etc.)
  /// - Right(User): Nếu login thành công
  Future<Either<Failure, User>> login(
    String email,
    String password, {
    String? twoFactorCode,
  });

  /// Đăng ký tài khoản mới
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String name,
  );

  /// Lấy thông tin profile của user hiện tại
  /// Requires: JWT token trong request header
  Future<Either<Failure, User>> getProfile();

  /// Cập nhật thông tin profile
  /// Có thể update name, profileImage hoặc cả 2
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? profileImage,
  });

  /// Đăng xuất - Xóa token và clear local data
  Future<Either<Failure, void>> logout();

  /// Kiểm tra user đã đăng nhập chưa
  /// Check token trong SecureStorage
  Future<Either<Failure, bool>> isAuthenticated();

  /// Quên mật khẩu - Gửi reset token qua email
  Future<Either<Failure, void>> forgotPassword(String email);

  /// Reset mật khẩu với token từ email
  Future<Either<Failure, void>> resetPassword(String token, String newPassword);

  /// Đổi mật khẩu (khi đã login)
  /// Requires: Password hiện tại để verify
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  );

  // ========== 2FA (Two-Factor Authentication) Methods ==========

  /// Bước 1: Setup 2FA - Generate secret và QR code
  /// Returns: TwoFactorSetup với secret và QR code URL
  Future<Either<Failure, TwoFactorSetup>> setup2FA();

  /// Bước 2: Enable 2FA - Verify OTP code từ Authenticator app
  /// User scan QR code -> Nhập OTP code để verify
  Future<Either<Failure, User>> enable2FA(String code);

  /// Disable 2FA - Tắt 2FA authentication
  /// Requires: Password và OTP code để verify
  Future<Either<Failure, User>> disable2FA(String password, String code);

  /// Gửi OTP qua email (alternative 2FA method)
  /// Dùng khi user không có Authenticator app
  Future<Either<Failure, void>> sendEmailOTP();
}
