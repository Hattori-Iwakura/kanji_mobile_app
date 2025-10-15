import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/flashcard_deck_bloc.dart';
import '../bloc/flashcard_deck_event.dart';
import '../bloc/flashcard_deck_state.dart';

class CreateDeckPage extends StatefulWidget {
  const CreateDeckPage({Key? key}) : super(key: key);

  @override
  State<CreateDeckPage> createState() => _CreateDeckPageState();
}

class _CreateDeckPageState extends State<CreateDeckPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _sourceType = 'custom';
  bool _isPublic = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Create Flashcard Deck'),
        backgroundColor: Colors.grey[900],
      ),
      body: BlocListener<FlashcardDeckBloc, FlashcardDeckState>(
        listener: (context, state) {
          if (state is FlashcardDeckCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Deck created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }

          if (state is FlashcardDeckError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<FlashcardDeckBloc, FlashcardDeckState>(
          builder: (context, state) {
            final isLoading = state is FlashcardDeckLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Deck Name
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Deck Name',
                        labelStyle: const TextStyle(color: Colors.grey),
                        hintText: 'e.g., JLPT N5 Kanji',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.style, color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a deck name';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        labelStyle: const TextStyle(color: Colors.grey),
                        hintText: 'Add a description for this deck...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.description_outlined,
                          color: Colors.blue,
                        ),
                        alignLabelWithHint: true,
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Source Type
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deck Source',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          RadioListTile<String>(
                            title: const Text(
                              'Custom Deck',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Manually add cards to this deck',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            value: 'custom',
                            groupValue: _sourceType,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _sourceType = value!;
                                    });
                                  },
                            activeColor: Colors.blue,
                          ),
                          RadioListTile<String>(
                            title: const Text(
                              'From Kanji List',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Create deck from an existing kanji collection (Coming soon)',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            value: 'kanji_list',
                            groupValue: _sourceType,
                            onChanged: null, // Disabled for now
                            activeColor: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Public Switch
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.public, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Make deck public',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Allow others to view and study this deck',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isPublic,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _isPublic = value;
                                    });
                                  },
                            activeColor: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Create Button
                    ElevatedButton(
                      onPressed: isLoading ? null : _createDeck,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Create Deck',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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

  void _createDeck() {
    if (_formKey.currentState!.validate()) {
      context.read<FlashcardDeckBloc>().add(
        CreateDeckEvent(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          sourceType: _sourceType,
          isPublic: _isPublic,
        ),
      );
    }
  }
}
