import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetProfile {
  final AuthRepository repository;

  GetProfile(this.repository);

  Future<Either<Failure, User>> call() {
    return repository.getProfile();
  }
}
