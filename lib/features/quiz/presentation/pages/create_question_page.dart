import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../kanji/domain/repositories/kanji_repository.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';

/// Page for creating a new question
class CreateQuestionPage extends StatefulWidget {
  final String quizId;

  const CreateQuestionPage({super.key, required this.quizId});

  @override
  State<CreateQuestionPage> createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _explanationController = TextEditingController();
  final _pointsController = TextEditingController(text: '10');
  final _fillInBlankAnswerController = TextEditingController();
  final _drawingAnswerController = TextEditingController();

  // Multiple choice options
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  String _selectedType = 'MULTIPLE_CHOICE';
  int _correctAnswerIndex = 0;
  bool _trueFalseAnswer = true;
  bool _isSubmitting = false;

  // For DRAWING type - auto-fetched kanji data
  List<String> _kanjiMeanings = [];
  String _kanjiOnyomi = '';
  String _kanjiKunyomi = '';
  bool _isFetchingKanji = false;

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
              'Create Question',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Question Type Selector
                const Text(
                  'Question Type',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTypeSelector(),

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
                            'Create Question',
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

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildTypeChip(
          'MULTIPLE_CHOICE',
          'Multiple Choice',
          Icons.format_list_bulleted,
          Colors.blue,
        ),
        _buildTypeChip(
          'TRUE_FALSE',
          'True/False',
          Icons.check_circle,
          Colors.green,
        ),
        _buildTypeChip(
          'FILL_IN_BLANK',
          'Fill in Blank',
          Icons.edit,
          Colors.orange,
        ),
        _buildTypeChip('DRAWING', 'Drawing', Icons.draw, Colors.purple),
      ],
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : color),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedType = type;
        });
      },
      backgroundColor: const Color(0xFF1A1A1A),
      selectedColor: color,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(color: isSelected ? color : Colors.white24),
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
          onChanged: (value) {
            if (value.isNotEmpty) {
              _fetchKanjiData(value);
            } else {
              setState(() {
                _kanjiMeanings = [];
                _kanjiOnyomi = '';
                _kanjiKunyomi = '';
              });
            }
          },
          decoration: InputDecoration(
            labelText: 'Kanji',
            labelStyle: const TextStyle(color: Colors.white70),
            hintText: '漢',
            suffixIcon: _isFetchingKanji
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.purple,
                      ),
                    ),
                  )
                : null,
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
            if (_kanjiMeanings.isEmpty) {
              return 'Failed to fetch kanji data. Please try again.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Show fetched kanji data
        if (_kanjiMeanings.isNotEmpty) ...[
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
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kanji Data Loaded',
                      style: TextStyle(
                        color: Colors.green.shade300,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildKanjiInfoRow('Meanings', _kanjiMeanings.join(', ')),
                if (_kanjiOnyomi.isNotEmpty)
                  _buildKanjiInfoRow('On\'yomi', _kanjiOnyomi),
                if (_kanjiKunyomi.isNotEmpty)
                  _buildKanjiInfoRow('Kun\'yomi', _kanjiKunyomi),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _kanjiMeanings.isNotEmpty
                ? 'Students will see the meanings and readings above, then draw the kanji'
                : 'Enter a kanji character to fetch meanings and readings',
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

  Widget _buildKanjiInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchKanjiData(String kanji) async {
    setState(() => _isFetchingKanji = true);

    try {
      final kanjiRepo = getIt<KanjiRepository>();
      final result = await kanjiRepo.searchKanji(query: kanji);

      result.fold(
        (failure) {
          setState(() {
            _isFetchingKanji = false;
            _kanjiMeanings = [];
            _kanjiOnyomi = '';
            _kanjiKunyomi = '';
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to fetch kanji: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (kanjiList) {
          // Find exact match
          final kanjiData = kanjiList.firstWhere(
            (k) => k.character == kanji,
            orElse: () => kanjiList.first,
          );

          setState(() {
            // meanings is a comma-separated string, convert to list
            _kanjiMeanings = kanjiData.meanings
                .split(',')
                .map((m) => m.trim())
                .where((m) => m.isNotEmpty)
                .toList();
            _kanjiOnyomi = kanjiData.onyomi ?? '';
            _kanjiKunyomi = kanjiData.kunyomi ?? '';
            _isFetchingKanji = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isFetchingKanji = false;
        _kanjiMeanings = [];
        _kanjiOnyomi = '';
        _kanjiKunyomi = '';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    // Prepare data based on type
    List<String> options = [];
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

    // For DRAWING type, include meanings/readings in questionText
    String finalQuestionText = _questionController.text.trim();
    List<String> meanings = [];

    if (_selectedType == 'DRAWING' && _kanjiMeanings.isNotEmpty) {
      meanings = _kanjiMeanings;
      // Auto-generate question text from meanings and readings
      finalQuestionText = 'Draw the kanji for: ${_kanjiMeanings.join(", ")}';
      if (_kanjiOnyomi.isNotEmpty) {
        finalQuestionText += '\nOn\'yomi: $_kanjiOnyomi';
      }
      if (_kanjiKunyomi.isNotEmpty) {
        finalQuestionText += '\nKun\'yomi: $_kanjiKunyomi';
      }
    }

    context.read<QuizBloc>().add(
      AddQuestionEvent(
        quizId: widget.quizId,
        type: _selectedType,
        questionText: finalQuestionText,
        options: options,
        correctAnswer: correctAnswer,
        explanation: explanation.isEmpty ? null : explanation,
        points: points,
        meanings: meanings,
      ),
    );
  }
}
