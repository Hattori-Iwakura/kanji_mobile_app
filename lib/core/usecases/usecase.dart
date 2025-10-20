import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for all use cases in the application
///
/// A use case represents a single business operation/action
/// It takes parameters of type [Params] and returns [Either<Failure, Type>]
///
/// Example:
/// ```dart
/// class LoginUser extends UseCase<User, LoginParams> {
///   final AuthRepository repository;
///
///   LoginUser(this.repository);
///
///   @override
///   Future<Either<Failure, User>> call(LoginParams params) async {
///     return await repository.login(params.email, params.password);
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  /// Execute the use case
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case with no parameters
/// Use [NoParams] for use cases that don't need parameters
class NoParams {
  const NoParams();
}
