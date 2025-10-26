import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../entities/update_user_dto.dart';

abstract class UserManagementRepository {
  Future<Either<Failure, List<User>>> getAllUsers({
    int? page,
    int? limit,
    String? search,
    String? role,
    String? status,
  });

  Future<Either<Failure, User>> getUserById(int userId);

  Future<Either<Failure, User>> updateUser(int userId, UpdateUserDto dto);

  Future<Either<Failure, void>> deleteUser(int userId);
}
