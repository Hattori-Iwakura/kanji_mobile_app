import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'core/network/api_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==================== Features - Auth ====================

  // BLoC
  sl.registerFactory(
    () => AuthBloc(repository: sl(), authService: sl(), apiClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );

  // Auth Service
  sl.registerLazySingleton<AuthService>(() => AuthService(sl()));

  // ==================== Core ====================

  // API Client
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
}
