import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/update_user_dto.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../datasources/user_management_remote_datasource.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final UserManagementRemoteDataSource remoteDataSource;

  UserManagementRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<User>>> getAllUsers({
    int? page,
    int? limit,
    String? search,
    String? role,
    String? status,
  }) async {
    try {
      final result = await remoteDataSource.getAllUsers(
        page: page,
        limit: limit,
        search: search,
        role: role,
        status: status,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(int userId) async {
    try {
      final result = await remoteDataSource.getUserById(userId);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(
    int userId,
    UpdateUserDto dto,
  ) async {
    try {
      final result = await remoteDataSource.updateUser(userId, dto);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(int userId) async {
    try {
      await remoteDataSource.deleteUser(userId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Failure _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(message: 'Connection timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return AuthenticationFailure(
            message: 'Unauthorized. Admin access required.',
          );
        } else if (statusCode == 403) {
          return AuthenticationFailure(
            message: 'Forbidden. Insufficient permissions.',
          );
        } else if (statusCode == 404) {
          return NotFoundFailure(message: 'User not found.');
        } else if (statusCode != null && statusCode >= 500) {
          return ServerFailure(message: 'Server error. Please try again.');
        }
        return ServerFailure(
          message: error.response?.data['message'] ?? 'Unknown error',
        );
      case DioExceptionType.cancel:
        return NetworkFailure(message: 'Request cancelled.');
      case DioExceptionType.connectionError:
        return NetworkFailure(
          message: 'No internet connection. Please check your connection.',
        );
      default:
        return UnknownFailure(message: error.message ?? 'Unknown error');
    }
  }
}
