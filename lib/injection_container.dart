import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage.dart';
import 'core/services/cache_service.dart';
import 'core/services/kanji_alive_service.dart';
import 'core/services/jisho_service.dart';
import 'core/services/kanji_vg_service.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/check_auth_status.dart';
import 'features/auth/domain/usecases/get_profile.dart';
import 'features/auth/domain/usecases/update_profile.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/register.dart';
import 'features/auth/domain/usecases/forgot_password.dart';
import 'features/auth/domain/usecases/reset_password.dart';
import 'features/auth/domain/usecases/change_password.dart';
import 'features/auth/domain/usecases/setup_2fa.dart';
import 'features/auth/domain/usecases/enable_2fa.dart';
import 'features/auth/domain/usecases/disable_2fa.dart';
import 'features/auth/domain/usecases/send_email_otp.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/kanji/data/datasources/kanji_remote_data_source.dart';
import 'features/kanji/data/repositories/kanji_repository_impl.dart';
import 'features/kanji/domain/repositories/kanji_repository.dart';
import 'features/kanji/domain/usecases/get_kanji_list.dart';
import 'features/kanji/domain/usecases/get_kanji_detail.dart';
import 'features/kanji/domain/usecases/search_kanji.dart';
import 'features/kanji/domain/usecases/create_kanji.dart';
import 'features/kanji/domain/usecases/update_kanji.dart';
import 'features/kanji/domain/usecases/delete_kanji.dart';
import 'features/kanji/presentation/bloc/kanji_bloc.dart';
import 'features/kanji_table/data/datasources/kanji_table_remote_datasource.dart';
import 'features/kanji_table/data/repositories/kanji_table_repository_impl.dart';
import 'features/kanji_table/domain/repositories/kanji_table_repository.dart';
import 'features/kanji_table/domain/usecases/kanji_table_usecases.dart';
import 'features/kanji_table/presentation/bloc/kanji_table_bloc.dart';
import 'features/flashcard/data/datasources/flashcard_remote_datasource.dart';
import 'features/flashcard/data/repositories/flashcard_repository_impl.dart';
import 'features/flashcard/domain/repositories/flashcard_repository.dart';
import 'features/flashcard/domain/usecases/flashcard_usecases.dart';
import 'features/flashcard/presentation/bloc/flashcard_bloc.dart';
import 'features/quiz/data/datasources/quiz_remote_datasource.dart';
import 'features/quiz/data/repositories/quiz_repository_impl.dart';
import 'features/quiz/domain/repositories/quiz_repository.dart';
import 'features/quiz/domain/usecases/get_quizzes.dart';
import 'features/quiz/domain/usecases/get_quiz_detail.dart';
import 'features/quiz/domain/usecases/create_quiz.dart';
import 'features/quiz/domain/usecases/update_quiz.dart';
import 'features/quiz/domain/usecases/delete_quiz.dart';
import 'features/quiz/domain/usecases/add_question.dart';
import 'features/quiz/domain/usecases/update_question.dart';
import 'features/quiz/domain/usecases/delete_question.dart';
import 'features/quiz/domain/usecases/start_quiz_attempt.dart';
import 'features/quiz/domain/usecases/submit_quiz_attempt.dart';
import 'features/quiz/domain/usecases/get_quiz_attempts.dart';
import 'features/quiz/domain/usecases/get_quiz_attempt_details.dart';
import 'features/quiz/presentation/bloc/quiz_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies({
  SharedPreferences? mockSharedPreferences,
}) async {
  // SharedPreferences (for caching)
  // Use mock if provided (for testing), otherwise get real instance
  if (!sl.isRegistered<SharedPreferences>()) {
    final sharedPreferences =
        mockSharedPreferences ?? await SharedPreferences.getInstance();
    sl.registerLazySingleton(() => sharedPreferences);
  }

  // Core
  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(() => ApiClient());
  }
  if (!sl.isRegistered<SecureStorage>()) {
    sl.registerLazySingleton(() => SecureStorage());
  }
  if (!sl.isRegistered<CacheService>()) {
    sl.registerLazySingleton(() => CacheService(sl()));
  }

  // Dio for external APIs
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton(() => Dio());
  }

  // External services (with caching)
  sl.registerLazySingleton(() => KanjiAliveService(sl(), sl()));
  sl.registerLazySingleton(() => JishoService(sl(), sl()));
  sl.registerLazySingleton(() => KanjiVGService(sl(), sl()));

  // Auth - Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  // Auth - Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      apiClient: sl(),
    ),
  );

  // Auth - Use cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerLazySingleton(() => ChangePassword(sl()));
  sl.registerLazySingleton(() => Setup2FA(sl()));
  sl.registerLazySingleton(() => Enable2FA(sl()));
  sl.registerLazySingleton(() => Disable2FA(sl()));
  sl.registerLazySingleton(() => SendEmailOTP(sl()));

  // Auth - Bloc
  sl.registerFactory(
    () => AuthBloc(
      login: sl(),
      register: sl(),
      logout: sl(),
      getProfile: sl(),
      checkAuthStatus: sl(),
      setup2FA: sl(),
      enable2FA: sl(),
      disable2FA: sl(),
      sendEmailOTP: sl(),
      forgotPassword: sl(),
      resetPassword: sl(),
      changePassword: sl(),
    ),
  );

  // Kanji - Data sources
  sl.registerLazySingleton<KanjiRemoteDataSource>(
    () => KanjiRemoteDataSourceImpl(sl()),
  );

  // Kanji - Repository
  sl.registerLazySingleton<KanjiRepository>(
    () => KanjiRepositoryImpl(
      remoteDataSource: sl(),
      kanjiAliveService: sl(),
      jishoService: sl(),
      kanjiVGService: sl(),
    ),
  );

  // Kanji - Use cases
  sl.registerLazySingleton(() => GetKanjiList(sl()));
  sl.registerLazySingleton(() => GetKanjiDetail(sl()));
  sl.registerLazySingleton(() => SearchKanji(sl()));
  sl.registerLazySingleton(() => CreateKanji(sl()));
  sl.registerLazySingleton(() => UpdateKanji(sl()));
  sl.registerLazySingleton(() => DeleteKanji(sl()));

  // Kanji - Bloc
  sl.registerFactory(
    () => KanjiBloc(
      getKanjiList: sl(),
      getKanjiDetail: sl(),
      searchKanji: sl(),
      updateKanji: sl(),
      kanjiRepository: sl(),
    ),
  );

  // KanjiTable - Data sources
  sl.registerLazySingleton<KanjiTableRemoteDataSource>(
    () => KanjiTableRemoteDataSourceImpl(dio: sl<ApiClient>().dio),
  );

  // KanjiTable - Repository
  sl.registerLazySingleton<KanjiTableRepository>(
    () => KanjiTableRepositoryImpl(remoteDataSource: sl()),
  );

  // KanjiTable - Use cases
  sl.registerLazySingleton(() => GetTablesByJlptUseCase(sl()));
  sl.registerLazySingleton(() => GetAllTablesUseCase(sl()));
  sl.registerLazySingleton(() => GetTableByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateTableUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTableUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTableUseCase(sl()));
  sl.registerLazySingleton(() => AddKanjiToTableUseCase(sl()));
  sl.registerLazySingleton(() => RemoveKanjiFromTableUseCase(sl()));
  sl.registerLazySingleton(() => RequestPublishUseCase(sl()));

  // KanjiTable - Bloc
  sl.registerFactory(
    () => KanjiTableBloc(
      getTablesByJlpt: sl(),
      getAllTables: sl(),
      getTableById: sl(),
      createTable: sl(),
      updateTable: sl(),
      deleteTable: sl(),
      addKanjiToTable: sl(),
      removeKanjiFromTable: sl(),
      requestPublish: sl(),
    ),
  );

  // Flashcard - Data sources
  sl.registerLazySingleton<FlashcardRemoteDataSource>(
    () => FlashcardRemoteDataSourceImpl(apiClient: sl(), secureStorage: sl()),
  );

  // Flashcard - Repository
  sl.registerLazySingleton<FlashcardRepository>(
    () => FlashcardRepositoryImpl(remoteDataSource: sl()),
  );

  // Flashcard - Use cases
  sl.registerLazySingleton(() => GetDecksUseCase(sl()));
  sl.registerLazySingleton(() => GetDeckByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateDeckUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDeckUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDeckUseCase(sl()));
  sl.registerLazySingleton(() => AddCardToDeckUseCase(sl()));
  sl.registerLazySingleton(() => RemoveCardFromDeckUseCase(sl()));
  sl.registerLazySingleton(() => StartSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionProgressUseCase(sl()));
  sl.registerLazySingleton(() => GetNextCardUseCase(sl()));
  sl.registerLazySingleton(() => ReviewCardUseCase(sl()));
  sl.registerLazySingleton(() => CompleteSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetDueCardsUseCase(sl()));
  sl.registerLazySingleton(() => GetDeckStatisticsUseCase(sl()));

  // Flashcard - Bloc
  sl.registerFactory(
    () => FlashcardBloc(
      getDecks: sl(),
      getDeckById: sl(),
      createDeck: sl(),
      updateDeck: sl(),
      deleteDeck: sl(),
      addCardToDeck: sl(),
      removeCardFromDeck: sl(),
      startSession: sl(),
      getSessionProgress: sl(),
      getNextCard: sl(),
      reviewCard: sl(),
      completeSession: sl(),
      getDueCards: sl(),
      getDeckStatistics: sl(),
    ),
  );

  // Quiz - Data sources
  sl.registerLazySingleton<QuizRemoteDataSource>(
    () => QuizRemoteDataSourceImpl(apiClient: sl(), secureStorage: sl()),
  );

  // Quiz - Repository
  sl.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(remoteDataSource: sl()),
  );

  // Quiz - Use cases
  sl.registerLazySingleton(() => GetQuizzesUseCase(sl()));
  sl.registerLazySingleton(() => GetQuizDetailUseCase(sl()));
  sl.registerLazySingleton(() => CreateQuizUseCase(sl()));
  sl.registerLazySingleton(() => UpdateQuizUseCase(sl()));
  sl.registerLazySingleton(() => DeleteQuizUseCase(sl()));
  sl.registerLazySingleton(() => AddQuestionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateQuestionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteQuestionUseCase(sl()));
  sl.registerLazySingleton(() => StartQuizAttemptUseCase(sl()));
  sl.registerLazySingleton(() => SubmitQuizAttemptUseCase(sl()));
  sl.registerLazySingleton(() => GetQuizAttemptsUseCase(sl()));
  sl.registerLazySingleton(() => GetQuizAttemptDetailsUseCase(sl()));

  // Quiz - Bloc
  sl.registerFactory(
    () => QuizBloc(
      getQuizzesUseCase: sl(),
      getQuizDetailUseCase: sl(),
      createQuizUseCase: sl(),
      updateQuizUseCase: sl(),
      deleteQuizUseCase: sl(),
      addQuestionUseCase: sl(),
      updateQuestionUseCase: sl(),
      deleteQuestionUseCase: sl(),
      startQuizAttemptUseCase: sl(),
      submitQuizAttemptUseCase: sl(),
      getQuizAttemptsUseCase: sl(),
      getQuizAttemptDetailsUseCase: sl(),
    ),
  );
}
