import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/widgets/custom_back_button.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';

class QuizListPage extends StatelessWidget {
  const QuizListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<QuizBloc>()..add(const GetAllQuizzesEvent()),
      child: const _QuizListView(),
    );
  }
}

class _QuizListView extends StatelessWidget {
  const _QuizListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: const Text('Quizzes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<QuizBloc>().add(const GetAllQuizzesEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state is QuizError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is QuizCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quiz created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload quizzes
            context.read<QuizBloc>().add(const GetAllQuizzesEvent());
          } else if (state is QuizDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quiz deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload quizzes
            context.read<QuizBloc>().add(const GetAllQuizzesEvent());
          }
        },
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuizzesLoaded) {
            if (state.quizzes.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<QuizBloc>().add(const GetAllQuizzesEvent());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = state.quizzes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${quiz.totalQuestions}'),
                      ),
                      title: Text(
                        quiz.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (quiz.description != null &&
                              quiz.description!.isNotEmpty)
                            Text(
                              quiz.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                quiz.isPublic ? Icons.public : Icons.lock,
                                size: 14,
                                color: quiz.isPublic
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                quiz.isPublic ? 'Public' : 'Private',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: quiz.isPublic
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'start',
                            child: Row(
                              children: [
                                Icon(Icons.play_arrow),
                                SizedBox(width: 8),
                                Text('Start Quiz'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'start') {
                            // Navigate to quiz session page
                            Navigator.pushNamed(
                              context,
                              '/quiz-session',
                              arguments: quiz.id,
                            );
                          } else if (value == 'edit') {
                            Navigator.pushNamed(
                              context,
                              '/quiz-edit',
                              arguments: quiz.id,
                            );
                          } else if (value == 'delete') {
                            _showDeleteDialog(context, quiz.id);
                          }
                        },
                      ),
                      onTap: () {
                        // Navigate to quiz detail page
                        Navigator.pushNamed(
                          context,
                          '/quiz-detail',
                          arguments: quiz.id,
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateQuizDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Quiz'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No quizzes yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first quiz to get started',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateQuizDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Quiz'),
          ),
        ],
      ),
    );
  }

  void _showCreateQuizDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create New Quiz'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter quiz title',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Enter quiz description',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                final description = descriptionController.text.trim();
                context.read<QuizBloc>().add(
                  CreateQuizEvent(
                    title: title,
                    description: description.isEmpty ? null : description,
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int quizId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: const Text(
          'Are you sure you want to delete this quiz? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<QuizBloc>().add(DeleteQuizEvent(quizId));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
