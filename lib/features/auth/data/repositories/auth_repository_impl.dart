import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/two_factor_setup.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.apiClient,
  });

  @override
  Future<Either<Failure, User>> login(
    String email,
    String password, {
    String? twoFactorCode,
  }) async {
    try {
      final response = await remoteDataSource.login(
        email,
        password,
        twoFactorCode: twoFactorCode,
      );

      // Backend returns: {statusCode, data: {user, accessToken}, timestamp}
      final data = response['data'] as Map<String, dynamic>;

      print('=== REPOSITORY CHECK ===');
      print('Response data: $data');
      print('requires2FA: ${data['requires2FA']}');
      print('========================');

      // Check if 2FA is required
      if (data['requires2FA'] == true) {
        final message = data['message'] as String? ?? '2FA code required';
        print('=== 2FA REQUIRED - Throwing UnauthorizedException ===');
        throw UnauthorizedException(message);
      }

      final token = data['accessToken'] as String;
      final userData = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);

      // Save token and user ID
      await localDataSource.saveToken(token);
      await localDataSource.saveUserId(user.id.toString());

      // Set token in API client for future requests
      apiClient.setAuthToken(token);

      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await remoteDataSource.register(email, password, name);

      // Backend returns: {statusCode, data: {user, accessToken}, timestamp}
      final data = response['data'] as Map<String, dynamic>;
      final token = data['accessToken'] as String;
      final userData = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);

      // Save token and user ID
      await localDataSource.saveToken(token);
      await localDataSource.saveUserId(user.id.toString());

      // Set token in API client
      apiClient.setAuthToken(token);

      return Right(user);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      // Get token and set it in API client
      final token = await localDataSource.getToken();
      if (token != null) {
        apiClient.setAuthToken(token);
      }

      final user = await remoteDataSource.getProfile();
      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearAuth();
      apiClient.clearAuthToken();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to logout'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final hasToken = await localDataSource.hasToken();
      if (hasToken) {
        final token = await localDataSource.getToken();
        if (token != null) {
          apiClient.setAuthToken(token);
        }
      }
      return Right(hasToken);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? profileImage,
  }) async {
    try {
      final token = await localDataSource.getToken();
      if (token != null) {
        apiClient.setAuthToken(token);
      }

      final user = await remoteDataSource.updateProfile(
        name: name,
        profileImage: profileImage,
      );
      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.resetPassword(token, newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final token = await localDataSource.getToken();
      if (token != null) {
        apiClient.setAuthToken(token);
      }

      await remoteDataSource.changePassword(currentPassword, newPassword);
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, TwoFactorSetup>> setup2FA() async {
    try {
      final token = await localDataSource.getToken();
      if (token != null) {
        apiClient.setAuthToken(token);
      }

      final setup = await remoteDataSource.setup2FA();
      return Right(setup);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> enable2FA(String code) async {
    try {
      final token = await localDataSource.getToken();
      if (token != null) {
        apiClient.setAuthToken(token);
      }

      final user = await remoteDataSource.enable2FA(code);
      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> disable2FA(String password, String code) async {
    try {
      final token = await localDataSource.getToken();
      if (token != null) {
        apiClient.setAuthToken(token);
      }

      final user = await remoteDataSource.disable2FA(password, code);
      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailOTP() async {
    try {
      final token = await localDataSource.getToken();
      if (token != null) {
        apiClient.setAuthToken(token);
      }

      await remoteDataSource.sendEmailOTP();
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
