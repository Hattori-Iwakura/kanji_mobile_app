import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/kanji_entity.dart';

class KanjiDetailDialog extends StatefulWidget {
  final Kanji? kanji;
  final Function(Map<String, dynamic>)? onSave;
  final bool isReadOnly;

  const KanjiDetailDialog({
    Key? key,
    this.kanji,
    this.onSave,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  State<KanjiDetailDialog> createState() => _KanjiDetailDialogState();
}

class _KanjiDetailDialogState extends State<KanjiDetailDialog> {
  late final TextEditingController _characterController;
  late final TextEditingController _meaningsController;
  late final TextEditingController _onyomiController;
  late final TextEditingController _kunyomiController;
  late final TextEditingController _strokeCountController;
  late final TextEditingController _jlptController;
  late final TextEditingController _gradeController;
  late final TextEditingController _frequencyController;
  late final TextEditingController _radicalsController;

  bool get _isEditing => widget.kanji != null;

  @override
  void initState() {
    super.initState();

    _characterController = TextEditingController(
      text: widget.kanji?.character ?? '',
    );
    _meaningsController = TextEditingController(
      text: widget.kanji?.meanings ?? '',
    );
    _onyomiController = TextEditingController(text: widget.kanji?.onyomi ?? '');
    _kunyomiController = TextEditingController(
      text: widget.kanji?.kunyomi ?? '',
    );
    _strokeCountController = TextEditingController(
      text: widget.kanji?.strokeCount?.toString() ?? '',
    );
    _jlptController = TextEditingController(
      text: widget.kanji?.jlpt?.toString() ?? '',
    );
    _gradeController = TextEditingController(
      text: widget.kanji?.grade?.toString() ?? '',
    );
    _frequencyController = TextEditingController(
      text: widget.kanji?.frequency?.toString() ?? '',
    );
    _radicalsController = TextEditingController(
      text: widget.kanji?.radicals ?? '',
    );
  }

  @override
  void dispose() {
    _characterController.dispose();
    _meaningsController.dispose();
    _onyomiController.dispose();
    _kunyomiController.dispose();
    _strokeCountController.dispose();
    _jlptController.dispose();
    _gradeController.dispose();
    _frequencyController.dispose();
    _radicalsController.dispose();
    super.dispose();
  }

  void _save() {
    if (widget.onSave != null) {
      final data = {
        'character': _characterController.text.trim(),
        'meanings': _meaningsController.text.trim(),
        'onyomi': _onyomiController.text.trim().isEmpty
            ? null
            : _onyomiController.text.trim(),
        'kunyomi': _kunyomiController.text.trim().isEmpty
            ? null
            : _kunyomiController.text.trim(),
        'strokeCount': int.tryParse(_strokeCountController.text.trim()),
        'jlpt': int.tryParse(_jlptController.text.trim()),
        'grade': int.tryParse(_gradeController.text.trim()),
        'frequency': int.tryParse(_frequencyController.text.trim()),
        'radicals': _radicalsController.text.trim().isEmpty
            ? null
            : _radicalsController.text.trim(),
      };
      widget.onSave!(data);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.isReadOnly
                        ? 'Kanji Details'
                        : _isEditing
                        ? 'Edit Kanji'
                        : 'Add New Kanji',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Form fields
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Character (required)
                    _buildTextField(
                      controller: _characterController,
                      label: 'Character *',
                      hint: 'Enter kanji character',
                      readOnly: widget.isReadOnly,
                    ),
                    const SizedBox(height: 16),

                    // Meanings (required)
                    _buildTextField(
                      controller: _meaningsController,
                      label: 'Meanings *',
                      hint: 'Enter meanings separated by commas',
                      readOnly: widget.isReadOnly,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Readings
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _onyomiController,
                            label: 'Onyomi (音読み)',
                            hint: 'e.g., コウ, キョウ',
                            readOnly: widget.isReadOnly,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _kunyomiController,
                            label: 'Kunyomi (訓読み)',
                            hint: 'e.g., たか.い, たか.める',
                            readOnly: widget.isReadOnly,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Numbers
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _strokeCountController,
                            label: 'Stroke Count',
                            hint: 'Number of strokes',
                            readOnly: widget.isReadOnly,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _jlptController,
                            label: 'JLPT Level',
                            hint: '1-5',
                            readOnly: widget.isReadOnly,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _gradeController,
                            label: 'School Grade',
                            hint: '1-6',
                            readOnly: widget.isReadOnly,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _frequencyController,
                            label: 'Frequency',
                            hint: 'Usage frequency',
                            readOnly: widget.isReadOnly,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Radicals
                    _buildTextField(
                      controller: _radicalsController,
                      label: 'Radicals',
                      hint: 'Kanji components/radicals',
                      readOnly: widget.isReadOnly,
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            if (!widget.isReadOnly) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(_isEditing ? 'Update' : 'Add'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.indigo),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: readOnly,
            fillColor: readOnly ? Colors.grey[100] : null,
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
