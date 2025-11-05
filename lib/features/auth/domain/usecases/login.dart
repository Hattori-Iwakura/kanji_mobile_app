import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Login UseCase - Encapsulate business logic cho login action
///
/// UseCase Pattern principles:
/// - Mỗi UseCase làm MỘT việc duy nhất (Single Responsibility)
/// - Tách biệt business logic khỏi UI (Presentation) và API calls (Data)
/// - Dễ test vì logic đơn giản và isolated
/// - Dễ reuse trong nhiều nơi
///
/// Flow:
/// 1. UI gọi: authBloc.add(LoginRequested(email, password))
/// 2. BLoC gọi: login(email, password)
/// 3. UseCase gọi: repository.login(email, password)
/// 4. Repository gọi API và return Either<Failure, User>
/// 5. BLoC emit state: AuthSuccess(user) hoặc AuthFailure(message)
///
/// Tại sao cần UseCase layer?
/// - Nếu business logic phức tạp (vd: validate input, combine multiple repos)
/// - Có thể thêm logic trước/sau khi gọi repository
/// - Giữ cho Repository methods đơn giản
class Login {
  final AuthRepository repository;

  Login(this.repository);

  /// Call method - Cho phép gọi usecase như một function
  /// Usage: login(email, password)
  ///
  /// Params:
  /// - email: Email của user
  /// - password: Password
  /// - twoFactorCode: OTP code nếu user đã bật 2FA (optional)
  ///
  /// Returns:
  /// - Either<Failure, User>: Failure nếu lỗi, User nếu thành công
  Future<Either<Failure, User>> call(
    String email,
    String password, {
    String? twoFactorCode,
  }) {
    // Có thể thêm validation ở đây trước khi gọi repository
    // VD: Check email format, password length, etc.

    return repository.login(email, password, twoFactorCode: twoFactorCode);
  }
}
