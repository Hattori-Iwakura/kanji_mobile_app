import 'package:equatable/equatable.dart';

/// Failure - Abstract base class cho tất cả các lỗi trong Domain layer
///
/// Clean Architecture pattern:
/// - Domain layer không được throw Exceptions (exceptions thuộc Data layer)
/// - Thay vào đó sử dụng Failure objects được wrap trong Either<Failure, Success>
/// - UI có thể hiển thị error message từ Failure một cách dễ dàng
///
/// Extends Equatable để so sánh Failures trong tests
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Lỗi từ Server (API trả về lỗi)
/// VD: 400 Bad Request, 500 Internal Server Error
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Lỗi Network (không kết nối được server)
/// VD: Không có internet, timeout, DNS error
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Lỗi Cache (không đọc/ghi được cache)
/// VD: Corrupted cache data, storage full
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Lỗi Unauthorized (không có quyền truy cập)
/// VD: Token expired, invalid token, không đủ permissions
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}
