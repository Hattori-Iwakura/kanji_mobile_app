import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/question.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';

/// Page for editing an existing question
class EditQuestionPage extends StatefulWidget {
  final String quizId;
  final Question question;

  const EditQuestionPage({
    super.key,
    required this.quizId,
    required this.question,
  });

  @override
  State<EditQuestionPage> createState() => _EditQuestionPageState();
}

class _EditQuestionPageState extends State<EditQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _explanationController;
  late TextEditingController _pointsController;
  late TextEditingController _fillInBlankAnswerController;
  late TextEditingController _drawingAnswerController;

  // Multiple choice options
  late List<TextEditingController> _optionControllers;

  late String _selectedType;
  late int _correctAnswerIndex;
  late bool _trueFalseAnswer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data
    _questionController = TextEditingController(
      text: widget.question.questionText,
    );
    _explanationController = TextEditingController(
      text: widget.question.explanation ?? '',
    );
    _pointsController = TextEditingController(
      text: widget.question.points.toString(),
    );
    _fillInBlankAnswerController = TextEditingController();
    _drawingAnswerController = TextEditingController();

    _selectedType = widget.question.type;

    // Initialize type-specific data
    switch (_selectedType) {
      case 'MULTIPLE_CHOICE':
        _optionControllers = widget.question.options
            .map((option) => TextEditingController(text: option))
            .toList();
        // Ensure we have exactly 4 options
        while (_optionControllers.length < 4) {
          _optionControllers.add(TextEditingController());
        }
        _correctAnswerIndex = widget.question.options.indexOf(
          widget.question.correctAnswer,
        );
        if (_correctAnswerIndex == -1) _correctAnswerIndex = 0;
        break;

      case 'TRUE_FALSE':
        _optionControllers = List.generate(4, (_) => TextEditingController());
        _trueFalseAnswer =
            widget.question.correctAnswer.toLowerCase() == 'true';
        break;

      case 'FILL_IN_BLANK':
        _optionControllers = List.generate(4, (_) => TextEditingController());
        _fillInBlankAnswerController = TextEditingController(
          text: widget.question.correctAnswer,
        );
        break;

      case 'DRAWING':
        _optionControllers = List.generate(4, (_) => TextEditingController());
        _drawingAnswerController = TextEditingController(
          text: widget.question.correctAnswer,
        );
        break;

      default:
        _optionControllers = List.generate(4, (_) => TextEditingController());
    }

    _correctAnswerIndex = _correctAnswerIndex.clamp(0, 3);
    _trueFalseAnswer = false;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    _pointsController.dispose();
    _fillInBlankAnswerController.dispose();
    _drawingAnswerController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuizBloc>(),
      child: BlocListener<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state is QuizError) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is QuizSessionActive) {
            // Success - go back
            Navigator.pop(context, true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'Edit Question',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => _confirmDiscard(),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Question Type (read-only)
                const Text(
                  'Question Type',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getTypeIcon(_selectedType),
                        color: _getTypeColor(_selectedType),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.question.typeDisplayName,
                        style: TextStyle(
                          color: _getTypeColor(_selectedType),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.lock,
                        color: Colors.white.withOpacity(0.3),
                        size: 20,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Question type cannot be changed after creation',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Question Text
                TextFormField(
                  controller: _questionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Question',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: 'Enter your question here...',
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
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a question';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Type-specific fields
                _buildTypeSpecificFields(),

                const SizedBox(height: 24),

                // Points
                TextFormField(
                  controller: _pointsController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Points',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.star, color: Colors.amber),
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
                      borderSide: const BorderSide(
                        color: Colors.amber,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter points';
                    }
                    final points = int.tryParse(value);
                    if (points == null || points <= 0) {
                      return 'Points must be a positive number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Explanation (optional)
                TextFormField(
                  controller: _explanationController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Explanation (Optional)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: 'Provide an explanation for the answer...',
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
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSpecificFields() {
    switch (_selectedType) {
      case 'MULTIPLE_CHOICE':
        return _buildMultipleChoiceFields();
      case 'TRUE_FALSE':
        return _buildTrueFalseFields();
      case 'FILL_IN_BLANK':
        return _buildFillInBlankFields();
      case 'DRAWING':
        return _buildDrawingFields();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMultipleChoiceFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Options',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Radio<int>(
                  value: index,
                  groupValue: _correctAnswerIndex,
                  onChanged: (value) {
                    setState(() {
                      _correctAnswerIndex = value!;
                    });
                  },
                  activeColor: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _optionControllers[index],
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Option ${index + 1}',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _correctAnswerIndex == index
                              ? Colors.green
                              : Colors.white24,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _correctAnswerIndex == index
                              ? Colors.green
                              : Colors.white24,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _correctAnswerIndex == index
                              ? Colors.green
                              : Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter option ${index + 1}';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Select the correct answer by clicking the radio button',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalseFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Correct Answer',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTrueFalseOption(true, 'True', Icons.check_circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTrueFalseOption(false, 'False', Icons.cancel),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrueFalseOption(bool value, String label, IconData icon) {
    final isSelected = _trueFalseAnswer == value;
    return InkWell(
      onTap: () {
        setState(() {
          _trueFalseAnswer = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (value
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2))
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (value ? Colors.green : Colors.red)
                : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (value ? Colors.green : Colors.red)
                  : Colors.white70,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillInBlankFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Correct Answer',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _fillInBlankAnswerController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Answer',
            labelStyle: const TextStyle(color: Colors.white70),
            hintText: 'Enter the correct answer...',
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
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the correct answer';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDrawingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Correct Kanji Character',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _drawingAnswerController,
          style: const TextStyle(color: Colors.white, fontSize: 32),
          textAlign: TextAlign.center,
          maxLength: 1,
          readOnly: true, // Cannot change kanji in edit mode
          decoration: InputDecoration(
            labelText: 'Kanji',
            labelStyle: const TextStyle(color: Colors.white70),
            hintText: '漢',
            suffixIcon: const Icon(Icons.lock, color: Colors.white38),
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 32,
            ),
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
              borderSide: const BorderSide(color: Colors.purple, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a kanji character';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Show stored meanings (read-only)
        if (widget.question.meanings.isNotEmpty) ...[
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
                    const Icon(
                      Icons.info_outline,
                      color: Colors.purple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Kanji Information',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Meanings: ${widget.question.meanings.join(", ")}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Kanji character cannot be changed after creation',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'MULTIPLE_CHOICE':
        return Icons.format_list_bulleted;
      case 'TRUE_FALSE':
        return Icons.check_circle;
      case 'FILL_IN_BLANK':
        return Icons.edit;
      case 'DRAWING':
        return Icons.draw;
      default:
        return Icons.quiz;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'MULTIPLE_CHOICE':
        return Colors.blue;
      case 'TRUE_FALSE':
        return Colors.green;
      case 'FILL_IN_BLANK':
        return Colors.orange;
      case 'DRAWING':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _confirmDiscard() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'Are you sure you want to discard your changes? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    // Prepare data based on type
    List<String>? options;
    String correctAnswer = '';

    switch (_selectedType) {
      case 'MULTIPLE_CHOICE':
        options = _optionControllers
            .map((controller) => controller.text.trim())
            .toList();
        correctAnswer = options[_correctAnswerIndex];
        break;
      case 'TRUE_FALSE':
        options = ['True', 'False'];
        correctAnswer = _trueFalseAnswer ? 'True' : 'False';
        break;
      case 'FILL_IN_BLANK':
        correctAnswer = _fillInBlankAnswerController.text.trim();
        break;
      case 'DRAWING':
        correctAnswer = _drawingAnswerController.text.trim();
        break;
    }

    final points = int.parse(_pointsController.text.trim());
    final explanation = _explanationController.text.trim();

    context.read<QuizBloc>().add(
      UpdateQuestionEvent(
        quizId: widget.quizId,
        questionId: widget.question.id,
        questionText: _questionController.text.trim(),
        options: options,
        correctAnswer: correctAnswer,
        explanation: explanation.isEmpty ? null : explanation,
        points: points,
      ),
    );
  }
}
