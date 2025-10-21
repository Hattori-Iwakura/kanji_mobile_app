import '../../../../core/network/api_client.dart';

abstract class AdminRemoteDataSource {
  Future<Map<String, dynamic>> getDashboardStats();
  Future<List<dynamic>> getPendingPublishRequests();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Fetch statistics from multiple endpoints
      final usersResponse = await apiClient.get('/admin/users');
      final kanjiResponse = await apiClient.get('/kanji');
      final quizzesResponse = await apiClient.get('/quizzes');

      // Extract counts from responses
      final users = usersResponse['data'] as List? ?? [];
      final kanji = kanjiResponse['data'] as List? ?? [];
      final quizzes = quizzesResponse['data'] as List? ?? [];

      // Calculate statistics
      return {
        'totalUsers': users.length,
        'totalKanji': kanji.length,
        'totalQuizzes': quizzes.length,
        'activeUsers': users.where((u) => u['isActive'] == true).length,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  @override
  Future<List<dynamic>> getPendingPublishRequests() async {
    try {
      final response = await apiClient.get('/quizzes/admin/publish-requests');
      return response['data'] as List? ?? [];
    } catch (e) {
      throw Exception('Failed to fetch pending publish requests: $e');
    }
  }
}
