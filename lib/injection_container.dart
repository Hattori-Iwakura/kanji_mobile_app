import 'package:get_it/get_it.dart';
import 'core/database/database_helper.dart';
import 'features/kanji/data/datasources/kanji_local_data_source.dart';
import 'features/kanji/data/repositories/kanji_repository_impl.dart';
import 'features/kanji/domain/repositories/kanji_repository.dart';
import 'features/kanji/domain/usecases/get_all_kanji.dart';
import 'features/kanji/domain/usecases/get_kanji_by_grade.dart';
import 'features/kanji/domain/usecases/search_kanji.dart';
import 'features/kanji/domain/usecases/get_kanji_stats.dart';
import 'features/kanji/presentation/bloc/kanji_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(
    () =>
        KanjiBloc(getAllKanji: sl(), getKanjiByGrade: sl(), searchKanji: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllKanji(sl()));
  sl.registerLazySingleton(() => GetKanjiByGrade(sl()));
  sl.registerLazySingleton(() => SearchKanji(sl()));
  sl.registerLazySingleton(() => GetKanjiStats(sl()));

  // Repository
  sl.registerLazySingleton<KanjiRepository>(
    () => KanjiRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<KanjiLocalDataSource>(
    () => KanjiLocalDataSourceImpl(databaseHelper: sl()),
  );

  // Core
  sl.registerLazySingleton(() => DatabaseHelper.instance);
}
