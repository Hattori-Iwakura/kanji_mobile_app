import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_profile_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/kanji/data/datasources/kanji_remote_datasource.dart';
import '../../features/kanji/data/repositories/kanji_repository_impl.dart';
import '../../features/kanji/domain/repositories/kanji_repository.dart';
import '../../features/kanji/domain/usecases/get_all_kanji.dart';
import '../../features/kanji/domain/usecases/get_kanji_by_id.dart';
import '../../features/kanji/domain/usecases/search_kanji.dart';
import '../../features/kanji/presentation/bloc/kanji_bloc.dart';
import '../../features/cnn_recognition/data/datasources/cnn_recognition_remote_datasource.dart';
import '../../features/cnn_recognition/data/repositories/cnn_recognition_repository_impl.dart';
import '../../features/cnn_recognition/domain/repositories/cnn_recognition_repository.dart';
import '../../features/cnn_recognition/domain/usecases/predict_kanji.dart';
import '../../features/cnn_recognition/presentation/bloc/cnn_recognition_bloc.dart';
import '../../features/flashcard/data/datasources/flashcard_remote_datasource.dart';
import '../../features/flashcard/data/datasources/flashcard_local_datasource.dart';
import '../../features/flashcard/data/repositories/flashcard_repository_impl.dart';
import '../../features/flashcard/domain/repositories/flashcard_repository.dart';
import '../../features/flashcard/domain/usecases/get_all_decks.dart';
import '../../features/flashcard/domain/usecases/get_due_cards.dart';
import '../../features/flashcard/domain/usecases/update_card_review.dart';
import '../../features/flashcard/domain/usecases/save_study_progress.dart';
import '../../features/flashcard/presentation/bloc/flashcard_bloc.dart';
import '../../features/quiz/data/datasources/quiz_remote_datasource.dart';
import '../../features/quiz/data/repositories/quiz_repository_impl.dart';
import '../../features/quiz/domain/repositories/quiz_repository.dart';
import '../../features/quiz/domain/usecases/get_all_quizzes.dart';
import '../../features/quiz/domain/usecases/get_quiz_questions.dart';
import '../../features/quiz/domain/usecases/submit_quiz_answer.dart';
import '../../features/quiz/domain/usecases/complete_quiz.dart';
import '../../features/quiz/domain/usecases/get_quiz_history.dart';
import '../../features/quiz/presentation/bloc/quiz_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Core - External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  getIt.registerLazySingleton<Logger>(
    () => Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 50,
        colors: true,
        printEmojis: true,
      ),
    ),
  );

  // Core - Network
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt<FlutterSecureStorage>(), getIt<Logger>()),
  );

  // ========== AUTH FEATURE ==========
  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt<FlutterSecureStorage>()),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetProfileUseCase(getIt<AuthRepository>()));

  // BLoC
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getProfileUseCase: getIt<GetProfileUseCase>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // TODO: Register other features
  // Kanji
  // ========== KANJI FEATURE ==========
  // Data sources
  getIt.registerLazySingleton<KanjiRemoteDataSource>(
    () => KanjiRemoteDataSourceImpl(dio: getIt<DioClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<KanjiRepository>(
    () => KanjiRepositoryImpl(remoteDataSource: getIt<KanjiRemoteDataSource>()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetAllKanji(getIt<KanjiRepository>()));
  getIt.registerLazySingleton(() => GetKanjiById(getIt<KanjiRepository>()));
  getIt.registerLazySingleton(() => SearchKanji(getIt<KanjiRepository>()));

  // BLoC
  getIt.registerFactory(
    () => KanjiBloc(
      getAllKanji: getIt<GetAllKanji>(),
      getKanjiById: getIt<GetKanjiById>(),
      searchKanji: getIt<SearchKanji>(),
    ),
  );

  // ========== CNN RECOGNITION FEATURE ==========
  // Data sources
  getIt.registerLazySingleton<CnnRecognitionRemoteDataSource>(
    () => CnnRecognitionRemoteDataSourceImpl(dio: getIt<DioClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<CnnRecognitionRepository>(
    () => CnnRecognitionRepositoryImpl(
      remoteDataSource: getIt<CnnRecognitionRemoteDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(
    () => PredictKanji(getIt<CnnRecognitionRepository>()),
  );

  // BLoC
  getIt.registerFactory(
    () => CnnRecognitionBloc(
      predictKanji: getIt<PredictKanji>(),
      repository: getIt<CnnRecognitionRepository>(),
    ),
  );

  // ========== FLASHCARD FEATURE ==========
  // Data sources
  getIt.registerLazySingleton<FlashcardRemoteDataSource>(
    () => FlashcardRemoteDataSourceImpl(dio: getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<FlashcardLocalDataSource>(
    () => FlashcardLocalDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<FlashcardRepository>(
    () => FlashcardRepositoryImpl(
      remoteDataSource: getIt<FlashcardRemoteDataSource>(),
      localDataSource: getIt<FlashcardLocalDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetAllDecks(getIt<FlashcardRepository>()));
  getIt.registerLazySingleton(() => GetDueCards(getIt<FlashcardRepository>()));
  getIt.registerLazySingleton(
    () => UpdateCardReview(getIt<FlashcardRepository>()),
  );
  getIt.registerLazySingleton(
    () => SaveStudyProgress(getIt<FlashcardRepository>()),
  );

  // BLoC
  getIt.registerFactory(
    () => FlashcardBloc(
      getAllDecks: getIt<GetAllDecks>(),
      getDueCards: getIt<GetDueCards>(),
      updateCardReview: getIt<UpdateCardReview>(),
      saveStudyProgress: getIt<SaveStudyProgress>(),
      repository: getIt<FlashcardRepository>(),
    ),
  );

  // ========== QUIZ FEATURE ==========
  // Data sources
  getIt.registerLazySingleton<QuizRemoteDataSource>(
    () => QuizRemoteDataSource(getIt()),
  );

  // Repository
  getIt.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetAllQuizzes(getIt()));
  getIt.registerLazySingleton(() => GetQuizQuestions(getIt()));
  getIt.registerLazySingleton(() => SubmitQuizAnswer(getIt()));
  getIt.registerLazySingleton(() => CompleteQuiz(getIt()));
  getIt.registerLazySingleton(() => GetQuizHistory(getIt()));

  // BLoC
  getIt.registerFactory(
    () => QuizBloc(
      getAllQuizzes: getIt(),
      getQuizQuestions: getIt(),
      submitQuizAnswer: getIt(),
      completeQuiz: getIt(),
      getQuizHistory: getIt(),
      repository: getIt(),
    ),
  );

  // Kanji List
  // Kanji Search
  // Profile
  // Settings
  // User
  // Dashboard
  // Notification
  // Translate
}
