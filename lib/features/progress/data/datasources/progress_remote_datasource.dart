import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/progress_overview_model.dart';
import '../models/flashcard_progress_model.dart';
import '../models/quiz_progress_model.dart';
import '../models/streak_model.dart';
import '../models/leaderboard_model.dart';
import '../models/achievement_model.dart';
import '../models/chart_data_model.dart';
import '../models/study_time_model.dart';

abstract class ProgressRemoteDataSource {
  Future<ProgressOverviewModel> getProgressOverview();
  Future<FlashcardProgressModel> getFlashcardProgress({String? period});
  Future<QuizProgressModel> getQuizProgress({String? period});
  Future<StreakModel> getStreak();
  Future<LeaderboardModel> getLeaderboard({
    String? period,
    String? type,
    int? limit,
  });
  Future<AchievementsOverviewModel> getAchievements();
  Future<ChartDataModel> getChartData();
  Future<StudyTimeModel> getStudyTime({String? period});
}

class ProgressRemoteDataSourceImpl implements ProgressRemoteDataSource {
  final DioClient dioClient;

  ProgressRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<ProgressOverviewModel> getProgressOverview() async {
    final response = await dioClient.dio.get(ApiEndpoints.progressOverview);
    return ProgressOverviewModel.fromJson(response.data['data']);
  }

  @override
  Future<FlashcardProgressModel> getFlashcardProgress({String? period}) async {
    final queryParams = <String, dynamic>{};
    if (period != null) queryParams['period'] = period;

    final response = await dioClient.dio.get(
      ApiEndpoints.progressFlashcard,
      queryParameters: queryParams,
    );
    return FlashcardProgressModel.fromJson(response.data['data']);
  }

  @override
  Future<QuizProgressModel> getQuizProgress({String? period}) async {
    final queryParams = <String, dynamic>{};
    if (period != null) queryParams['period'] = period;

    final response = await dioClient.dio.get(
      ApiEndpoints.progressQuiz,
      queryParameters: queryParams,
    );
    return QuizProgressModel.fromJson(response.data['data']);
  }

  @override
  Future<StreakModel> getStreak() async {
    final response = await dioClient.dio.get(ApiEndpoints.progressStreak);
    return StreakModel.fromJson(response.data['data']);
  }

  @override
  Future<LeaderboardModel> getLeaderboard({
    String? period,
    String? type,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (period != null) queryParams['period'] = period;
    if (type != null) queryParams['type'] = type;
    if (limit != null) queryParams['limit'] = limit;

    final response = await dioClient.dio.get(
      ApiEndpoints.progressLeaderboard,
      queryParameters: queryParams,
    );
    return LeaderboardModel.fromJson(response.data['data']);
  }

  @override
  Future<AchievementsOverviewModel> getAchievements() async {
    final response = await dioClient.dio.get(ApiEndpoints.progressAchievements);
    return AchievementsOverviewModel.fromJson(response.data['data']);
  }

  @override
  Future<ChartDataModel> getChartData() async {
    final response = await dioClient.dio.get(ApiEndpoints.progressChartData);
    return ChartDataModel.fromJson(response.data['data']);
  }

  @override
  Future<StudyTimeModel> getStudyTime({String? period}) async {
    final queryParams = <String, dynamic>{};
    if (period != null) queryParams['period'] = period;

    final response = await dioClient.dio.get(
      ApiEndpoints.progressStudyTime,
      queryParameters: queryParams,
    );
    return StudyTimeModel.fromJson(response.data['data']);
  }
}
