import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../kanji_list/domain/entities/category_entity.dart';
import '../bloc/category_bloc.dart';
import 'package:intl/intl.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoriesLoaded) {
            return _buildCategoryTable(state.categories);
          }

          if (state is CategoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CategoryBloc>().add(LoadCategories());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No categories loaded'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  Widget _buildCategoryTable(List<CategoryEntity> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No categories yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first category',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
            columns: const [
              DataColumn(
                label: Text(
                  'ID',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Created',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: categories.map((category) {
              return DataRow(
                cells: [
                  DataCell(Text(category.id.toString())),
                  DataCell(Text(category.name)),
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Text(
                        category.description ?? '-',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(DateFormat('yyyy-MM-dd').format(category.createdAt)),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Edit',
                          onPressed: () =>
                              _showCategoryDialog(context, category: category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete',
                          onPressed: () => _confirmDelete(context, category),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {CategoryEntity? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(
      text: category?.description ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.length > 100) {
                      return 'Name must be less than 100 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value != null && value.length > 500) {
                      return 'Description must be less than 500 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();

                if (category == null) {
                  context.read<CategoryBloc>().add(
                    CreateCategory(
                      name: name,
                      description: description.isEmpty ? null : description,
                    ),
                  );
                } else {
                  context.read<CategoryBloc>().add(
                    UpdateCategory(
                      id: category.id,
                      name: name,
                      description: description.isEmpty ? null : description,
                    ),
                  );
                }
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(category == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, CategoryEntity category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryBloc>().add(DeleteCategory(category.id));
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
