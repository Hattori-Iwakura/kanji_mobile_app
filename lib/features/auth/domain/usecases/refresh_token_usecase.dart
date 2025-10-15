import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call(
    String sessionId,
    String refreshToken,
  ) async {
    return await repository.refreshToken(sessionId, refreshToken);
  }
}
