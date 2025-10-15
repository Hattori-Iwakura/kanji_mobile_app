import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/kanji/data/datasources/kanji_remote_datasource.dart';
import 'features/kanji/data/repositories/kanji_repository_impl.dart';
import 'features/kanji/domain/repositories/kanji_repository.dart';
import 'features/kanji/domain/usecases/get_all_kanji.dart';
import 'features/kanji/domain/usecases/get_kanji_by_id.dart';
import 'features/kanji/domain/usecases/get_kanji_by_character.dart';
import 'features/kanji/domain/usecases/create_kanji.dart';
import 'features/kanji/domain/usecases/update_kanji.dart';
import 'features/kanji/domain/usecases/delete_kanji.dart';
import 'features/kanji/presentation/bloc/kanji_bloc.dart';
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

  // ==================== Features - Kanji ====================

  // BLoC
  sl.registerFactory(
    () => KanjiBloc(
      getAllKanjiUseCase: sl(),
      getKanjiByIdUseCase: sl(),
      getKanjiByCharacterUseCase: sl(),
      createKanjiUseCase: sl(),
      updateKanjiUseCase: sl(),
      deleteKanjiUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllKanji(sl()));
  sl.registerLazySingleton(() => GetKanjiById(sl()));
  sl.registerLazySingleton(() => GetKanjiByCharacter(sl()));
  sl.registerLazySingleton(() => CreateKanji(sl()));
  sl.registerLazySingleton(() => UpdateKanji(sl()));
  sl.registerLazySingleton(() => DeleteKanji(sl()));

  // Repository
  sl.registerLazySingleton<KanjiRepository>(
    () => KanjiRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<KanjiRemoteDataSource>(
    () => KanjiRemoteDataSourceImpl(apiClient: sl()),
  );

  // ==================== Core ====================

  // API Client
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
}
