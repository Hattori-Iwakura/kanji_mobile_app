import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SendEmailOTP {
  final AuthRepository repository;

  SendEmailOTP(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.sendEmailOTP();
  }
}
