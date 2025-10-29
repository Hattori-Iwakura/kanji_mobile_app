import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';
import '../../domain/entities/quiz.dart';
import 'add_question_page.dart';
import 'quiz_attempt_page.dart';

class QuizDetailPage extends StatefulWidget {
  final int quizId;

  const QuizDetailPage({super.key, required this.quizId});

  @override
  State<QuizDetailPage> createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  bool _wasModified = false;

  @override
  void initState() {
    super.initState();
    _loadQuizDetail();
  }

  void _loadQuizDetail() {
    context.read<QuizBloc>().add(LoadQuizDetailEvent(widget.quizId));
  }

  void _navigateToAddQuestion() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionPage(quizId: widget.quizId),
      ),
    );
    if (result == true) {
      _wasModified = true;
      _loadQuizDetail();
    }
  }

  void _startQuiz() {
    context.read<QuizBloc>().add(StartQuizAttemptEvent(widget.quizId));
  }

  void _showEditDialog(Quiz quiz) {
    showDialog(
      context: context,
      builder: (context) => _EditQuizDialog(
        quizId: widget.quizId,
        initialTitle: quiz.title,
        initialDescription: quiz.description ?? '',
        onSuccess: _loadQuizDetail,
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B0F14),
        title: const Text('Delete Quiz', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this quiz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<QuizBloc>().add(DeleteQuizEvent(widget.quizId));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteQuestion(int questionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B0F14),
        title: const Text('Delete Question', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this question?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<QuizBloc>().add(
                DeleteQuestionEvent(quizId: widget.quizId, questionId: questionId),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xFF071126),
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF071126), Color(0xFF0B0F14)],
                ),
              ),
            ),
            SafeArea(
              child: BlocConsumer<QuizBloc, QuizState>(
                listener: (context, state) {
                  if (state is QuizError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${state.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is QuizDeleted) {
                    Navigator.pop(context, true);
                  } else if (state is QuestionDeleted) {
                    _wasModified = true;
                    _loadQuizDetail();
                  } else if (state is QuizUpdated) {
                    _wasModified = true;
                  } else if (state is QuizAttemptStarted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizAttemptPage(attempt: state.attempt),
                      ),
                    ).then((_) => _loadQuizDetail());
                  }
                },
                builder: (context, state) {
                  if (state is QuizLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.tealAccent),
                    );
                  }

                  if (state is QuizDetailLoaded) {
                    final quiz = state.quiz;
                    final questions = quiz.questions ?? [];
                    final totalPoints = questions.fold<int>(0, (sum, q) => sum + q.points);

                    return Column(
                      children: [
                        // Custom AppBar
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                                onPressed: () => Navigator.pop(context, _wasModified),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Quiz Details',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              PopupMenuButton(
                                icon: const Icon(Icons.more_vert, color: Colors.white),
                                color: const Color(0xFF0B0F14),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.tealAccent),
                                        SizedBox(width: 8),
                                        Text('Edit Quiz', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete Quiz', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditDialog(quiz);
                                  } else if (value == 'delete') {
                                    _confirmDelete();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        // Quiz Info Card
                        Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.tealAccent.withOpacity(0.15),
                                Colors.white.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        quiz.title,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: quiz.isPublic
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        quiz.isPublic ? 'Public' : 'Private',
                                        style: TextStyle(
                                          color: quiz.isPublic
                                              ? Colors.greenAccent
                                              : Colors.white54,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (quiz.description != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    quiz.description!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _StatChip(
                                      icon: Icons.quiz_outlined,
                                      label: '${questions.length} Questions',
                                    ),
                                    const SizedBox(width: 8),
                                    _StatChip(
                                      icon: Icons.star_rounded,
                                      label: '$totalPoints Points',
                                    ),
                                  ],
                                ),
                                if (questions.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _startQuiz,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.tealAccent,
                                        foregroundColor: const Color(0xFF071126),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: const Icon(Icons.play_arrow, size: 28),
                                      label: const Text(
                                        'Start Quiz',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Questions List Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Text(
                                'Questions',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: _navigateToAddQuestion,
                                icon: const Icon(Icons.add, color: Colors.tealAccent),
                                label: const Text(
                                  'Add',
                                  style: TextStyle(color: Colors.tealAccent),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Questions List
                        Expanded(
                          child: questions.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.quiz_outlined,
                                        size: 80,
                                        color: Colors.white24,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No questions yet',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Add questions to start the quiz',
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: questions.length,
                                  itemBuilder: (context, index) {
                                    final question = questions[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.tealAccent.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${index + 1}',
                                                  style: const TextStyle(
                                                    color: Colors.tealAccent,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    question.questionText,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        size: 14,
                                                        color: Colors.amber.shade400,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${question.points} pts',
                                                        style: const TextStyle(
                                                          color: Colors.white54,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        _getQuestionTypeLabel(question.type),
                                                        style: const TextStyle(
                                                          color: Colors.white54,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                              onPressed: () => _confirmDeleteQuestion(question.id),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.white38),
                        const SizedBox(height: 16),
                        const Text(
                          'Quiz not found',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getQuestionTypeLabel(dynamic type) {
    return type.toString().split('.').last.replaceAll('_', ' ').toUpperCase();
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.tealAccent),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditQuizDialog extends StatefulWidget {
  final int quizId;
  final String initialTitle;
  final String initialDescription;
  final VoidCallback onSuccess;

  const _EditQuizDialog({
    required this.quizId,
    required this.initialTitle,
    required this.initialDescription,
    required this.onSuccess,
  });

  @override
  State<_EditQuizDialog> createState() => _EditQuizDialogState();
}

class _EditQuizDialogState extends State<_EditQuizDialog> {
  late final TextEditingController titleController;
  late final TextEditingController descController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    descController = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is QuizUpdated) {
          Navigator.pop(context);
          widget.onSuccess();
        } else if (state is QuizError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: AlertDialog(
        backgroundColor: const Color(0xFF0B0F14),
        title: const Text('Edit Quiz', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'Enter quiz title',
                hintStyle: TextStyle(color: Colors.white38),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.tealAccent),
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'Enter quiz description (optional)',
                hintStyle: TextStyle(color: Colors.white38),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.tealAccent),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                context.read<QuizBloc>().add(
                  UpdateQuizEvent(
                    quizId: widget.quizId,
                    title: titleController.text.trim(),
                    description: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: const Color(0xFF071126),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
