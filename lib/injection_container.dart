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

/// GetIt Service Locator instance - Global singleton
/// Sử dụng: sl<Type>() để lấy instance từ container
/// VD: sl<AuthRepository>(), sl<Login>(), sl<AuthBloc>()
final sl = GetIt.instance;

/// Hàm khởi tạo tất cả dependencies cho app
///
/// Dependency Injection Pattern:
/// - Tách biệt việc tạo objects khỏi việc sử dụng objects
/// - Dễ dàng thay thế implementations (vd: mock cho testing)
/// - Tuân theo Dependency Inversion Principle (SOLID)
///
/// Các loại registration:
/// 1. registerLazySingleton: Tạo 1 instance duy nhất khi được gọi lần đầu
///    - Dùng cho: Services, Repositories, UseCases
/// 2. registerFactory: Tạo instance mới mỗi lần được gọi
///    - Dùng cho: BLoCs (mỗi page có BLoC riêng)
///
/// Thứ tự đăng ký:
/// 1. Core dependencies (SharedPreferences, ApiClient, SecureStorage)
/// 2. External services (KanjiAlive, Jisho, KanjiVG)
/// 3. Data sources (Remote, Local)
/// 4. Repositories
/// 5. Use cases
/// 6. BLoCs
///
/// Gọi trong main.dart: await initializeDependencies();
Future<void> initializeDependencies({
  SharedPreferences? mockSharedPreferences,
}) async {
  // ============ CORE DEPENDENCIES ============

  // SharedPreferences - Để lưu cache và settings
  // Kiểm tra đã đăng ký chưa để tránh duplicate registration
  if (!sl.isRegistered<SharedPreferences>()) {
    final sharedPreferences =
        mockSharedPreferences ?? await SharedPreferences.getInstance();
    sl.registerLazySingleton(() => sharedPreferences);
  }

  // ApiClient - HTTP client cho Backend API
  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(() => ApiClient());
  }

  // SecureStorage - Lưu JWT token một cách an toàn
  if (!sl.isRegistered<SecureStorage>()) {
    sl.registerLazySingleton(() => SecureStorage());
  }

  // CacheService - Cache responses từ external APIs
  if (!sl.isRegistered<CacheService>()) {
    sl.registerLazySingleton(() => CacheService(sl()));
  }

  // Dio - HTTP client riêng cho external APIs (KanjiAlive, Jisho, KanjiVG)
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton(() => Dio());
  }

  // ============ EXTERNAL API SERVICES ============
  // Các services này kết hợp external API + caching

  sl.registerLazySingleton(() => KanjiAliveService(sl(), sl()));
  sl.registerLazySingleton(() => JishoService(sl(), sl()));
  sl.registerLazySingleton(() => KanjiVGService(sl(), sl()));

  // ============ AUTH FEATURE ============

  // Data sources - Giao tiếp với API và Local storage
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  // Repository - Implement interface từ Domain layer
  // Kết hợp Remote + Local data sources
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      apiClient: sl(),
    ),
  );

  // Use cases - Business logic đơn giản, mỗi usecase làm 1 việc
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

  // BLoC - State management cho Auth feature
  // registerFactory để mỗi page có BLoC instance riêng
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

  // ============ KANJI FEATURE ============

  // Data source - Gọi Backend API
  sl.registerLazySingleton<KanjiRemoteDataSource>(
    () => KanjiRemoteDataSourceImpl(sl()),
  );

  // Repository - Kết hợp Backend API + External APIs
  // KanjiRepository gọi cả Backend và external services (KanjiAlive, Jisho, KanjiVG)
  sl.registerLazySingleton<KanjiRepository>(
    () => KanjiRepositoryImpl(
      remoteDataSource: sl(),
      kanjiAliveService: sl(),
      jishoService: sl(),
      kanjiVGService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetKanjiList(sl()));
  sl.registerLazySingleton(() => GetKanjiDetail(sl()));
  sl.registerLazySingleton(() => SearchKanji(sl()));
  sl.registerLazySingleton(() => CreateKanji(sl()));
  sl.registerLazySingleton(() => UpdateKanji(sl()));
  sl.registerLazySingleton(() => DeleteKanji(sl()));

  // BLoC
  sl.registerFactory(
    () => KanjiBloc(
      getKanjiList: sl(),
      getKanjiDetail: sl(),
      searchKanji: sl(),
      updateKanji: sl(),
      kanjiRepository: sl(),
    ),
  );

  // ============ KANJI TABLE FEATURE ============
  // Feature để quản lý tables (bộ từ vựng theo chủ đề/JLPT level)

  sl.registerLazySingleton<KanjiTableRemoteDataSource>(
    () => KanjiTableRemoteDataSourceImpl(dio: sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<KanjiTableRepository>(
    () => KanjiTableRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases - CRUD operations cho tables
  sl.registerLazySingleton(() => GetTablesByJlptUseCase(sl()));
  sl.registerLazySingleton(() => GetAllTablesUseCase(sl()));
  sl.registerLazySingleton(() => GetTableByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateTableUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTableUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTableUseCase(sl()));
  sl.registerLazySingleton(() => AddKanjiToTableUseCase(sl()));
  sl.registerLazySingleton(() => RemoveKanjiFromTableUseCase(sl()));
  sl.registerLazySingleton(() => RequestPublishUseCase(sl()));

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

  // ============ FLASHCARD FEATURE ============
  // Feature học flashcard với spaced repetition (SM-2 algorithm)

  sl.registerLazySingleton<FlashcardRemoteDataSource>(
    () => FlashcardRemoteDataSourceImpl(apiClient: sl(), secureStorage: sl()),
  );

  sl.registerLazySingleton<FlashcardRepository>(
    () => FlashcardRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases - Quản lý decks, cards, và session
  sl.registerLazySingleton(() => GetDecksUseCase(sl()));
  sl.registerLazySingleton(() => GetDeckByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateDeckUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDeckUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDeckUseCase(sl()));
  sl.registerLazySingleton(() => AddCardToDeckUseCase(sl()));
  sl.registerLazySingleton(() => RemoveCardFromDeckUseCase(sl()));
  sl.registerLazySingleton(() => StartSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionProgressUseCase(sl()));
  sl.registerLazySingleton(() => GetNextCardUseCase(sl()));
  sl.registerLazySingleton(() => ReviewCardUseCase(sl()));
  sl.registerLazySingleton(() => CompleteSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetDueCardsUseCase(sl()));
  sl.registerLazySingleton(() => GetDeckStatisticsUseCase(sl()));

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
      getActiveSession: sl(),
      getSessionProgress: sl(),
      getNextCard: sl(),
      reviewCard: sl(),
      completeSession: sl(),
      getDueCards: sl(),
      getDeckStatistics: sl(),
    ),
  );

  // ============ QUIZ FEATURE ============
  // Feature làm quiz với scoring system

  sl.registerLazySingleton<QuizRemoteDataSource>(
    () => QuizRemoteDataSourceImpl(apiClient: sl(), secureStorage: sl()),
  );

  sl.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases - CRUD quiz, questions, và attempt management
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
