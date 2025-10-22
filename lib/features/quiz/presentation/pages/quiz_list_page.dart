import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/quiz.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';
import '../widgets/quiz_card.dart';
import 'quiz_taking_page.dart';

/// Page displaying all available quizzes
class QuizListPage extends StatelessWidget {
  const QuizListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuizBloc>()..add(LoadQuizzesEvent()),
      child: const _QuizListView(),
    );
  }
}

class _QuizListView extends StatelessWidget {
  const _QuizListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Quizzes', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              // TODO: Navigate to quiz history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quiz History - Coming Soon'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Quiz History',
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
          }
        },
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (state is QuizzesLoaded) {
            if (!state.hasQuizzes) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<QuizBloc>().add(LoadQuizzesEvent());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  Text(
                    'Test Your Knowledge',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a quiz to challenge yourself',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Easy Quizzes
                  if (state.getByDifficulty('EASY').isNotEmpty) ...[
                    _buildDifficultySection(
                      'Easy',
                      state.getByDifficulty('EASY'),
                      Colors.green,
                      context,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Medium Quizzes
                  if (state.getByDifficulty('MEDIUM').isNotEmpty) ...[
                    _buildDifficultySection(
                      'Medium',
                      state.getByDifficulty('MEDIUM'),
                      Colors.orange,
                      context,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Hard Quizzes
                  if (state.getByDifficulty('HARD').isNotEmpty) ...[
                    _buildDifficultySection(
                      'Hard',
                      state.getByDifficulty('HARD'),
                      Colors.red,
                      context,
                    ),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Quizzes Available',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Check back later for new quizzes!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySection(
    String difficulty,
    List<Quiz> quizzes,
    Color color,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              difficulty,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${quizzes.length} quiz${quizzes.length != 1 ? 'zes' : ''}',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...quizzes.map(
          (quiz) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: QuizCard(quiz: quiz, onTap: () => _startQuiz(context, quiz)),
          ),
        ),
      ],
    );
  }

  void _startQuiz(BuildContext context, Quiz quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizTakingPage(quiz: quiz)),
    );
  }
}
