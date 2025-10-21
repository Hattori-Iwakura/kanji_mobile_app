import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../admin/presentation/bloc/category_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../bloc/kanji_list_bloc.dart';
import '../bloc/kanji_list_event.dart';

class CreateEditListDialog extends StatefulWidget {
  final int? listId;
  final String? initialName;
  final String? initialDescription;
  final int? initialCategoryId;

  const CreateEditListDialog({
    super.key,
    this.listId,
    this.initialName,
    this.initialDescription,
    this.initialCategoryId,
  });

  @override
  State<CreateEditListDialog> createState() => _CreateEditListDialogState();
}

class _CreateEditListDialogState extends State<CreateEditListDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  int? _selectedCategoryId;
  List<CategoryEntity> _categories = [];
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    _selectedCategoryId = widget.initialCategoryId;

    // Load categories
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoriesLoaded) {
          setState(() {
            _categories = state.categories;
            _loadingCategories = false;
          });
        } else if (state is CategoryError) {
          setState(() {
            _loadingCategories = false;
          });
        }
      },
      child: AlertDialog(
        title: Text(widget.listId == null ? 'Create New List' : 'Edit List'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    hintText: 'Enter list name',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Enter description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _loadingCategories
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : DropdownButtonFormField<int?>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category (optional)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('No category'),
                          ),
                          ..._categories.map((category) {
                            return DropdownMenuItem<int?>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                      ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _handleSubmit,
            child: Text(widget.listId == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final description = _descriptionController.text.trim();

    if (widget.listId == null) {
      // Create new list
      context.read<KanjiListBloc>().add(
        CreateListEvent(
          name: name,
          description: description.isEmpty ? null : description,
          categoryId: _selectedCategoryId,
        ),
      );
    } else {
      // Update existing list
      context.read<KanjiListBloc>().add(
        UpdateListEvent(
          id: widget.listId!,
          name: name,
          description: description.isEmpty ? null : description,
          categoryId: _selectedCategoryId,
        ),
      );
    }

    Navigator.pop(context);
  }
}
