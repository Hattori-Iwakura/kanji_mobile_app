import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Server/API related failures
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

/// Network connection failures
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// Cache related failures
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message) : super(message);
}

/// Permission/Authorization failures
class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message);
}
