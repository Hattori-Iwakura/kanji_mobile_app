import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';

/// Quiz session with answer protection
/// Users CANNOT see correct answers until quiz is completed and submitted
class QuizSessionPage extends StatelessWidget {
  final int quizId;

  const QuizSessionPage({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<QuizBloc>()
        ..add(GetQuizByIdEvent(quizId))
        ..add(
          const StartQuizAttemptEvent(0),
        ), // Will be replaced with actual quiz ID
      child: const _QuizSessionView(),
    );
  }
}

class _QuizSessionView extends StatefulWidget {
  const _QuizSessionView();

  @override
  State<_QuizSessionView> createState() => _QuizSessionViewState();
}

class _QuizSessionViewState extends State<_QuizSessionView> {
  int _currentQuestionIndex = 0;
  final Map<int, String> _userAnswers = {};
  bool _isCompleted = false;
  bool _isSubmitted = false;

  void _nextQuestion() {
    // Can only move forward if current question is answered
    if (_userAnswers.containsKey(_currentQuestionIndex)) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer before continuing'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _selectAnswer(String answer) {
    if (!_isSubmitted) {
      setState(() {
        _userAnswers[_currentQuestionIndex] = answer;
      });
    }
  }

  void _submitQuiz() {
    final state = context.read<QuizBloc>().state;

    if (state is QuizLoaded) {
      final totalQuestions = state.quiz.totalQuestions;

      if (_userAnswers.length < totalQuestions) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('⚠️ Incomplete Quiz'),
            content: Text(
              'You have answered ${_userAnswers.length} out of $totalQuestions questions.\n\n'
              'Unanswered questions will be marked as wrong.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue Answering'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performSubmit();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Submit Anyway'),
              ),
            ],
          ),
        );
      } else {
        _performSubmit();
      }
    }
  }

  void _performSubmit() {
    // Convert answers to API format
    final answers = _userAnswers.entries
        .map(
          (entry) => {
            'questionId': entry.key + 1,
            'selectedOption': entry.value,
          },
        )
        .toList();

    // Submit quiz
    context.read<QuizBloc>().add(
      SubmitQuizAttemptEvent(
        attemptId: 1, // Should be from StartQuizAttemptEvent response
        answers: answers,
      ),
    );

    setState(() {
      _isSubmitted = true;
      _isCompleted = true;
    });
  }

  void _showResults(QuizAttemptSubmitted state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Quiz Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Your Score: ${state.attempt.score}%',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${state.attempt.correctAnswers} / ${state.attempt.totalQuestions} correct',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (state.attempt.score >= 80)
              const Text(
                '🌟 Excellent!',
                style: TextStyle(fontSize: 18, color: Colors.green),
              )
            else if (state.attempt.score >= 60)
              const Text(
                '👍 Good job!',
                style: TextStyle(fontSize: 18, color: Colors.blue),
              )
            else
              const Text(
                '💪 Keep practicing!',
                style: TextStyle(fontSize: 18, color: Colors.orange),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to quiz list
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to quiz list
              // Could navigate to quiz detail with answers shown
            },
            child: const Text('Review Answers'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_isSubmitted && _userAnswers.isNotEmpty) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Leave Quiz?'),
              content: const Text('Your progress will be lost.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Leave'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Session'),
          actions: [
            if (!_isSubmitted)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Chip(
                  label: Text('${_userAnswers.length} answered'),
                  avatar: const Icon(Icons.check_circle, size: 18),
                ),
              ),
          ],
        ),
        body: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            if (state is QuizAttemptSubmitted) {
              _showResults(state);
            }
          },
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is QuizError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 80, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            if (state is QuizLoaded) {
              final quiz = state.quiz;

              // Mock questions - in real app, load from API
              final questions = List.generate(
                quiz.totalQuestions,
                (index) => {
                  'id': index + 1,
                  'question': 'Question ${index + 1}',
                  'options': ['A', 'B', 'C', 'D'],
                  'correctAnswer': 'A', // Hidden until submitted
                },
              );

              if (_currentQuestionIndex >= questions.length) {
                return const Center(child: Text('No more questions'));
              }

              final currentQuestion = questions[_currentQuestionIndex];
              final userAnswer = _userAnswers[_currentQuestionIndex];

              return Column(
                children: [
                  // Progress bar
                  LinearProgressIndicator(
                    value: questions.isNotEmpty
                        ? (_currentQuestionIndex + 1) / questions.length
                        : 0,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question counter
                          Text(
                            'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Question text
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.help_outline,
                                    size: 32,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    currentQuestion['question'] as String,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Answer options
                          const Text(
                            'Select your answer:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          ...(currentQuestion['options'] as List<String>).map((
                            option,
                          ) {
                            final isSelected = userAnswer == option;

                            // Show correct/wrong only if submitted
                            Color? cardColor;
                            IconData? statusIcon;

                            if (_isSubmitted) {
                              final isCorrect =
                                  option == currentQuestion['correctAnswer'];
                              if (isCorrect) {
                                cardColor = Colors.green[100];
                                statusIcon = Icons.check_circle;
                              } else if (isSelected) {
                                cardColor = Colors.red[100];
                                statusIcon = Icons.cancel;
                              }
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: cardColor,
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  'Option $option',
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                trailing: _isSubmitted && statusIcon != null
                                    ? Icon(
                                        statusIcon,
                                        color: cardColor == Colors.green[100]
                                            ? Colors.green
                                            : Colors.red,
                                      )
                                    : null,
                                onTap: () => _selectAnswer(option),
                              ),
                            );
                          }),

                          // Warning about answer protection
                          if (!_isSubmitted)
                            Container(
                              margin: const EdgeInsets.only(top: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.amber[50],
                                border: Border.all(color: Colors.amber),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.lock, color: Colors.amber),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Answers are hidden until you submit the quiz',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Navigation and Submit buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (!_isSubmitted)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _userAnswers.isNotEmpty
                                  ? _submitQuiz
                                  : null,
                              icon: const Icon(Icons.send),
                              label: const Text('Submit Quiz'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: _currentQuestionIndex > 0
                                  ? _previousQuestion
                                  : null,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Previous'),
                            ),
                            Text(
                              '${_currentQuestionIndex + 1}/${questions.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed:
                                  _currentQuestionIndex < questions.length - 1
                                  ? _nextQuestion
                                  : null,
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Next'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
