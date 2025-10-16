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
import 'features/kanji/domain/usecases/search_kanji.dart';
import 'features/kanji/domain/usecases/get_kanji_detail.dart';
import 'features/kanji/domain/usecases/get_kanji_examples.dart';
import 'features/kanji/domain/usecases/kanji_list_usecases.dart';
import 'features/kanji/domain/usecases/kanji_progress_usecases.dart';
import 'features/kanji/presentation/bloc/kanji_bloc.dart';
import 'features/kanji/presentation/bloc/search/kanji_search_bloc.dart';
import 'features/kanji/presentation/bloc/detail/kanji_detail_bloc.dart';
import 'features/kanji/presentation/bloc/lists/kanji_lists_bloc.dart';
import 'features/kanji/presentation/bloc/progress/kanji_progress_bloc.dart';
import 'features/kanji_recognition/data/datasources/kanji_recognition_remote_datasource.dart';
import 'features/kanji_recognition/data/repositories/kanji_recognition_repository_impl.dart';
import 'features/kanji_recognition/domain/repositories/kanji_recognition_repository.dart';
import 'features/kanji_recognition/domain/usecases/recognize_kanji.dart';
import 'features/kanji_recognition/presentation/bloc/kanji_recognition_bloc.dart';
import 'features/flashcard/data/datasources/flashcard_remote_data_source.dart';
import 'features/flashcard/data/repositories/flashcard_repository_impl.dart';
import 'features/flashcard/domain/repositories/flashcard_repository.dart';
import 'features/flashcard/domain/usecases/create_deck.dart';
import 'features/flashcard/domain/usecases/get_user_decks.dart';
import 'features/flashcard/domain/usecases/get_deck_by_id.dart';
import 'features/flashcard/domain/usecases/start_study_session.dart';
import 'features/flashcard/domain/usecases/review_card.dart';
import 'features/flashcard/domain/usecases/pause_study_session.dart';
import 'features/flashcard/domain/usecases/resume_study_session.dart';
import 'features/flashcard/domain/usecases/get_active_sessions.dart';
import 'features/flashcard/domain/usecases/get_session_detail.dart';
import 'features/flashcard/domain/usecases/add_card_to_deck.dart';
import 'features/flashcard/domain/usecases/delete_card.dart';
import 'features/flashcard/domain/usecases/delete_deck.dart';
import 'features/flashcard/domain/usecases/update_deck.dart';
import 'features/flashcard/domain/usecases/bulk_add_cards.dart';
import 'features/flashcard/domain/usecases/reorder_cards.dart';
import 'features/flashcard/domain/usecases/get_card_detail.dart';
import 'features/flashcard/domain/usecases/get_flashcard_stats.dart';
import 'features/flashcard/presentation/bloc/flashcard_deck_bloc.dart';
import 'features/flashcard/presentation/bloc/study_session_bloc.dart';
import 'features/flashcard/presentation/bloc/deck_detail_bloc.dart';
import 'features/flashcard/presentation/bloc/card_detail_cubit.dart';
import 'features/flashcard/presentation/bloc/flashcard_stats_cubit.dart';
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

  // New BLoCs
  sl.registerFactory(() => KanjiSearchBloc(searchKanji: sl()));

  sl.registerFactory(
    () => KanjiDetailBloc(getKanjiDetail: sl(), getKanjiExamples: sl()),
  );

  sl.registerFactory(
    () => KanjiListsBloc(
      createKanjiList: sl(),
      getUserLists: sl(),
      getListDetail: sl(),
      addKanjiToList: sl(),
      removeKanjiFromList: sl(),
      deleteKanjiList: sl(),
      reorderKanjiList: sl(),
    ),
  );

  sl.registerFactory(
    () => KanjiProgressBloc(
      getProgressSummary: sl(),
      getKanjiProgress: sl(),
      updateKanjiProgress: sl(),
      recordKanjiReview: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllKanji(sl()));
  sl.registerLazySingleton(() => GetKanjiById(sl()));
  sl.registerLazySingleton(() => GetKanjiByCharacter(sl()));
  sl.registerLazySingleton(() => CreateKanji(sl()));
  sl.registerLazySingleton(() => UpdateKanji(sl()));
  sl.registerLazySingleton(() => DeleteKanji(sl()));

  // New use cases - Search & Detail
  sl.registerLazySingleton(() => SearchKanjiUseCase(sl()));
  sl.registerLazySingleton(() => GetKanjiDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetKanjiExamplesUseCase(sl()));

  // New use cases - Lists
  sl.registerLazySingleton(() => CreateKanjiListUseCase(sl()));
  sl.registerLazySingleton(() => GetUserListsUseCase(sl()));
  sl.registerLazySingleton(() => GetListDetailUseCase(sl()));
  sl.registerLazySingleton(() => AddKanjiToListUseCase(sl()));
  sl.registerLazySingleton(() => RemoveKanjiFromListUseCase(sl()));
  sl.registerLazySingleton(() => DeleteKanjiListUseCase(sl()));
  sl.registerLazySingleton(() => ReorderKanjiListUseCase(sl()));

  // New use cases - Progress
  sl.registerLazySingleton(() => GetProgressSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetKanjiProgressUseCase(sl()));
  sl.registerLazySingleton(() => UpdateKanjiProgressUseCase(sl()));
  sl.registerLazySingleton(() => RecordKanjiReviewUseCase(sl()));

  // Repository
  sl.registerLazySingleton<KanjiRepository>(
    () => KanjiRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<KanjiRemoteDataSource>(
    () => KanjiRemoteDataSourceImpl(apiClient: sl()),
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

  // ==================== Features - Flashcard ====================

  // BLoCs
  sl.registerFactory(
    () => FlashcardDeckBloc(
      getUserDecks: sl(),
      createDeck: sl(),
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => StudySessionBloc(
      startStudySession: sl(),
      reviewCard: sl(),
      repository: sl(),
      pauseSession: sl(),
      resumeSession: sl(),
      getActiveSessions: sl(),
      getSessionDetail: sl(),
    ),
  );

  sl.registerFactory(
    () => DeckDetailBloc(
      getDeckById: sl(),
      addCardToDeck: sl(),
      deleteCard: sl(),
      updateDeck: sl(),
      bulkAddCards: sl(),
      reorderCards: sl(),
    ),
  );

  sl.registerFactory(() => CardDetailCubit(getCardDetail: sl()));

  sl.registerFactory(() => FlashcardStatsCubit(getFlashcardStats: sl()));

  // Use cases
  sl.registerLazySingleton(() => CreateDeck(sl()));
  sl.registerLazySingleton(() => GetUserDecks(sl()));
  sl.registerLazySingleton(() => GetDeckById(sl()));
  sl.registerLazySingleton(() => StartStudySession(sl()));
  sl.registerLazySingleton(() => ReviewCard(sl()));
  sl.registerLazySingleton(() => PauseStudySession(sl()));
  sl.registerLazySingleton(() => ResumeStudySession(sl()));
  sl.registerLazySingleton(() => GetActiveSessions(sl()));
  sl.registerLazySingleton(() => GetSessionDetail(sl()));
  sl.registerLazySingleton(() => AddCardToDeck(sl()));
  sl.registerLazySingleton(() => DeleteCard(sl()));
  sl.registerLazySingleton(() => DeleteDeck(sl()));
  sl.registerLazySingleton(() => UpdateDeck(sl()));
  sl.registerLazySingleton(() => BulkAddCards(sl()));
  sl.registerLazySingleton(() => ReorderCards(sl()));
  sl.registerLazySingleton(() => GetCardDetail(sl()));
  sl.registerLazySingleton(() => GetFlashcardStats(sl()));

  // Repository
  sl.registerLazySingleton<FlashcardRepository>(
    () => FlashcardRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<FlashcardRemoteDataSource>(
    () => FlashcardRemoteDataSourceImpl(apiClient: sl()),
  );

  // ==================== Core ====================

  // API Client
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
}
