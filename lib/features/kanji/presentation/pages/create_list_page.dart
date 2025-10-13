import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/kanji_list.dart';
import '../bloc/kanji_list_bloc.dart';
import '../bloc/kanji_list_event.dart';
import '../bloc/kanji_list_state.dart';
import '../../../../injection_container.dart' as di;

class CreateListPage extends StatefulWidget {
  const CreateListPage({super.key});

  @override
  State<CreateListPage> createState() => _CreateListPageState();
}

class _CreateListPageState extends State<CreateListPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  ListFilterType _selectedFilterType = ListFilterType.jlptLevel;
  int? _selectedJlptLevel = 5;
  int? _selectedGrade = 1;
  int _frequencyMin = 1;
  int _frequencyMax = 500;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<KanjiListBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tạo danh sách mới'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: BlocListener<KanjiListBloc, KanjiListState>(
          listener: (context, state) {
            if (state is KanjiListCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã tạo danh sách "${state.list.name}"'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            } else if (state is KanjiListError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<KanjiListBloc, KanjiListState>(
            builder: (context, state) {
              final isLoading = state is KanjiListLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfo(),
                      const SizedBox(height: 24),
                      _buildFilterTypeSelection(),
                      const SizedBox(height: 24),
                      _buildFilterOptions(),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleCreate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Tạo danh sách',
                                  style: TextStyle(fontSize: 16),
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
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin cơ bản',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên danh sách *',
                hintText: 'Ví dụ: Kanji JLPT N5',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên danh sách';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Mô tả (tùy chọn)',
                hintText: 'Mô tả ngắn về danh sách',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTypeSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn loại danh sách',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterTypeOption(
              ListFilterType.jlptLevel,
              'JLPT Level',
              'Kanji theo cấp độ JLPT',
              Icons.school,
              Colors.purple,
            ),
            _buildFilterTypeOption(
              ListFilterType.grade,
              'Lớp học',
              'Kanji theo lớp học (1-6)',
              Icons.grade,
              Colors.blue,
            ),
            _buildFilterTypeOption(
              ListFilterType.frequency,
              'Độ phổ biến',
              'Kanji thường gặp nhất',
              Icons.trending_up,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTypeOption(
    ListFilterType type,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedFilterType == type;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilterType = type;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : null,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tùy chọn lọc',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterContent() {
    switch (_selectedFilterType) {
      case ListFilterType.jlptLevel:
        return _buildJlptLevelSelector();
      case ListFilterType.grade:
        return _buildGradeSelector();
      case ListFilterType.frequency:
        return _buildFrequencySelector();
      case ListFilterType.custom:
        return const Text('Danh sách tùy chỉnh - Thêm kanji thủ công');
    }
  }

  Widget _buildJlptLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chọn cấp độ JLPT:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [5, 4, 3, 2, 1].map((level) {
            final isSelected = _selectedJlptLevel == level;
            return ChoiceChip(
              label: Text('N$level'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedJlptLevel = level;
                });
              },
              selectedColor: Colors.purple.shade100,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGradeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chọn lớp học:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [1, 2, 3, 4, 5, 6].map((grade) {
            final isSelected = _selectedGrade == grade;
            return ChoiceChip(
              label: Text('Lớp $grade'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedGrade = grade;
                });
              },
              selectedColor: Colors.blue.shade100,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Độ phổ biến: $_frequencyMin - $_frequencyMax'),
        RangeSlider(
          values: RangeValues(
            _frequencyMin.toDouble(),
            _frequencyMax.toDouble(),
          ),
          min: 1,
          max: 2500,
          divisions: 100,
          labels: RangeLabels(
            _frequencyMin.toString(),
            _frequencyMax.toString(),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _frequencyMin = values.start.round();
              _frequencyMax = values.end.round();
            });
          },
        ),
        Text(
          'Kanji phổ biến hơn có số thứ tự thấp hơn (1 = phổ biến nhất)',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  void _handleCreate() {
    if (_formKey.currentState!.validate()) {
      int? filterValue;
      int? freqMin;
      int? freqMax;

      switch (_selectedFilterType) {
        case ListFilterType.jlptLevel:
          filterValue = _selectedJlptLevel;
          break;
        case ListFilterType.grade:
          filterValue = _selectedGrade;
          break;
        case ListFilterType.frequency:
          freqMin = _frequencyMin;
          freqMax = _frequencyMax;
          break;
        case ListFilterType.custom:
          break;
      }

      context.read<KanjiListBloc>().add(
        CreateListEvent(
          name: _nameController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          filterType: _selectedFilterType,
          filterValue: filterValue,
          frequencyMin: freqMin,
          frequencyMax: freqMax,
        ),
      );
    }
  }
}
