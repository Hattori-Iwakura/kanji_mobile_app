import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/kanji.dart';
import '../../domain/usecases/create_kanji.dart';
import '../../domain/usecases/update_kanji.dart';
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_event.dart';
import '../bloc/kanji_state.dart';

class KanjiFormPage extends StatefulWidget {
  final Kanji? kanji; // null for create, non-null for update

  const KanjiFormPage({Key? key, this.kanji}) : super(key: key);

  @override
  State<KanjiFormPage> createState() => _KanjiFormPageState();
}

class _KanjiFormPageState extends State<KanjiFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _characterController = TextEditingController();
  final _onyomiController = TextEditingController();
  final _kunyomiController = TextEditingController();
  final _meaningsController = TextEditingController();
  final _strokeCountController = TextEditingController();
  final _jlptController = TextEditingController();
  final _gradeController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _radicalsController = TextEditingController();

  bool get isEditMode => widget.kanji != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _populateFields();
    }
  }

  void _populateFields() {
    final kanji = widget.kanji!;
    _characterController.text = kanji.character;
    _onyomiController.text = kanji.onyomi ?? '';
    _kunyomiController.text = kanji.kunyomi ?? '';
    _meaningsController.text = kanji.meanings;
    _strokeCountController.text = kanji.strokeCount?.toString() ?? '';
    _jlptController.text = kanji.jlpt?.toString() ?? '';
    _gradeController.text = kanji.grade?.toString() ?? '';
    _frequencyController.text = kanji.frequency?.toString() ?? '';
    _radicalsController.text = kanji.radicals ?? '';
  }

  @override
  void dispose() {
    _characterController.dispose();
    _onyomiController.dispose();
    _kunyomiController.dispose();
    _meaningsController.dispose();
    _strokeCountController.dispose();
    _jlptController.dispose();
    _gradeController.dispose();
    _frequencyController.dispose();
    _radicalsController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (isEditMode) {
        // Update existing kanji
        final params = UpdateKanjiParams(
          id: widget.kanji!.id,
          character: _characterController.text.isNotEmpty
              ? _characterController.text
              : null,
          onyomi: _onyomiController.text.isNotEmpty
              ? _onyomiController.text
              : null,
          kunyomi: _kunyomiController.text.isNotEmpty
              ? _kunyomiController.text
              : null,
          meanings: _meaningsController.text.isNotEmpty
              ? _meaningsController.text
              : null,
          strokeCount: _strokeCountController.text.isNotEmpty
              ? int.tryParse(_strokeCountController.text)
              : null,
          jlpt: _jlptController.text.isNotEmpty
              ? int.tryParse(_jlptController.text)
              : null,
          grade: _gradeController.text.isNotEmpty
              ? int.tryParse(_gradeController.text)
              : null,
          frequency: _frequencyController.text.isNotEmpty
              ? int.tryParse(_frequencyController.text)
              : null,
          radicals: _radicalsController.text.isNotEmpty
              ? _radicalsController.text
              : null,
        );
        context.read<KanjiBloc>().add(UpdateKanjiEvent(params));
      } else {
        // Create new kanji
        final params = CreateKanjiParams(
          character: _characterController.text,
          onyomi: _onyomiController.text.isNotEmpty
              ? _onyomiController.text
              : null,
          kunyomi: _kunyomiController.text.isNotEmpty
              ? _kunyomiController.text
              : null,
          meanings: _meaningsController.text,
          strokeCount: _strokeCountController.text.isNotEmpty
              ? int.tryParse(_strokeCountController.text)
              : null,
          jlpt: _jlptController.text.isNotEmpty
              ? int.tryParse(_jlptController.text)
              : null,
          grade: _gradeController.text.isNotEmpty
              ? int.tryParse(_gradeController.text)
              : null,
          frequency: _frequencyController.text.isNotEmpty
              ? int.tryParse(_frequencyController.text)
              : null,
          radicals: _radicalsController.text.isNotEmpty
              ? _radicalsController.text
              : null,
        );
        context.read<KanjiBloc>().add(CreateKanjiEvent(params));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Kanji' : 'Create Kanji')),
      body: BlocListener<KanjiBloc, KanjiState>(
        listener: (context, state) {
          if (state is KanjiOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          } else if (state is KanjiError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<KanjiBloc, KanjiState>(
          builder: (context, state) {
            if (state is KanjiLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _characterController,
                      decoration: const InputDecoration(
                        labelText: 'Character *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a character';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _onyomiController,
                      decoration: const InputDecoration(
                        labelText: 'On\'yomi (音読み)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _kunyomiController,
                      decoration: const InputDecoration(
                        labelText: 'Kun\'yomi (訓読み)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _meaningsController,
                      decoration: const InputDecoration(
                        labelText: 'Meanings (comma separated) *',
                        border: OutlineInputBorder(),
                        hintText: 'one, two, three',
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter meanings';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _strokeCountController,
                            decoration: const InputDecoration(
                              labelText: 'Stroke Count',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _jlptController,
                            decoration: const InputDecoration(
                              labelText: 'JLPT Level (1-5)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final num = int.tryParse(value);
                                if (num == null || num < 1 || num > 5) {
                                  return 'Must be 1-5';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _gradeController,
                            decoration: const InputDecoration(
                              labelText: 'Grade (1-6)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final num = int.tryParse(value);
                                if (num == null || num < 1 || num > 6) {
                                  return 'Must be 1-6';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _frequencyController,
                            decoration: const InputDecoration(
                              labelText: 'Frequency',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _radicalsController,
                      decoration: const InputDecoration(
                        labelText: 'Radicals (comma separated)',
                        border: OutlineInputBorder(),
                        hintText: '一, 口, 木',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isEditMode ? 'Update Kanji' : 'Create Kanji',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
