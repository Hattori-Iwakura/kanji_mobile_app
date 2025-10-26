import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../cnn_recognition/presentation/bloc/cnn_recognition_bloc.dart';
import '../../../cnn_recognition/presentation/bloc/cnn_recognition_event.dart';
import '../../../cnn_recognition/presentation/bloc/cnn_recognition_state.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/question.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';
import '../widgets/quiz_drawing_canvas.dart';
import 'quiz_result_page.dart';

/// Page for taking a quiz
class QuizTakingPage extends StatefulWidget {
  final Quiz quiz;

  const QuizTakingPage({super.key, required this.quiz});

  @override
  State<QuizTakingPage> createState() => _QuizTakingPageState();
}

class _QuizTakingPageState extends State<QuizTakingPage> {
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });

      // Check time limit
      if (widget.quiz.hasTimeLimit &&
          _elapsedSeconds >= widget.quiz.timeLimit) {
        _timer?.cancel();
        _showTimeUpDialog();
      }
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Time\'s Up!', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your quiz time has expired. Submitting your answers now.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<QuizBloc>().add(CompleteQuizEvent(_elapsedSeconds));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<QuizBloc>()..add(StartQuizEvent(widget.quiz.id)),
        ),
        BlocProvider(create: (_) => getIt<CnnRecognitionBloc>()),
      ],
      child: _QuizTakingView(
        quiz: widget.quiz,
        elapsedSeconds: _elapsedSeconds,
        onComplete: () => _timer?.cancel(),
      ),
    );
  }
}

class _QuizTakingView extends StatelessWidget {
  final Quiz quiz;
  final int elapsedSeconds;
  final VoidCallback onComplete;

  const _QuizTakingView({
    required this.quiz,
    required this.elapsedSeconds,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(quiz.title, style: const TextStyle(color: Colors.white)),
        actions: [
          // Timer display
          if (quiz.hasTimeLimit)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getTimeColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(quiz.timeLimit - elapsedSeconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
            Navigator.pop(context);
          } else if (state is QuizCompleted) {
            onComplete();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => QuizResultPage(result: state.result),
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

          if (state is QuizSessionActive) {
            final currentQuestion = state.currentQuestion;
            if (currentQuestion == null) {
              return const Center(
                child: Text(
                  'No more questions',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return Column(
              children: [
                // Progress bar
                _buildProgressBar(state),

                // Question content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question number
                        Text(
                          'Question ${state.currentIndex + 1} of ${state.questions.length}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Question text
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            currentQuestion.questionText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Answer options based on question type
                        _buildAnswerSection(context, state, currentQuestion),
                      ],
                    ),
                  ),
                ),

                // Navigation buttons
                _buildNavigationButtons(context, state),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProgressBar(QuizSessionActive state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress: ${state.answeredCount}/${state.questions.length}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                '${state.progressPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (state.currentIndex + 1) / state.questions.length,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection(
    BuildContext context,
    QuizSessionActive state,
    Question question,
  ) {
    if (question.isMultipleChoice) {
      return _buildMultipleChoice(context, state, question);
    } else if (question.isFillInBlank) {
      return _buildFillInBlank(context, state, question);
    } else if (question.isTrueFalse) {
      return _buildTrueFalse(context, state, question);
    } else if (question.isDrawing) {
      return _buildDrawing(context, state, question);
    } else {
      return const Text(
        'Unsupported question type',
        style: TextStyle(color: Colors.white),
      );
    }
  }

  Widget _buildMultipleChoice(
    BuildContext context,
    QuizSessionActive state,
    Question question,
  ) {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = state.currentAnswer == option;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              context.read<QuizBloc>().add(
                AnswerQuestionEvent(questionId: question.id, answer: option),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.withOpacity(0.3)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.white24,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.blue : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.white54,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.blue),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFillInBlank(
    BuildContext context,
    QuizSessionActive state,
    Question question,
  ) {
    final controller = TextEditingController(text: state.currentAnswer ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          onChanged: (value) {
            // Auto-save answer
            if (value.isNotEmpty) {
              context.read<QuizBloc>().add(
                AnswerQuestionEvent(
                  questionId: question.id,
                  answer: value.trim(),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your answer in the text field above',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalse(
    BuildContext context,
    QuizSessionActive state,
    Question question,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildTrueFalseOption(
            context,
            state,
            question,
            'True',
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTrueFalseOption(
            context,
            state,
            question,
            'False',
            Colors.red,
            Icons.cancel,
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalseOption(
    BuildContext context,
    QuizSessionActive state,
    Question question,
    String value,
    Color color,
    IconData icon,
  ) {
    final isSelected = state.currentAnswer == value;

    return InkWell(
      onTap: () {
        context.read<QuizBloc>().add(
          AnswerQuestionEvent(questionId: question.id, answer: value),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: isSelected ? color : Colors.white54),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawing(
    BuildContext context,
    QuizSessionActive state,
    Question question,
  ) {
    return BlocConsumer<CnnRecognitionBloc, CnnRecognitionState>(
      listener: (context, cnnState) {
        if (cnnState is PredictionSuccess) {
          // Get top prediction
          if (cnnState.predictions.isNotEmpty) {
            final topPrediction = cnnState.predictions.first;
            final predictedKanji = topPrediction.character;

            // Auto-submit answer
            context.read<QuizBloc>().add(
              AnswerQuestionEvent(
                questionId: question.id,
                answer: predictedKanji,
              ),
            );

            // Show prediction result
            final isCorrect = predictedKanji == question.correctAnswer;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.error,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'CNN Predicted: $predictedKanji',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            isCorrect
                                ? '✓ Correct! (${(topPrediction.confidence * 100).toStringAsFixed(1)}%)'
                                : '✗ Expected: ${question.correctAnswer}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: isCorrect ? Colors.green : Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } else if (cnnState is PredictionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${cnnState.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, cnnState) {
        final isProcessing = cnnState is PredictingKanji;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawing instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.draw, color: Colors.purple, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Draw the Kanji',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Draw the kanji character in the canvas below. The AI will recognize your drawing and check if it matches the expected answer.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Canvas
            QuizDrawingCanvas(
              onDrawingComplete: (imageBytes) {
                // Trigger CNN prediction
                context.read<CnnRecognitionBloc>().add(
                  PredictKanjiEvent(imageBytes),
                );
              },
              onClear: () {
                // Clear any previous answer
                context.read<CnnRecognitionBloc>().add(ClearRecognitionEvent());
              },
            ),

            if (isProcessing) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Analyzing your drawing...',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (state.currentQuestionAnswered) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Answer Submitted',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Your answer: ${state.currentAnswer}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    QuizSessionActive state,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          // Previous button
          if (!state.isFirstQuestion)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<QuizBloc>().add(PreviousQuestionEvent());
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

          if (!state.isFirstQuestion) const SizedBox(width: 12),

          // Next/Submit button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: state.currentQuestionAnswered
                  ? () {
                      if (state.isLastQuestion) {
                        _showSubmitConfirmation(context, state);
                      } else {
                        context.read<QuizBloc>().add(NextQuestionEvent());
                      }
                    }
                  : null,
              icon: Icon(
                state.isLastQuestion ? Icons.check : Icons.arrow_forward,
              ),
              label: Text(state.isLastQuestion ? 'Submit Quiz' : 'Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: state.isLastQuestion
                    ? Colors.green
                    : Colors.blue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade800,
                disabledForegroundColor: Colors.white38,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          if (!state.isLastQuestion) const SizedBox(width: 12),

          // Skip button
          if (!state.isLastQuestion)
            OutlinedButton(
              onPressed: () {
                context.read<QuizBloc>().add(SkipQuestionEvent());
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              child: const Text('Skip'),
            ),
        ],
      ),
    );
  }

  void _showSubmitConfirmation(BuildContext context, QuizSessionActive state) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Submit Quiz?',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have answered ${state.answeredCount} out of ${state.questions.length} questions.',
              style: const TextStyle(color: Colors.white70),
            ),
            if (state.unansweredCount > 0) ...[
              const SizedBox(height: 12),
              Text(
                '${state.unansweredCount} question(s) remaining unanswered.',
                style: const TextStyle(color: Colors.orange),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Review'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<QuizBloc>().add(CompleteQuizEvent(elapsedSeconds));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Color _getTimeColor() {
    final remaining = quiz.timeLimit - elapsedSeconds;
    final percentage = (remaining / quiz.timeLimit) * 100;

    if (percentage > 50) return Colors.green;
    if (percentage > 25) return Colors.orange;
    return Colors.red;
  }

  String _formatTime(int seconds) {
    if (seconds < 0) return '0:00';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
