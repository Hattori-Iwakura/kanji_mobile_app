import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthResult>> login({
    required String account,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        account: account,
        password: password,
      );

      // Cache tokens and user
      await localDataSource.cacheAuthTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        sessionId: result.sessionId,
      );
      await localDataSource.cacheUser(result.user as dynamic);

      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> register({
    required String account,
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.register(
        account: account,
        email: email,
        password: password,
      );

      // Cache tokens and user
      await localDataSource.cacheAuthTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        sessionId: result.sessionId,
      );
      await localDataSource.cacheUser(result.user as dynamic);

      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAuthData();
      return const Right(null);
    } on DioException catch (e) {
      // Even if remote logout fails, clear local data
      await localDataSource.clearAuthData();
      return Left(_handleDioException(e));
    } catch (e) {
      await localDataSource.clearAuthData();
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final user = await remoteDataSource.getProfile();
      await localDataSource.cacheUser(user);
      return Right(user.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? profileImage,
  }) async {
    try {
      final user = await remoteDataSource.updateProfile(
        name: name,
        profileImage: profileImage,
      );
      await localDataSource.cacheUser(user);
      return Right(user.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> refreshToken({
    required String refreshToken,
    String? sessionId,
  }) async {
    try {
      final result = await remoteDataSource.refreshToken(
        refreshToken: refreshToken,
        sessionId: sessionId,
      );

      // Cache new tokens
      await localDataSource.cacheAuthTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        sessionId: result.sessionId,
      );

      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final accessToken = await localDataSource.getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  @override
  Future<User?> getCachedUser() async {
    final userModel = await localDataSource.getCachedUser();
    return userModel?.toEntity();
  }

  @override
  Future<void> clearAuthData() async {
    await localDataSource.clearAuthData();
  }

  // Helper method to handle Dio exceptions
  Failure _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(e.message ?? 'Request timeout');

      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return const UnauthorizedFailure('Unauthorized access');
        } else if (statusCode == 404) {
          return const NotFoundFailure('Resource not found');
        } else if (statusCode == 500) {
          return const ServerFailure('Internal server error');
        }
        return ServerFailure(e.error?.toString() ?? 'Server error occurred');

      case DioExceptionType.cancel:
        return const UnknownFailure('Request cancelled');

      default:
        return UnknownFailure(e.message ?? 'An unknown error occurred');
    }
  }
}
