import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../services/kanjivg_service.dart';
import '../services/rapidapi_service.dart';
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
import '../../features/kanji/domain/usecases/recognize_kanji.dart';
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
import '../../features/flashcard/data/datasources/flashcard_deck_remote_datasource.dart';
import '../../features/flashcard/data/repositories/flashcard_deck_repository_impl.dart';
import '../../features/flashcard/domain/repositories/flashcard_deck_repository.dart';
import '../../features/flashcard/domain/usecases/get_all_flashcard_decks.dart';
import '../../features/flashcard/domain/usecases/get_flashcard_deck_by_id.dart';
import '../../features/flashcard/domain/usecases/create_flashcard_deck.dart';
import '../../features/flashcard/domain/usecases/update_flashcard_deck.dart';
import '../../features/flashcard/domain/usecases/delete_flashcard_deck.dart';
import '../../features/flashcard/domain/usecases/add_card_to_flashcard_deck.dart';
import '../../features/flashcard/domain/usecases/remove_card_from_flashcard_deck.dart';
import '../../features/flashcard/presentation/bloc/flashcard_deck_bloc.dart';
import '../../features/kanji_list/data/datasources/kanji_list_remote_datasource.dart';
import '../../features/kanji_list/data/repositories/kanji_list_repository_impl.dart';
import '../../features/kanji_list/domain/repositories/kanji_list_repository.dart';
import '../../features/kanji_list/domain/usecases/get_all_kanji_lists.dart';
import '../../features/kanji_list/domain/usecases/get_kanji_list_by_id.dart';
import '../../features/kanji_list/domain/usecases/create_kanji_list.dart';
import '../../features/kanji_list/domain/usecases/update_kanji_list.dart';
import '../../features/kanji_list/domain/usecases/delete_kanji_list.dart';
import '../../features/kanji_list/domain/usecases/add_kanji_to_list.dart';
import '../../features/kanji_list/domain/usecases/remove_kanji_from_list.dart';
import '../../features/kanji_list/domain/usecases/get_kanji_lists_by_jlpt.dart';
import '../../features/kanji_list/presentation/bloc/kanji_list_bloc.dart';
import '../../features/quiz/data/datasources/quiz_remote_datasource.dart';
import '../../features/quiz/data/repositories/quiz_repository_impl.dart';
import '../../features/quiz/domain/repositories/quiz_repository.dart';
import '../../features/quiz/domain/usecases/get_all_quizzes.dart';
import '../../features/quiz/domain/usecases/get_quiz_questions.dart';
import '../../features/quiz/domain/usecases/submit_quiz_answer.dart';
import '../../features/quiz/domain/usecases/complete_quiz.dart';
import '../../features/quiz/domain/usecases/get_quiz_history.dart';
import '../../features/quiz/domain/usecases/add_question.dart';
import '../../features/quiz/domain/usecases/update_question.dart';
import '../../features/quiz/domain/usecases/delete_question.dart';
import '../../features/quiz/presentation/bloc/quiz_bloc.dart';
import '../../features/progress/data/datasources/progress_remote_datasource.dart';
import '../../features/progress/data/repositories/progress_repository_impl.dart';
import '../../features/progress/domain/repositories/progress_repository.dart';
import '../../features/progress/presentation/bloc/progress_bloc.dart';
import '../../features/user_management/data/datasources/user_management_remote_datasource.dart';
import '../../features/user_management/data/repositories/user_management_repository_impl.dart';
import '../../features/user_management/domain/repositories/user_management_repository.dart';
import '../../features/user_management/presentation/bloc/user_management_bloc.dart';
import '../../features/admin_dashboard/data/datasources/admin_dashboard_remote_datasource.dart';
import '../../features/admin_dashboard/data/repositories/admin_dashboard_repository_impl.dart';
import '../../features/admin_dashboard/domain/repositories/admin_dashboard_repository.dart';
import '../../features/admin_dashboard/presentation/bloc/admin_dashboard_bloc.dart';

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

  // Core - Services
  getIt.registerLazySingleton<KanjiVGService>(
    () => KanjiVGService(dio: getIt<DioClient>().dio),
  );
  getIt.registerLazySingleton<RapidAPIService>(
    () => RapidAPIService(dio: getIt<DioClient>().dio),
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
  getIt.registerLazySingleton(() => RecognizeKanji(getIt<KanjiRepository>()));

  // BLoC
  getIt.registerFactory(
    () => KanjiBloc(
      getAllKanji: getIt<GetAllKanji>(),
      getKanjiById: getIt<GetKanjiById>(),
      searchKanji: getIt<SearchKanji>(),
      recognizeKanji: getIt<RecognizeKanji>(),
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

  // BLoC (old flashcard)
  getIt.registerFactory(
    () => FlashcardBloc(
      getAllDecks: getIt<GetAllDecks>(),
      getDueCards: getIt<GetDueCards>(),
      updateCardReview: getIt<UpdateCardReview>(),
      saveStudyProgress: getIt<SaveStudyProgress>(),
      repository: getIt<FlashcardRepository>(),
    ),
  );

  // ========== FLASHCARD DECK FEATURE (NEW BACKEND) ==========
  // Data sources
  getIt.registerLazySingleton<FlashcardDeckRemoteDataSource>(
    () => FlashcardDeckRemoteDataSourceImpl(dio: getIt<DioClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<FlashcardDeckRepository>(
    () => FlashcardDeckRepositoryImpl(
      remoteDataSource: getIt<FlashcardDeckRemoteDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(
    () => GetAllFlashcardDecks(getIt<FlashcardDeckRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetFlashcardDeckById(getIt<FlashcardDeckRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateFlashcardDeck(getIt<FlashcardDeckRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateFlashcardDeck(getIt<FlashcardDeckRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteFlashcardDeck(getIt<FlashcardDeckRepository>()),
  );
  getIt.registerLazySingleton(
    () => AddCardToFlashcardDeck(getIt<FlashcardDeckRepository>()),
  );
  getIt.registerLazySingleton(
    () => RemoveCardFromFlashcardDeck(getIt<FlashcardDeckRepository>()),
  );

  // BLoC
  getIt.registerFactory(
    () => FlashcardDeckBloc(
      getAllDecks: getIt<GetAllFlashcardDecks>(),
      getDeckById: getIt<GetFlashcardDeckById>(),
      createDeck: getIt<CreateFlashcardDeck>(),
      updateDeck: getIt<UpdateFlashcardDeck>(),
      deleteDeck: getIt<DeleteFlashcardDeck>(),
      addCardToDeck: getIt<AddCardToFlashcardDeck>(),
      removeCardFromDeck: getIt<RemoveCardFromFlashcardDeck>(),
    ),
  );

  // ========== KANJI LIST FEATURE ==========
  // Data sources
  getIt.registerLazySingleton<KanjiListRemoteDataSource>(
    () => KanjiListRemoteDataSourceImpl(dio: getIt<DioClient>().dio),
  );

  // Repository
  getIt.registerLazySingleton<KanjiListRepository>(
    () => KanjiListRepositoryImpl(remoteDataSource: getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetAllKanjiLists(getIt()));
  getIt.registerLazySingleton(() => GetKanjiListById(getIt()));
  getIt.registerLazySingleton(() => CreateKanjiList(getIt()));
  getIt.registerLazySingleton(() => UpdateKanjiList(getIt()));
  getIt.registerLazySingleton(() => DeleteKanjiList(getIt()));
  getIt.registerLazySingleton(() => AddKanjiToList(getIt()));
  getIt.registerLazySingleton(() => RemoveKanjiFromList(getIt()));
  getIt.registerLazySingleton(() => GetKanjiListsByJlpt(getIt()));

  // BLoC
  getIt.registerFactory(
    () => KanjiListBloc(
      getAllKanjiLists: getIt(),
      getKanjiListById: getIt(),
      createKanjiList: getIt(),
      updateKanjiList: getIt(),
      deleteKanjiList: getIt(),
      addKanjiToList: getIt(),
      removeKanjiFromList: getIt(),
      getKanjiListsByJlpt: getIt(),
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
  getIt.registerLazySingleton(() => AddQuestion(getIt()));
  getIt.registerLazySingleton(() => UpdateQuestion(getIt()));
  getIt.registerLazySingleton(() => DeleteQuestion(getIt()));

  // BLoC
  getIt.registerFactory(
    () => QuizBloc(
      getAllQuizzes: getIt(),
      getQuizQuestions: getIt(),
      submitQuizAnswer: getIt(),
      completeQuiz: getIt(),
      getQuizHistory: getIt(),
      repository: getIt(),
      addQuestion: getIt(),
      updateQuestion: getIt(),
      deleteQuestion: getIt(),
    ),
  );

  // ========== PROGRESS FEATURE ==========
  // Data sources
  getIt.registerLazySingleton<ProgressRemoteDataSource>(
    () => ProgressRemoteDataSourceImpl(dioClient: getIt()),
  );

  // Repository
  getIt.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(remoteDataSource: getIt()),
  );

  // BLoC
  getIt.registerFactory(() => ProgressBloc(repository: getIt()));

  // ========== USER MANAGEMENT FEATURE ==========
  // Data sources
  getIt.registerLazySingleton<UserManagementRemoteDataSource>(
    () => UserManagementRemoteDataSourceImpl(dioClient: getIt()),
  );

  // Repository
  getIt.registerLazySingleton<UserManagementRepository>(
    () => UserManagementRepositoryImpl(remoteDataSource: getIt()),
  );

  // BLoC
  getIt.registerFactory(() => UserManagementBloc(repository: getIt()));

  // ========== ADMIN DASHBOARD FEATURE ==========
  // Data sources
  getIt.registerLazySingleton<AdminDashboardRemoteDataSource>(
    () => AdminDashboardRemoteDataSourceImpl(dioClient: getIt()),
  );

  // Repository
  getIt.registerLazySingleton<AdminDashboardRepository>(
    () => AdminDashboardRepositoryImpl(remoteDataSource: getIt()),
  );

  // BLoC
  getIt.registerFactory(() => AdminDashboardBloc(repository: getIt()));

  // Kanji List
  // Kanji Search
  // Profile
  // Settings
  // User
  // Dashboard
  // Notification
  // Translate
}
