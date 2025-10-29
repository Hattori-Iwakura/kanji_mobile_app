import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Enable2FA {
  final AuthRepository repository;

  Enable2FA(this.repository);

  Future<Either<Failure, User>> call(String code) async {
    return await repository.enable2FA(code);
  }
}
