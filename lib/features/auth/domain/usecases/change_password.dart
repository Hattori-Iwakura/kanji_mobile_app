import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ChangePassword {
  final AuthRepository repository;

  ChangePassword(this.repository);

  Future<Either<Failure, void>> call(
    String currentPassword,
    String newPassword,
  ) {
    return repository.changePassword(currentPassword, newPassword);
  }
}
