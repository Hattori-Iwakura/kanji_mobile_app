import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../injection_container.dart' as di;
import '../../../quiz/models/quiz.dart';

class AdminQuizzesPage extends StatefulWidget {
  const AdminQuizzesPage({super.key});

  @override
  State<AdminQuizzesPage> createState() => _AdminQuizzesPageState();
}

class _AdminQuizzesPageState extends State<AdminQuizzesPage> {
  final ApiClient _apiClient = di.sl<ApiClient>();

  List<Quiz> _quizzes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiClient.get('/quizzes');
      final data = response.data['data'] ?? response.data;

      List<Quiz> quizzes;
      if (data is Map && data['data'] is List) {
        quizzes = (data['data'] as List)
            .map((q) => Quiz.fromJson(q as Map<String, dynamic>))
            .toList();
      } else if (data is List) {
        quizzes = data
            .map((q) => Quiz.fromJson(q as Map<String, dynamic>))
            .toList();
      } else {
        quizzes = [];
      }

      setState(() {
        _quizzes = quizzes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load quizzes: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Management'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuizzes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _loadQuizzes, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_quizzes.isEmpty) {
      return const Center(child: Text('No quizzes found'));
    }

    return RefreshIndicator(
      onRefresh: _loadQuizzes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _quizzes.length,
        itemBuilder: (context, index) {
          final quiz = _quizzes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: quiz.isPublic
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  quiz.isPublic ? Icons.public : Icons.lock,
                  color: quiz.isPublic ? Colors.green : Colors.grey,
                ),
              ),
              title: Text(
                quiz.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${quiz.questions?.length ?? 0} questions'),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'publish',
                    child: Row(
                      children: [
                        Icon(
                          quiz.isPublic ? Icons.lock : Icons.public,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(quiz.isPublic ? 'Make Private' : 'Publish'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'publish') {
                    _togglePublish(quiz);
                  } else if (value == 'delete') {
                    _deleteQuiz(quiz.id);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _togglePublish(Quiz quiz) async {
    try {
      await _apiClient.put('/quizzes/${quiz.id}', {'isPublic': !quiz.isPublic});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              quiz.isPublic
                  ? 'Quiz is now private'
                  : 'Quiz published successfully',
            ),
          ),
        );
        _loadQuizzes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update quiz: $e')));
      }
    }
  }

  Future<void> _deleteQuiz(int quizId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: const Text('Are you sure you want to delete this quiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _apiClient.delete('/quizzes/$quizId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz deleted successfully')),
        );
        _loadQuizzes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete quiz: $e')));
      }
    }
  }
}
