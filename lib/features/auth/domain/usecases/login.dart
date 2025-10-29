import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<Either<Failure, User>> call(
    String email,
    String password, {
    String? twoFactorCode,
  }) {
    return repository.login(email, password, twoFactorCode: twoFactorCode);
  }
}
