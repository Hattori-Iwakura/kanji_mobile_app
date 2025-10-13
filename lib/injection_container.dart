import 'package:get_it/get_it.dart';
import 'core/database/database_helper.dart';
import 'features/kanji/data/datasources/kanji_local_data_source.dart';
import 'features/kanji/data/datasources/kanji_list_local_data_source.dart';
import 'features/kanji/data/repositories/kanji_repository_impl.dart';
import 'features/kanji/data/repositories/kanji_list_repository_impl.dart';
import 'features/kanji/domain/repositories/kanji_repository.dart';
import 'features/kanji/domain/repositories/kanji_list_repository.dart';
import 'features/kanji/domain/usecases/get_all_kanji.dart';
import 'features/kanji/domain/usecases/get_kanji_by_grade.dart';
import 'features/kanji/domain/usecases/get_kanji_by_jlpt_level.dart';
import 'features/kanji/domain/usecases/get_kanji_by_frequency.dart';
import 'features/kanji/domain/usecases/search_kanji.dart';
import 'features/kanji/domain/usecases/get_kanji_stats.dart';
import 'features/kanji/domain/usecases/get_all_kanji_lists.dart';
import 'features/kanji/domain/usecases/create_kanji_list.dart';
import 'features/kanji/domain/usecases/delete_kanji_list.dart';
import 'features/kanji/presentation/bloc/kanji_bloc.dart';
import 'features/kanji/presentation/bloc/kanji_list_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(
    () =>
        KanjiBloc(getAllKanji: sl(), getKanjiByGrade: sl(), searchKanji: sl()),
  );

  sl.registerFactory(
    () => KanjiListBloc(
      getAllLists: sl(),
      createList: sl(),
      deleteList: sl(),
      getKanjiByGrade: sl(),
      getKanjiByJlptLevel: sl(),
      getKanjiByFrequency: sl(),
    ),
  );

  // Use cases - Kanji
  sl.registerLazySingleton(() => GetAllKanji(sl()));
  sl.registerLazySingleton(() => GetKanjiByGrade(sl()));
  sl.registerLazySingleton(() => GetKanjiByJlptLevel(sl()));
  sl.registerLazySingleton(() => GetKanjiByFrequency(sl()));
  sl.registerLazySingleton(() => SearchKanji(sl()));
  sl.registerLazySingleton(() => GetKanjiStats(sl()));

  // Use cases - Kanji Lists
  sl.registerLazySingleton(() => GetAllKanjiLists(sl()));
  sl.registerLazySingleton(() => CreateKanjiList(sl()));
  sl.registerLazySingleton(() => DeleteKanjiList(sl()));

  // Repository
  sl.registerLazySingleton<KanjiRepository>(
    () => KanjiRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<KanjiListRepository>(
    () => KanjiListRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<KanjiLocalDataSource>(
    () => KanjiLocalDataSourceImpl(databaseHelper: sl()),
  );

  sl.registerLazySingleton<KanjiListLocalDataSource>(
    () => KanjiListLocalDataSourceImpl(databaseHelper: sl()),
  );

  // Core
  sl.registerLazySingleton(() => DatabaseHelper.instance);
}
