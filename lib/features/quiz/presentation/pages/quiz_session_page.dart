import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../injection_container.dart' as di;
import '../models/quiz.dart';
import '../models/quiz_question.dart';
import '../widgets/question_widget.dart';

class QuizSessionPage extends StatefulWidget {
  final int quizId;

  const QuizSessionPage({super.key, required this.quizId});

  @override
  State<QuizSessionPage> createState() => _QuizSessionPageState();
}

class _QuizSessionPageState extends State<QuizSessionPage> {
  final ApiClient _apiClient = di.sl<ApiClient>();

  Quiz? _quiz;
  bool _isLoading = true;
  String? _errorMessage;

  int _currentQuestionIndex = 0;
  Map<int, String> _answers = {}; // questionId -> answer
  int _score = 0;
  bool _isCompleted = false;
  int? _attemptId;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiClient.get('/quizzes/${widget.quizId}');
      final data = response.data['data'] ?? response.data;

      final quiz = Quiz.fromJson(data as Map<String, dynamic>);

      if (quiz.questions == null || quiz.questions!.isEmpty) {
        throw Exception('This quiz has no questions');
      }

      setState(() {
        _quiz = quiz;
        _isLoading = false;
      });

      // Start attempt
      await _startAttempt();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load quiz: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _startAttempt() async {
    try {
      final response = await _apiClient.post('/quiz-attempts', {
        'quizId': widget.quizId,
      });

      final data = response.data['data'] ?? response.data;
      _attemptId = data['id'] as int;
    } catch (e) {
      debugPrint('Failed to start attempt: $e');
    }
  }

  Future<void> _submitAttempt() async {
    if (_attemptId == null) return;

    try {
      await _apiClient.put('/quiz-attempts/$_attemptId', {
        'score': _score,
        'answers': _answers,
        'completedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Failed to submit attempt: $e');
    }
  }

  void _answerQuestion(String answer) {
    final question = _quiz!.questions![_currentQuestionIndex];

    setState(() {
      _answers[question.id] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quiz!.questions!.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _completeQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _completeQuiz() {
    // Calculate score
    int correctAnswers = 0;
    for (final question in _quiz!.questions!) {
      final userAnswer = _answers[question.id];
      if (userAnswer != null &&
          userAnswer.trim().toLowerCase() ==
              question.correctAnswer.trim().toLowerCase()) {
        correctAnswers++;
      }
    }

    setState(() {
      _score = correctAnswers;
      _isCompleted = true;
    });

    _submitAttempt();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isCompleted,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_isCompleted) {
          _showExitConfirmation();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_quiz?.title ?? 'Quiz'),
          centerTitle: true,
          actions: [
            if (!_isCompleted && _quiz != null)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '${_currentQuestionIndex + 1}/${_quiz!.questions!.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: _buildBody(),
      ),
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
            ElevatedButton(onPressed: _loadQuiz, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_isCompleted) {
      return _buildResultsView();
    }

    return _buildQuestionView();
  }

  Widget _buildQuestionView() {
    final question = _quiz!.questions![_currentQuestionIndex];
    final userAnswer = _answers[question.id];

    return Column(
      children: [
        // Progress Bar
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _quiz!.questions!.length,
          backgroundColor: Colors.grey.shade200,
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                QuestionWidget(
                  question: question,
                  selectedAnswer: userAnswer,
                  onAnswerSelected: _answerQuestion,
                ),
              ],
            ),
          ),
        ),

        // Navigation Buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previousQuestion,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                ),
              if (_currentQuestionIndex > 0) const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: userAnswer != null ? _nextQuestion : null,
                  icon: Icon(
                    _currentQuestionIndex < _quiz!.questions!.length - 1
                        ? Icons.arrow_forward
                        : Icons.check,
                  ),
                  label: Text(
                    _currentQuestionIndex < _quiz!.questions!.length - 1
                        ? 'Next'
                        : 'Finish',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    final totalQuestions = _quiz!.questions!.length;
    final percentage = ((_score / totalQuestions) * 100).round();

    Color resultColor;
    String resultText;
    IconData resultIcon;

    if (percentage >= 80) {
      resultColor = Colors.green;
      resultText = 'Excellent!';
      resultIcon = Icons.emoji_events;
    } else if (percentage >= 60) {
      resultColor = Colors.blue;
      resultText = 'Good Job!';
      resultIcon = Icons.thumb_up;
    } else if (percentage >= 40) {
      resultColor = Colors.orange;
      resultText = 'Keep Practicing!';
      resultIcon = Icons.lightbulb;
    } else {
      resultColor = Colors.red;
      resultText = 'Need More Study';
      resultIcon = Icons.school;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(resultIcon, size: 80, color: resultColor),
            ),
            const SizedBox(height: 24),
            Text(
              resultText,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: resultColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your Score',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              '$_score / $totalQuestions',
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: resultColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home),
                label: const Text('Back to Quizzes'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentQuestionIndex = 0;
                    _answers.clear();
                    _score = 0;
                    _isCompleted = false;
                  });
                  _startAttempt();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Quiz'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
