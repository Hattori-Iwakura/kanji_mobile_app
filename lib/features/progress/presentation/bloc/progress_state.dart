import 'package:equatable/equatable.dart';

import '../../domain/entities/progress_overview.dart';
import '../../domain/entities/flashcard_progress.dart';
import '../../domain/entities/quiz_progress.dart';
import '../../domain/entities/streak.dart';
import '../../domain/entities/leaderboard.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/chart_data.dart';
import '../../domain/entities/study_time.dart';

abstract class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {
  const ProgressInitial();
}

class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

// Individual loaded states
class ProgressOverviewLoaded extends ProgressState {
  final ProgressOverview overview;

  const ProgressOverviewLoaded(this.overview);

  @override
  List<Object?> get props => [overview];
}

class FlashcardProgressLoaded extends ProgressState {
  final FlashcardProgress progress;

  const FlashcardProgressLoaded(this.progress);

  @override
  List<Object?> get props => [progress];
}

class QuizProgressLoaded extends ProgressState {
  final QuizProgress progress;

  const QuizProgressLoaded(this.progress);

  @override
  List<Object?> get props => [progress];
}

class StreakLoaded extends ProgressState {
  final Streak streak;

  const StreakLoaded(this.streak);

  @override
  List<Object?> get props => [streak];
}

class LeaderboardLoaded extends ProgressState {
  final Leaderboard leaderboard;

  const LeaderboardLoaded(this.leaderboard);

  @override
  List<Object?> get props => [leaderboard];
}

class AchievementsLoaded extends ProgressState {
  final AchievementsOverview achievements;

  const AchievementsLoaded(this.achievements);

  @override
  List<Object?> get props => [achievements];
}

class ChartDataLoaded extends ProgressState {
  final ChartData chartData;

  const ChartDataLoaded(this.chartData);

  @override
  List<Object?> get props => [chartData];
}

class StudyTimeLoaded extends ProgressState {
  final StudyTime studyTime;

  const StudyTimeLoaded(this.studyTime);

  @override
  List<Object?> get props => [studyTime];
}

// Combined state for overview page
class ProgressDataLoaded extends ProgressState {
  final ProgressOverview? overview;
  final Streak? streak;
  final FlashcardProgress? flashcardProgress;
  final QuizProgress? quizProgress;
  final StudyTime? studyTime;

  const ProgressDataLoaded({
    this.overview,
    this.streak,
    this.flashcardProgress,
    this.quizProgress,
    this.studyTime,
  });

  @override
  List<Object?> get props => [
    overview,
    streak,
    flashcardProgress,
    quizProgress,
    studyTime,
  ];

  ProgressDataLoaded copyWith({
    ProgressOverview? overview,
    Streak? streak,
    FlashcardProgress? flashcardProgress,
    QuizProgress? quizProgress,
    StudyTime? studyTime,
  }) {
    return ProgressDataLoaded(
      overview: overview ?? this.overview,
      streak: streak ?? this.streak,
      flashcardProgress: flashcardProgress ?? this.flashcardProgress,
      quizProgress: quizProgress ?? this.quizProgress,
      studyTime: studyTime ?? this.studyTime,
    );
  }
}

class ProgressError extends ProgressState {
  final String message;

  const ProgressError(this.message);

  @override
  List<Object?> get props => [message];
}
