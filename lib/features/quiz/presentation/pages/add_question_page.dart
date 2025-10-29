import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';
import '../../domain/entities/question.dart';

class AddQuestionPage extends StatefulWidget {
  final int quizId;

  const AddQuestionPage({super.key, required this.quizId});

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final _explanationController = TextEditingController();
  final _pointsController = TextEditingController(text: '10');

  QuestionType _selectedType = QuestionType.fillBlank;
  final List<TextEditingController> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    _addOptionField();
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _correctAnswerController.dispose();
    _explanationController.dispose();
    _pointsController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOptionField() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOptionField(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  void _addQuestion() {
    if (_formKey.currentState!.validate()) {
      final options = _selectedType == QuestionType.multipleChoice
          ? _optionControllers
                .map((c) => c.text.trim())
                .where((text) => text.isNotEmpty)
                .toList()
          : null;

      context.read<QuizBloc>().add(
        AddQuestionEvent(
          quizId: widget.quizId,
          type: _selectedType,
          questionText: _questionTextController.text.trim(),
          correctAnswer: _correctAnswerController.text.trim(),
          options: options,
          explanation: _explanationController.text.trim().isEmpty
              ? null
              : _explanationController.text.trim(),
          points: int.tryParse(_pointsController.text) ?? 10,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Add Question',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Form content
                Expanded(
                  child: BlocListener<QuizBloc, QuizState>(
                    listener: (context, state) {
                      if (state is QuestionAdded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Question added successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context, true);
                      } else if (state is QuizError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${state.message}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Question Type Selection
                            _buildSection(
                              title: 'Question Type',
                              child: SegmentedButton<QuestionType>(
                                segments: const [
                                  ButtonSegment(
                                    value: QuestionType.fillBlank,
                                    label: Text('Fill Blank'),
                                    icon: Icon(Icons.edit),
                                  ),
                                  ButtonSegment(
                                    value: QuestionType.multipleChoice,
                                    label: Text('Multiple Choice'),
                                    icon: Icon(Icons.checklist),
                                  ),
                                ],
                                selected: {_selectedType},
                                onSelectionChanged:
                                    (Set<QuestionType> newSelection) {
                                      setState(() {
                                        _selectedType = newSelection.first;
                                      });
                                    },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith((
                                        states,
                                      ) {
                                        if (states.contains(
                                          MaterialState.selected,
                                        )) {
                                          return Colors.tealAccent;
                                        }
                                        return Colors.white.withOpacity(0.1);
                                      }),
                                  foregroundColor:
                                      MaterialStateProperty.resolveWith((
                                        states,
                                      ) {
                                        if (states.contains(
                                          MaterialState.selected,
                                        )) {
                                          return const Color(0xFF071126);
                                        }
                                        return Colors.white70;
                                      }),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Question Text
                            _buildSection(
                              title: 'Question',
                              child: TextFormField(
                                controller: _questionTextController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(
                                  'Enter your question',
                                ),
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a question';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Multiple Choice Options
                            if (_selectedType ==
                                QuestionType.multipleChoice) ...[
                              _buildSection(
                                title: 'Answer Options',
                                child: Column(
                                  children: [
                                    ..._optionControllers.asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final controller = entry.value;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: controller,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                                decoration: _inputDecoration(
                                                  'Option ${index + 1}',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (_optionControllers.length > 1)
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(
                                                    0.2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.remove_circle,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () =>
                                                      _removeOptionField(index),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: _addOptionField,
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.tealAccent,
                                      ),
                                      label: const Text(
                                        'Add Option',
                                        style: TextStyle(
                                          color: Colors.tealAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Correct Answer
                            _buildSection(
                              title: 'Correct Answer',
                              child: TextFormField(
                                controller: _correctAnswerController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(
                                  'Enter the correct answer',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter the correct answer';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Additional Information
                            _buildSection(
                              title: 'Additional Information',
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _explanationController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _inputDecoration(
                                      'Explain the answer (optional)',
                                      label: 'Explanation',
                                    ),
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _pointsController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _inputDecoration(
                                      'Enter points',
                                      label: 'Points',
                                      prefixIcon: Icons.star_rounded,
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter points';
                                      }
                                      final points = int.tryParse(value);
                                      if (points == null || points < 1) {
                                        return 'Points must be at least 1';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Submit Button
                            BlocBuilder<QuizBloc, QuizState>(
                              builder: (context, state) {
                                final isLoading = state is QuizLoading;
                                return ElevatedButton(
                                  onPressed: isLoading ? null : _addQuestion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.tealAccent,
                                    foregroundColor: const Color(0xFF071126),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    disabledBackgroundColor: Colors.tealAccent
                                        .withOpacity(0.5),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF071126),
                                          ),
                                        )
                                      : const Text(
                                          'Add Question',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.tealAccent.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint, {
    String? label,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      hintStyle: const TextStyle(color: Colors.white38),
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Colors.tealAccent)
          : null,
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
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
        borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}
