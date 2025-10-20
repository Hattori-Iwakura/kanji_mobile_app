/// Base class for exceptions in the app
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception thrown when network request fails
class ServerException extends AppException {
  ServerException(super.message, {super.code});
}

/// Exception thrown when cache operation fails
class CacheException extends AppException {
  CacheException(super.message, {super.code});
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  AuthenticationException(super.message, {super.code});
}

/// Exception thrown when authorization fails
class AuthorizationException extends AppException {
  AuthorizationException(super.message, {super.code});
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  ValidationException(super.message, {super.code});
}

/// Exception thrown when resource is not found
class NotFoundException extends AppException {
  NotFoundException(super.message, {super.code});
}
