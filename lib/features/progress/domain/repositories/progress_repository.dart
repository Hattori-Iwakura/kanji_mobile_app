import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/achievement.dart';
import '../entities/chart_data.dart';
import '../entities/flashcard_progress.dart';
import '../entities/leaderboard.dart';
import '../entities/progress_overview.dart';
import '../entities/quiz_progress.dart';
import '../entities/streak.dart';
import '../entities/study_time.dart';

/// Repository interface for Progress feature
abstract class ProgressRepository {
  /// Get comprehensive progress overview
  /// GET /progress/overview
  Future<Either<Failure, ProgressOverview>> getProgressOverview();

  /// Get flashcard progress with optional period filter
  /// GET /progress/flashcard?period=7d|30d|90d|1y
  Future<Either<Failure, FlashcardProgress>> getFlashcardProgress({
    String? period,
  });

  /// Get quiz progress with optional period filter
  /// GET /progress/quiz?period=7d|30d|90d|1y
  Future<Either<Failure, QuizProgress>> getQuizProgress({String? period});

  /// Get streak information
  /// GET /progress/streak
  Future<Either<Failure, Streak>> getStreak();

  /// Get leaderboard rankings
  /// GET /progress/leaderboard?period=week|month|all&type=xp|streak&limit=50
  Future<Either<Failure, Leaderboard>> getLeaderboard({
    String? period,
    String? type,
    int? limit,
  });

  /// Get user achievements
  /// GET /progress/achievements
  Future<Either<Failure, AchievementsOverview>> getAchievements();

  /// Get chart data for visualization
  /// GET /progress/chart-data
  Future<Either<Failure, ChartData>> getChartData();

  /// Get study time tracking with optional period filter
  /// GET /progress/study-time?period=7d|30d|90d|1y
  Future<Either<Failure, StudyTime>> getStudyTime({String? period});
}
