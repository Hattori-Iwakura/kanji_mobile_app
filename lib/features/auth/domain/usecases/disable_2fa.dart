import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Disable2FA {
  final AuthRepository repository;

  Disable2FA(this.repository);

  Future<Either<Failure, User>> call({
    required String password,
    required String code,
  }) async {
    return await repository.disable2FA(password, code);
  }
}
