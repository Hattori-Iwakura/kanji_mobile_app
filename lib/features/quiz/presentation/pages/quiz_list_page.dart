import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_enums.dart';
import '../bloc/quiz_list/quiz_list_bloc.dart';
import '../bloc/quiz_list/quiz_list_event.dart';
import '../bloc/quiz_list/quiz_list_state.dart';

class QuizListPage extends StatelessWidget {
  const QuizListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<QuizListBloc>()..add(const LoadQuizzesEvent(publicOnly: true)),
      child: const QuizListView(),
    );
  }
}

class QuizListView extends StatelessWidget {
  const QuizListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<QuizListBloc>().add(RefreshQuizzesEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<QuizListBloc, QuizListState>(
        builder: (context, state) {
          if (state is QuizListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuizListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<QuizListBloc>().add(
                        const LoadQuizzesEvent(publicOnly: true),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is QuizListLoaded) {
            if (state.quizzes.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No quizzes available'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.quizzes.length,
              itemBuilder: (context, index) {
                return QuizCard(quiz: state.quizzes[index]);
              },
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to CreateQuizPage
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create Quiz - Coming soon!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class QuizCard extends StatelessWidget {
  final Quiz quiz;

  const QuizCard({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to QuizDetailPage
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening quiz: ${quiz.title}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      quiz.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _buildDifficultyBadge(context),
                ],
              ),
              if (quiz.description != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  quiz.description!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.questionCount} questions',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.stars, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.totalPoints} points',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.attemptsCount} attempts',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              if (quiz.tags.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: quiz.tags
                      .map(
                        (tag) => Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 12),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(BuildContext context) {
    Color color;
    switch (quiz.difficulty) {
      case QuizDifficulty.beginner:
        color = Colors.green;
        break;
      case QuizDifficulty.intermediate:
        color = Colors.blue;
        break;
      case QuizDifficulty.advanced:
        color = Colors.orange;
        break;
      case QuizDifficulty.expert:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        quiz.difficulty.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
