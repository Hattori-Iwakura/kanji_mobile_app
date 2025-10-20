import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

// Core services
import 'core/network/api_client.dart';
import 'core/services/jisho_service.dart';
import 'core/services/kanjivg_service.dart';
import 'core/services/kanji_alive_service.dart';

// ==================== Features - Auth (Clean Architecture) ====================
// Domain
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/check_auth_usecase.dart';
import 'features/auth/domain/usecases/get_profile_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
// Data
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
// Presentation
import 'features/auth/presentation/bloc/auth_bloc.dart';

// ==================== Features - Flashcard (Clean Architecture) ====================
// Domain
import 'features/flashcard/domain/repositories/flashcard_repository.dart';
import 'features/flashcard/domain/usecases/add_card_usecase.dart';
import 'features/flashcard/domain/usecases/approve_publish_request_usecase.dart'
    as flashcard_approve;
import 'features/flashcard/domain/usecases/create_deck_usecase.dart';
import 'features/flashcard/domain/usecases/delete_deck_usecase.dart';
import 'features/flashcard/domain/usecases/get_all_decks_usecase.dart';
import 'features/flashcard/domain/usecases/get_deck_by_id_usecase.dart';
import 'features/flashcard/domain/usecases/get_publish_requests_usecase.dart'
    as flashcard_publish_requests;
import 'features/flashcard/domain/usecases/reject_publish_request_usecase.dart'
    as flashcard_reject;
import 'features/flashcard/domain/usecases/remove_card_usecase.dart';
import 'features/flashcard/domain/usecases/request_publish_usecase.dart';
import 'features/flashcard/domain/usecases/update_deck_usecase.dart';
// Data
import 'features/flashcard/data/datasources/flashcard_remote_datasource.dart';
import 'features/flashcard/data/repositories/flashcard_repository_impl.dart';
// Presentation
import 'features/flashcard/presentation/bloc/flashcard_bloc.dart';

// ==================== Features - Kanji (Clean Architecture) ====================
// Domain
import 'features/kanji/domain/repositories/kanji_repository.dart';
import 'features/kanji/domain/usecases/create_kanji_usecase.dart';
import 'features/kanji/domain/usecases/delete_kanji_usecase.dart';
import 'features/kanji/domain/usecases/get_kanji_list_usecase.dart';
import 'features/kanji/domain/usecases/get_kanji_by_character_usecase.dart';
import 'features/kanji/domain/usecases/get_kanji_by_id_usecase.dart';
import 'features/kanji/domain/usecases/update_kanji_usecase.dart';
// Data
import 'features/kanji/data/datasources/kanji_remote_datasource.dart';
import 'features/kanji/data/repositories/kanji_repository_impl.dart';
// Presentation
import 'features/kanji/presentation/bloc/kanji_bloc.dart';

// ==================== Features - Kanji List (Clean Architecture) ====================
// Domain
import 'features/kanji_list/domain/repositories/kanji_list_repository.dart';
import 'features/kanji_list/domain/usecases/add_kanji_to_list_usecase.dart';
import 'features/kanji_list/domain/usecases/approve_publish_request_usecase.dart'
    as kanji_list_approve;
import 'features/kanji_list/domain/usecases/create_list_usecase.dart';
import 'features/kanji_list/domain/usecases/delete_list_usecase.dart';
import 'features/kanji_list/domain/usecases/get_all_lists_usecase.dart';
import 'features/kanji_list/domain/usecases/get_list_by_id_usecase.dart';
import 'features/kanji_list/domain/usecases/get_publish_requests_usecase.dart'
    as kanji_list_publish_requests;
import 'features/kanji_list/domain/usecases/reject_publish_request_usecase.dart'
    as kanji_list_reject;
import 'features/kanji_list/domain/usecases/remove_kanji_from_list_usecase.dart';
import 'features/kanji_list/domain/usecases/request_publish_list_usecase.dart';
import 'features/kanji_list/domain/usecases/update_list_usecase.dart';
// Data
import 'features/kanji_list/data/datasources/kanji_list_remote_datasource.dart';
import 'features/kanji_list/data/repositories/kanji_list_repository_impl.dart';
// Presentation
import 'features/kanji_list/presentation/bloc/kanji_list_bloc.dart';

// ==================== Features - Quiz (Clean Architecture) ====================
// Domain
import 'features/quiz/domain/repositories/quiz_repository.dart';
import 'features/quiz/domain/usecases/add_question_usecase.dart';
import 'features/quiz/domain/usecases/approve_publish_request_usecase.dart'
    as quiz_approve;
import 'features/quiz/domain/usecases/create_quiz_usecase.dart';
import 'features/quiz/domain/usecases/delete_question_usecase.dart';
import 'features/quiz/domain/usecases/delete_quiz_usecase.dart';
import 'features/quiz/domain/usecases/get_all_quizzes_usecase.dart';
import 'features/quiz/domain/usecases/get_pending_publish_requests_usecase.dart';
import 'features/quiz/domain/usecases/get_quiz_attempt_details_usecase.dart';
import 'features/quiz/domain/usecases/get_quiz_attempts_usecase.dart';
import 'features/quiz/domain/usecases/get_quiz_by_id_usecase.dart';
import 'features/quiz/domain/usecases/reject_publish_request_usecase.dart'
    as quiz_reject;
import 'features/quiz/domain/usecases/reorder_questions_usecase.dart';
import 'features/quiz/domain/usecases/request_publish_quiz_usecase.dart';
import 'features/quiz/domain/usecases/start_quiz_attempt_usecase.dart';
import 'features/quiz/domain/usecases/submit_quiz_attempt_usecase.dart';
import 'features/quiz/domain/usecases/update_question_usecase.dart';
import 'features/quiz/domain/usecases/update_quiz_usecase.dart';
// Data
import 'features/quiz/data/datasources/quiz_remote_datasource.dart';
import 'features/quiz/data/repositories/quiz_repository_impl.dart';
// Presentation
import 'features/quiz/presentation/bloc/quiz_bloc.dart';

// ==================== Features - Kanji Recognition (Clean Architecture - preserved) ====================
import 'features/kanji_recognition/data/datasources/kanji_recognition_remote_datasource.dart';
import 'features/kanji_recognition/data/repositories/kanji_recognition_repository_impl.dart';
import 'features/kanji_recognition/domain/repositories/kanji_recognition_repository.dart';
import 'features/kanji_recognition/domain/usecases/recognize_kanji.dart';
import 'features/kanji_recognition/presentation/bloc/kanji_recognition_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==================== Core ====================

  // Dio instance
  sl.registerLazySingleton<Dio>(() => Dio());

  // API Client
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // External Services
  sl.registerLazySingleton<JishoService>(() => JishoService(sl<Dio>()));
  sl.registerLazySingleton<KanjiVGService>(() => KanjiVGService(sl<Dio>()));
  sl.registerLazySingleton<KanjiAliveService>(
    () => KanjiAliveService(sl<Dio>()),
  );

  // ==================== Features - Auth (Clean Architecture) ====================

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      getProfileUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      apiClient: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  // ==================== Features - Kanji (Clean Architecture) ====================

  // BLoC
  sl.registerFactory(
    () => KanjiBloc(
      getKanjiListUseCase: sl(),
      getKanjiByIdUseCase: sl(),
      getKanjiByCharacterUseCase: sl(),
      createKanjiUseCase: sl(),
      updateKanjiUseCase: sl(),
      deleteKanjiUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetKanjiListUseCase(sl()));
  sl.registerLazySingleton(() => GetKanjiByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetKanjiByCharacterUseCase(sl()));
  sl.registerLazySingleton(() => CreateKanjiUseCase(sl()));
  sl.registerLazySingleton(() => UpdateKanjiUseCase(sl()));
  sl.registerLazySingleton(() => DeleteKanjiUseCase(sl()));

  // Repository
  sl.registerLazySingleton<KanjiRepository>(
    () => KanjiRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<KanjiRemoteDataSource>(
    () => KanjiRemoteDataSourceImpl(sl()),
  );

  // ==================== Features - Flashcard (Clean Architecture) ====================

  // BLoC
  sl.registerFactory(
    () => FlashcardBloc(
      getAllDecksUseCase: sl(),
      getDeckByIdUseCase: sl(),
      createDeckUseCase: sl(),
      updateDeckUseCase: sl(),
      deleteDeckUseCase: sl(),
      addCardUseCase: sl(),
      removeCardUseCase: sl(),
      requestPublishUseCase: sl(),
      getPublishRequestsUseCase: sl(),
      approvePublishRequestUseCase: sl(),
      rejectPublishRequestUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllDecksUseCase(sl()));
  sl.registerLazySingleton(() => GetDeckByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateDeckUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDeckUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDeckUseCase(sl()));
  sl.registerLazySingleton(() => AddCardUseCase(sl()));
  sl.registerLazySingleton(() => RemoveCardUseCase(sl()));
  sl.registerLazySingleton(() => RequestPublishUseCase(sl()));
  sl.registerLazySingleton(
    () => flashcard_publish_requests.GetPublishRequestsUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => flashcard_approve.ApprovePublishRequestUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => flashcard_reject.RejectPublishRequestUseCase(sl()),
  );

  // Repository
  sl.registerLazySingleton<FlashcardRepository>(
    () => FlashcardRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<FlashcardRemoteDataSource>(
    () => FlashcardRemoteDataSourceImpl(sl()),
  );

  // ==================== Features - Kanji List (Clean Architecture) ====================

  // BLoC
  sl.registerFactory(
    () => KanjiListBloc(
      getAllListsUseCase: sl(),
      getListByIdUseCase: sl(),
      createListUseCase: sl(),
      updateListUseCase: sl(),
      deleteListUseCase: sl(),
      addKanjiToListUseCase: sl(),
      removeKanjiFromListUseCase: sl(),
      requestPublishListUseCase: sl(),
      getPublishRequestsUseCase: sl(),
      approvePublishRequestUseCase: sl(),
      rejectPublishRequestUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllListsUseCase(sl()));
  sl.registerLazySingleton(() => GetListByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateListUseCase(sl()));
  sl.registerLazySingleton(() => UpdateListUseCase(sl()));
  sl.registerLazySingleton(() => DeleteListUseCase(sl()));
  sl.registerLazySingleton(() => AddKanjiToListUseCase(sl()));
  sl.registerLazySingleton(() => RemoveKanjiFromListUseCase(sl()));
  sl.registerLazySingleton(() => RequestPublishListUseCase(sl()));
  sl.registerLazySingleton(
    () => kanji_list_publish_requests.GetPublishRequestsUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => kanji_list_approve.ApprovePublishRequestUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => kanji_list_reject.RejectPublishRequestUseCase(sl()),
  );

  // Repository
  sl.registerLazySingleton<KanjiListRepository>(
    () => KanjiListRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<KanjiListRemoteDataSource>(
    () => KanjiListRemoteDataSourceImpl(sl()),
  );

  // ==================== Features - Quiz (Clean Architecture) ====================

  // BLoC
  sl.registerFactory(
    () => QuizBloc(
      getAllQuizzesUseCase: sl(),
      getQuizByIdUseCase: sl(),
      createQuizUseCase: sl(),
      updateQuizUseCase: sl(),
      deleteQuizUseCase: sl(),
      addQuestionUseCase: sl(),
      updateQuestionUseCase: sl(),
      deleteQuestionUseCase: sl(),
      reorderQuestionsUseCase: sl(),
      startQuizAttemptUseCase: sl(),
      submitQuizAttemptUseCase: sl(),
      getQuizAttemptsUseCase: sl(),
      getQuizAttemptDetailsUseCase: sl(),
      requestPublishQuizUseCase: sl(),
      getPendingPublishRequestsUseCase: sl(),
      approvePublishRequestUseCase: sl(),
      rejectPublishRequestUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllQuizzesUseCase(sl()));
  sl.registerLazySingleton(() => GetQuizByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateQuizUseCase(sl()));
  sl.registerLazySingleton(() => UpdateQuizUseCase(sl()));
  sl.registerLazySingleton(() => DeleteQuizUseCase(sl()));
  sl.registerLazySingleton(() => AddQuestionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateQuestionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteQuestionUseCase(sl()));
  sl.registerLazySingleton(() => ReorderQuestionsUseCase(sl()));
  sl.registerLazySingleton(() => StartQuizAttemptUseCase(sl()));
  sl.registerLazySingleton(() => SubmitQuizAttemptUseCase(sl()));
  sl.registerLazySingleton(() => GetQuizAttemptsUseCase(sl()));
  sl.registerLazySingleton(() => GetQuizAttemptDetailsUseCase(sl()));
  sl.registerLazySingleton(() => RequestPublishQuizUseCase(sl()));
  sl.registerLazySingleton(() => GetPendingPublishRequestsUseCase(sl()));
  sl.registerLazySingleton(
    () => quiz_approve.ApprovePublishRequestUseCase(sl()),
  );
  sl.registerLazySingleton(() => quiz_reject.RejectPublishRequestUseCase(sl()));

  // Repository
  sl.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<QuizRemoteDataSource>(
    () => QuizRemoteDataSourceImpl(dio: sl()),
  );

  // ==================== Features - Kanji Recognition ====================

  // BLoC
  sl.registerFactory(() => KanjiRecognitionBloc(recognizeKanji: sl()));

  // Use cases
  sl.registerLazySingleton(() => RecognizeKanji(sl()));

  // Repository
  sl.registerLazySingleton<KanjiRecognitionRepository>(
    () => KanjiRecognitionRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<KanjiRecognitionRemoteDataSource>(
    () => KanjiRecognitionRemoteDataSourceImpl(apiClient: sl()),
  );
}
