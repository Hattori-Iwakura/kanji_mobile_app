import 'package:flutter/material.dart';
import 'package:kanji_mobile_app/core/network/api_client.dart';
import 'package:kanji_mobile_app/features/kanji/domain/entities/kanji.dart';

class AdminKanjiManagementPage extends StatefulWidget {
  final ApiClient apiClient;

  const AdminKanjiManagementPage({super.key, required this.apiClient});

  @override
  State<AdminKanjiManagementPage> createState() =>
      _AdminKanjiManagementPageState();
}

class _AdminKanjiManagementPageState extends State<AdminKanjiManagementPage> {
  bool _isLoading = true;
  String? _error;

  List<Kanji> _kanjis = [];
  int _total = 0;
  int _currentPage = 0;
  final int _pageSize = 20;

  String _searchQuery = '';
  int? _selectedJlpt;
  int? _selectedGrade;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKanjis();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadKanjis() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final queryParams = <String, dynamic>{
        'limit': _pageSize,
        'offset': _currentPage * _pageSize,
      };

      if (_searchQuery.isNotEmpty) {
        queryParams['query'] = _searchQuery;
      }
      if (_selectedJlpt != null) {
        queryParams['jlpt'] = _selectedJlpt;
      }
      if (_selectedGrade != null) {
        queryParams['grade'] = _selectedGrade;
      }

      final response = await widget.apiClient.dio.get(
        '/kanji',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data']['items'];
      final kanjis = data
          .map(
            (json) => Kanji(
              id: json['id'],
              character: json['character'],
              meanings: json['meanings'],
              onyomi: json['onyomi'],
              kunyomi: json['kunyomi'],
              jlpt: json['jlpt'],
              grade: json['grade'],
              strokeCount: json['strokeCount'],
              frequency: json['frequency'],
              radical: json['radical'],
              radicalMeaning: json['radicalMeaning'],
              createdAt: DateTime.parse(json['createdAt']),
              updatedAt: DateTime.parse(json['updatedAt']),
            ),
          )
          .toList();

      setState(() {
        _kanjis = kanjis;
        _total = response.data['data']['total'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteKanji(Kanji kanji) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Kanji',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${kanji.character}"?\nThis action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await widget.apiClient.dio.delete('/kanji/${kanji.id}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kanji "${kanji.character}" deleted successfully'),
            backgroundColor: Colors.tealAccent.shade700,
          ),
        );
        _loadKanjis();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete kanji: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showAddEditDialog([Kanji? kanji]) {
    final isEdit = kanji != null;
    final characterController = TextEditingController(
      text: kanji?.character ?? '',
    );
    final meaningsController = TextEditingController(
      text: kanji?.meanings ?? '',
    );
    final onyomiController = TextEditingController(text: kanji?.onyomi ?? '');
    final kunyomiController = TextEditingController(text: kanji?.kunyomi ?? '');
    final jlptController = TextEditingController(
      text: kanji?.jlpt?.toString() ?? '',
    );
    final gradeController = TextEditingController(
      text: kanji?.grade?.toString() ?? '',
    );
    final strokeCountController = TextEditingController(
      text: kanji?.strokeCount?.toString() ?? '',
    );
    final frequencyController = TextEditingController(
      text: kanji?.frequency?.toString() ?? '',
    );
    final radicalController = TextEditingController(text: kanji?.radical ?? '');
    final radicalMeaningController = TextEditingController(
      text: kanji?.radicalMeaning ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isEdit ? Icons.edit : Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isEdit ? 'Edit Kanji' : 'Add New Kanji',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  characterController,
                  'Character *',
                  Icons.text_fields,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  meaningsController,
                  'Meanings *',
                  Icons.translate,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  onyomiController,
                  'Onyomi (音読み)',
                  Icons.volume_up,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  kunyomiController,
                  'Kunyomi (訓読み)',
                  Icons.hearing,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        jlptController,
                        'JLPT (1-5)',
                        Icons.school,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        gradeController,
                        'Grade (1-6)',
                        Icons.grade,
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        strokeCountController,
                        'Strokes',
                        Icons.create,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        frequencyController,
                        'Frequency',
                        Icons.trending_up,
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  radicalController,
                  'Radical (部首)',
                  Icons.category,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  radicalMeaningController,
                  'Radical Meaning',
                  Icons.description,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (characterController.text.isEmpty ||
                  meaningsController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Character and meanings are required'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              final body = <String, dynamic>{
                'character': characterController.text.trim(),
                'meanings': meaningsController.text.trim(),
              };

              if (onyomiController.text.isNotEmpty) {
                body['onyomi'] = onyomiController.text.trim();
              }
              if (kunyomiController.text.isNotEmpty) {
                body['kunyomi'] = kunyomiController.text.trim();
              }
              if (jlptController.text.isNotEmpty) {
                body['jlpt'] = int.tryParse(jlptController.text.trim());
              }
              if (gradeController.text.isNotEmpty) {
                body['grade'] = int.tryParse(gradeController.text.trim());
              }
              if (strokeCountController.text.isNotEmpty) {
                body['strokeCount'] = int.tryParse(
                  strokeCountController.text.trim(),
                );
              }
              if (frequencyController.text.isNotEmpty) {
                body['frequency'] = int.tryParse(
                  frequencyController.text.trim(),
                );
              }
              if (radicalController.text.isNotEmpty) {
                body['radical'] = radicalController.text.trim();
              }
              if (radicalMeaningController.text.isNotEmpty) {
                body['radicalMeaning'] = radicalMeaningController.text.trim();
              }

              try {
                if (isEdit) {
                  await widget.apiClient.dio.put(
                    '/kanji/${kanji.id}',
                    data: body,
                  );
                } else {
                  await widget.apiClient.dio.post('/kanji', data: body);
                }

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Kanji ${isEdit ? 'updated' : 'created'} successfully',
                      ),
                      backgroundColor: Colors.tealAccent.shade700,
                    ),
                  );
                  _loadKanjis();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black87,
            ),
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.tealAccent, size: 20),
        filled: true,
        fillColor: const Color(0xFF0F1419),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF071126), Color(0xFF0B0F14)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildSearchAndFilters(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _error != null
                    ? _buildErrorState()
                    : _buildKanjiList(),
              ),
              _buildPaginationControls(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Kanji',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.text_fields, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kanji Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$_total total kanji',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.tealAccent),
            onPressed: _loadKanjis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search kanji...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.tealAccent),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white60),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _currentPage = 0;
                        });
                        _loadKanjis();
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF1A1F2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) {
              setState(() {
                _searchQuery = value;
                _currentPage = 0;
              });
              _loadKanjis();
            },
          ),
          const SizedBox(height: 12),
          // JLPT and Grade filters
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  'JLPT',
                  _selectedJlpt,
                  [null, 5, 4, 3, 2, 1],
                  (value) {
                    setState(() {
                      _selectedJlpt = value;
                      _currentPage = 0;
                    });
                    _loadKanjis();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownFilter(
                  'Grade',
                  _selectedGrade,
                  [null, 1, 2, 3, 4, 5, 6],
                  (value) {
                    setState(() {
                      _selectedGrade = value;
                      _currentPage = 0;
                    });
                    _loadKanjis();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    int? selected,
    List<int?> options,
    Function(int?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selected,
          hint: Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          dropdownColor: const Color(0xFF1A1F2E),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.tealAccent),
          isExpanded: true,
          items: options.map((option) {
            return DropdownMenuItem<int?>(
              value: option,
              child: Text(
                option == null ? 'All $label' : '$label $option',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.tealAccent),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Kanji',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadKanjis,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanjiList() {
    if (_kanjis.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: Colors.white.withOpacity(0.3),
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'No Kanji Found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.tealAccent,
      backgroundColor: const Color(0xFF1A1F2E),
      onRefresh: _loadKanjis,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _kanjis.length,
        itemBuilder: (context, index) {
          return _buildKanjiCard(_kanjis[index]);
        },
      ),
    );
  }

  Widget _buildKanjiCard(Kanji kanji) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Large Kanji character
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    kanji.character,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Kanji info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kanji.meanings,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (kanji.onyomi != null || kanji.kunyomi != null)
                        Row(
                          children: [
                            if (kanji.onyomi != null) ...[
                              const Icon(
                                Icons.volume_up,
                                color: Colors.tealAccent,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                kanji.onyomi!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            if (kanji.kunyomi != null) ...[
                              const Icon(
                                Icons.hearing,
                                color: Colors.orangeAccent,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  kanji.kunyomi!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (kanji.jlpt != null)
                            _buildBadge('N${kanji.jlpt}', Colors.blueAccent),
                          if (kanji.grade != null) ...[
                            const SizedBox(width: 8),
                            _buildBadge('G${kanji.grade}', Colors.purpleAccent),
                          ],
                          if (kanji.strokeCount != null) ...[
                            const SizedBox(width: 8),
                            _buildBadge(
                              '${kanji.strokeCount}画',
                              Colors.tealAccent,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.tealAccent,
                        size: 20,
                      ),
                      onPressed: () => _showAddEditDialog(kanji),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      onPressed: () => _deleteKanji(kanji),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (kanji.radical != null) ...[
            const Divider(color: Color(0xFF2A2F3E), height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.category, color: Colors.white38, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Radical: ${kanji.radical}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  if (kanji.radicalMeaning != null) ...[
                    const Text(' • ', style: TextStyle(color: Colors.white38)),
                    Text(
                      kanji.radicalMeaning!,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = (_total / _pageSize).ceil();
    final hasNext = _currentPage < totalPages - 1;
    final hasPrev = _currentPage > 0;

    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: hasPrev
                ? () {
                    setState(() => _currentPage--);
                    _loadKanjis();
                  }
                : null,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasPrev
                  ? Colors.tealAccent
                  : Colors.grey.shade800,
              foregroundColor: hasPrev ? Colors.black87 : Colors.white38,
              disabledBackgroundColor: Colors.grey.shade800,
              disabledForegroundColor: Colors.white38,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          Text(
            'Page ${_currentPage + 1} of $totalPages',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          ElevatedButton.icon(
            onPressed: hasNext
                ? () {
                    setState(() => _currentPage++);
                    _loadKanjis();
                  }
                : null,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasNext
                  ? Colors.tealAccent
                  : Colors.grey.shade800,
              foregroundColor: hasNext ? Colors.black87 : Colors.white38,
              disabledBackgroundColor: Colors.grey.shade800,
              disabledForegroundColor: Colors.white38,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
