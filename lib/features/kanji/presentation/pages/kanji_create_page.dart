import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_event.dart';
import '../bloc/kanji_state.dart';

class KanjiCreatePage extends StatefulWidget {
  final int? kanjiId; // null for create, non-null for edit

  const KanjiCreatePage({Key? key, this.kanjiId}) : super(key: key);

  @override
  State<KanjiCreatePage> createState() => _KanjiCreatePageState();
}

class _KanjiCreatePageState extends State<KanjiCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _characterController = TextEditingController();
  final _onyomiController = TextEditingController();
  final _kunyomiController = TextEditingController();
  final _meaningsController = TextEditingController();
  final _strokeCountController = TextEditingController();

  String? _selectedJlpt;
  int? _selectedGrade;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.kanjiId != null) {
      // Load kanji data for edit
      context.read<KanjiBloc>().add(LoadKanjiByIdEvent(widget.kanjiId!));
    }
  }

  @override
  void dispose() {
    _characterController.dispose();
    _onyomiController.dispose();
    _kunyomiController.dispose();
    _meaningsController.dispose();
    _strokeCountController.dispose();
    super.dispose();
  }

  void _loadKanjiData(dynamic kanji) {
    _characterController.text = kanji.character ?? '';
    
    // Backend returns strings, not arrays
    _onyomiController.text = kanji.onyomi is String 
      ? (kanji.onyomi as String).replaceAll('、', ', ')
      : (kanji.onyomi as List<dynamic>).join(', ');
    
    _kunyomiController.text = kanji.kunyomi is String
      ? (kanji.kunyomi as String).replaceAll('、', ', ')
      : (kanji.kunyomi as List<dynamic>).join(', ');
    
    _meaningsController.text = kanji.meanings is String
      ? kanji.meanings as String
      : (kanji.meanings as List<dynamic>).join(', ');
    
    _strokeCountController.text = kanji.strokeCount?.toString() ?? '';
    
    // Backend returns jlpt as int (1-5), convert to N1-N5
    if (kanji.jlpt != null) {
      _selectedJlpt = 'N${kanji.jlpt}';
    } else {
      _selectedJlpt = kanji.jlptLevel;
    }
    
    _selectedGrade = kanji.grade;
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final kanjiData = {
      'character': _characterController.text.trim(),
      'onyomi': _onyomiController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      'kunyomi': _kunyomiController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      'meanings': _meaningsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      'strokeCount': int.tryParse(_strokeCountController.text.trim()),
      'jlptLevel': _selectedJlpt,
      'grade': _selectedGrade,
    };

    if (widget.kanjiId == null) {
      // Create new kanji
      context.read<KanjiBloc>().add(CreateKanjiEvent(kanjiData));
    } else {
      // Update existing kanji
      context.read<KanjiBloc>().add(
        UpdateKanjiEvent(widget.kanjiId!, kanjiData),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.kanjiId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Kanji' : 'Create Kanji'),
        leading: const CustomBackButton(),
      ),
      body: BlocConsumer<KanjiBloc, KanjiState>(
        listener: (context, state) {
          if (state is KanjiDetailLoaded && isEdit && !_isLoading) {
            // Load data for edit
            setState(() {
              _isLoading = true;
            });
            _loadKanjiData(state.kanji);
          }

          if (state is KanjiCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Kanji created successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            // Navigate back immediately to see the updated list
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.pop(context);
              }
            });
          }

          if (state is KanjiUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Kanji updated successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            // Navigate back immediately to see the updated list
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.pop(context);
              }
            });
          }

          if (state is KanjiError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is KanjiLoading && !_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Character field
                  TextFormField(
                    controller: _characterController,
                    decoration: const InputDecoration(
                      labelText: 'Kanji Character *',
                      hintText: 'e.g., 日',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 32),
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a kanji character';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Onyomi field
                  TextFormField(
                    controller: _onyomiController,
                    decoration: const InputDecoration(
                      labelText: 'Onyomi (音読み)',
                      hintText: 'e.g., ニチ, ジツ (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter at least one onyomi reading';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Kunyomi field
                  TextFormField(
                    controller: _kunyomiController,
                    decoration: const InputDecoration(
                      labelText: 'Kunyomi (訓読み)',
                      hintText: 'e.g., ひ, か (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter at least one kunyomi reading';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Meanings field
                  TextFormField(
                    controller: _meaningsController,
                    decoration: const InputDecoration(
                      labelText: 'Meanings *',
                      hintText: 'e.g., sun, day (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter at least one meaning';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Stroke count field
                  TextFormField(
                    controller: _strokeCountController,
                    decoration: const InputDecoration(
                      labelText: 'Stroke Count',
                      hintText: 'e.g., 4',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final count = int.tryParse(value);
                        if (count == null || count < 1) {
                          return 'Please enter a valid stroke count';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // JLPT Level dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedJlpt,
                    decoration: const InputDecoration(
                      labelText: 'JLPT Level',
                      border: OutlineInputBorder(),
                    ),
                    items: ['N5', 'N4', 'N3', 'N2', 'N1']
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedJlpt = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Grade dropdown
                  DropdownButtonFormField<int>(
                    value: _selectedGrade,
                    decoration: const InputDecoration(
                      labelText: 'Grade (Kyōiku Kanji)',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(6, (i) => i + 1)
                        .map(
                          (grade) => DropdownMenuItem(
                            value: grade,
                            child: Text('Grade $grade'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGrade = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  ElevatedButton.icon(
                    onPressed: state is KanjiLoading ? null : _handleSubmit,
                    icon: Icon(isEdit ? Icons.save : Icons.add),
                    label: Text(
                      isEdit ? 'Update Kanji' : 'Create Kanji',
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cancel button
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
