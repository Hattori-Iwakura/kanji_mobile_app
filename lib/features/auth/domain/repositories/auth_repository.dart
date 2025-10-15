import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login(String account, String password);
  Future<Either<Failure, AuthResponse>> refreshToken(
    String sessionId,
    String refreshToken,
  );
  Future<Either<Failure, void>> logout(String sessionId);
}
