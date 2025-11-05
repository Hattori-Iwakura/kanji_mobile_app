/// Exception - Base class cho tất cả exceptions trong Data layer
///
/// Clean Architecture pattern:
/// - Data layer throws Exceptions khi có lỗi (network, server, cache)
/// - Repository catch Exceptions và convert thành Failures
/// - Domain layer chỉ nhận Failures, không biết đến Exceptions
///
/// Flow: DataSource throws Exception -> Repository catches -> Returns Either<Failure, Data>

/// Lỗi từ Server API
/// VD: 400 Bad Request, 401 Unauthorized, 500 Internal Server Error
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

/// Lỗi Network connection
/// VD: SocketException, TimeoutException, No Internet
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

/// Lỗi Cache operations
/// VD: Failed to read/write cache, corrupted data
class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

/// Lỗi Authentication/Authorization
/// VD: Token expired, invalid credentials, missing permissions
class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException(this.message);
}
