import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/two_factor_setup.dart';
import '../repositories/auth_repository.dart';

class Setup2FA {
  final AuthRepository repository;

  Setup2FA(this.repository);

  Future<Either<Failure, TwoFactorSetup>> call() async {
    return await repository.setup2FA();
  }
}
