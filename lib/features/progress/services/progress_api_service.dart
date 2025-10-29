import 'package:kanji_mobile_app/core/network/api_client.dart';
import '../models/progress_models.dart';

class ProgressApiService {
  final ApiClient apiClient;

  ProgressApiService(this.apiClient);

  /// Get comprehensive progress overview
  Future<ProgressOverview> getProgressOverview() async {
    try {
      final response = await apiClient.dio.get('/progress/overview');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ProgressOverview.fromJson(data);
      } else {
        throw Exception('Failed to get progress overview');
      }
    } catch (e) {
      throw Exception('Error getting progress overview: $e');
    }
  }

  /// Get streak information
  Future<StreakInfo> getStreaks() async {
    try {
      final response = await apiClient.dio.get('/progress/streak');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return StreakInfo.fromJson(data);
      } else {
        throw Exception('Failed to get streak info');
      }
    } catch (e) {
      throw Exception('Error getting streak info: $e');
    }
  }

  /// Get leaderboard
  /// [period] - Time period: 'day', 'week', 'month', 'year', 'all'
  /// [type] - Leaderboard type: 'xp', 'streak', 'accuracy', 'cards'
  /// [limit] - Number of entries to return
  Future<Leaderboard> getLeaderboard({
    String period = 'week',
    String type = 'xp',
    int limit = 10,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/progress/leaderboard',
        queryParameters: {'period': period, 'type': type, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return Leaderboard.fromJson(data);
      } else {
        throw Exception('Failed to get leaderboard');
      }
    } catch (e) {
      throw Exception('Error getting leaderboard: $e');
    }
  }

  /// Get achievements
  Future<Achievements> getAchievements() async {
    try {
      final response = await apiClient.dio.get('/progress/achievements');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return Achievements.fromJson(data);
      } else {
        throw Exception('Failed to get achievements');
      }
    } catch (e) {
      throw Exception('Error getting achievements: $e');
    }
  }

  /// Get chart data for progress visualization
  /// [period] - Time period: 'day', 'week', 'month', 'year', 'all'
  /// [points] - Number of data points
  Future<ChartData> getChartData({
    String period = 'week',
    int points = 7,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/progress/chart-data',
        queryParameters: {'period': period, 'points': points},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ChartData.fromJson(data);
      } else {
        throw Exception('Failed to get chart data');
      }
    } catch (e) {
      throw Exception('Error getting chart data: $e');
    }
  }
}
