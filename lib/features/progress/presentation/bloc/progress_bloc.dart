import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/progress_repository.dart';
import 'progress_event.dart';
import 'progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final ProgressRepository repository;

  ProgressBloc({required this.repository}) : super(const ProgressInitial()) {
    on<LoadProgressOverview>(_onLoadProgressOverview);
    on<LoadFlashcardProgress>(_onLoadFlashcardProgress);
    on<LoadQuizProgress>(_onLoadQuizProgress);
    on<LoadStreak>(_onLoadStreak);
    on<LoadLeaderboard>(_onLoadLeaderboard);
    on<LoadAchievements>(_onLoadAchievements);
    on<LoadChartData>(_onLoadChartData);
    on<LoadStudyTime>(_onLoadStudyTime);
    on<RefreshProgress>(_onRefreshProgress);
  }

  Future<void> _onLoadProgressOverview(
    LoadProgressOverview event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoading());

    final result = await repository.getProgressOverview();

    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (overview) => emit(ProgressOverviewLoaded(overview)),
    );
  }

  Future<void> _onLoadFlashcardProgress(
    LoadFlashcardProgress event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoading());

    final result = await repository.getFlashcardProgress(period: event.period);

    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (progress) => emit(FlashcardProgressLoaded(progress)),
    );
  }

  Future<void> _onLoadQuizProgress(
    LoadQuizProgress event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoading());

    final result = await repository.getQuizProgress(period: event.period);

    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (progress) => emit(QuizProgressLoaded(progress)),
    );
  }

  Future<void> _onLoadStreak(
    LoadStreak event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoading());

    final result = await repository.getStreak();

    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (streak) => emit(StreakLoaded(streak)),
    );
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoading());

    final result = await repository.getLeaderboard(
      period: event.period,
      type: event.type,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (leaderboard) => emit(LeaderboardLoaded(leaderboard)),
    );
  }

  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoading());

    final result = await repository.getAchievements();

    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (achievements) => emit(AchievementsLoaded(achievements)),
    );
  }

  Future<void> _onLoadChartData(
    LoadChartData event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoading());

    final result = await repository.getChartData();

    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (chartData) => emit(ChartDataLoaded(chartData)),
    );
  }

  Future<void> _onLoadStudyTime(
    LoadStudyTime event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoading());

    final result = await repository.getStudyTime(period: event.period);

    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (studyTime) => emit(StudyTimeLoaded(studyTime)),
    );
  }

  Future<void> _onRefreshProgress(
    RefreshProgress event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoading());

    // Load all data for overview page
    final overviewResult = await repository.getProgressOverview();
    final streakResult = await repository.getStreak();
    final flashcardResult = await repository.getFlashcardProgress();
    final quizResult = await repository.getQuizProgress();
    final studyTimeResult = await repository.getStudyTime();

    // Check if any failed
    if (overviewResult.isLeft()) {
      emit(
        ProgressError(
          overviewResult.fold((l) => l.message, (r) => 'Unknown error'),
        ),
      );
      return;
    }

    // Emit combined state
    emit(
      ProgressDataLoaded(
        overview: overviewResult.getOrElse(() => throw Exception()),
        streak: streakResult.getOrElse(() => null),
        flashcardProgress: flashcardResult.getOrElse(() => null),
        quizProgress: quizResult.getOrElse(() => null),
        studyTime: studyTimeResult.getOrElse(() => null),
      ),
    );
  }
}
