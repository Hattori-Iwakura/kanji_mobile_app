import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Server failure (5xx errors)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred'])
    : super(message);
}

/// Network failure (connection issues)
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network connection failed'])
    : super(message);
}

/// Unauthorized failure (401, 403)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'Unauthorized access'])
    : super(message);
}

/// Not found failure (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Resource not found'])
    : super(message);
}

/// Bad request failure (400)
class BadRequestFailure extends Failure {
  const BadRequestFailure([String message = 'Bad request']) : super(message);
}

/// Cache failure (local storage)
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred'])
    : super(message);
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation failed'])
    : super(message);
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unknown error occurred'])
    : super(message);
}
